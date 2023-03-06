const fs = require("fs")
const path = require("path")
const papa = require("papaparse")
const { getUserAgent, downloadImage, createLogger } = require("./utils")
const puppeteer = require("puppeteer")
const { PrismaClient, DocumentTypeEnum } = require("@prisma/client");

const allowedCategories = [
  "Источники Бесперебойного Питания",
  "Комплектующие для компьютеров",
  "Компьютеры",
  "Ноутбуки и планшеты",
  "Оборудование для геймеров",
  "Периферия и аксессуары",
  "Серверы и СХД",
  "Сетевое оборудование",
  "Расходные материалы"
]

const logger = createLogger()
const prisma = new PrismaClient()

async function parse() {
  const file = fs.createReadStream(path.join(__dirname, "../", "vendor", "merlion-price.csv"))
  const browser = await puppeteer.launch()
  const page = await browser.newPage()
  await page.setViewport({ width: 1980, height: 1080 });
  let count = 0

  const [supplierDB, currencyDB, languageDB ] = await (async () => {
    return [
      await prisma.supplier.findFirst({ where: { name: "Мерлион" } }),
      await prisma.currency.findFirst({ where: { name: "rub" } }),
      await prisma.language.findFirst({ where: { language: "ru" } })
    ]
  })()

  if (!supplierDB || !currencyDB || !languageDB) {
    console.error("Seed database first!")
    logger("Seed database first!")
    process.exit(0)
  }

  await new Promise((resolve) => {
    papa.parse(file, {
      worker: true,
      skipEmptyLines: true,
      step: async ({ data }, parser) => {
        parser.pause()

        data = {
          category1: data[0],
          category2: data[1],
          category3: data[2],
          vendor: data[3],
          supplier_partnumber: data[4],
          vendor_partnumber: data[6],
          price: parseFloat(data[10].replace(/,/, '.')),
        }

        if (allowedCategories.includes(data.category1)) {
          try {
            await page.setUserAgent(getUserAgent());
            await page.goto(`https://merlion.com/catalog/product/${data.supplier_partnumber}/`, { waitUntil: "load", timeout: 0 });
            const [ parsedData, properties ] = await page.evaluate(() => {
                const title = document.querySelector(".product-text-block h1").innerText
                const description = document.querySelector(".product-text-block h1+p").innerText
                const imageURLs = [...document.querySelectorAll("#productCardPhoto .swiper-wrapper .swiper-slide img")].map(img => img.src)
                const properties = [...document.querySelectorAll(".product-text-block .product_content .property-wrapper")].map(elem => {
                  const key = elem.querySelector(".property").innerText.replace("\n", "").trim()
                  const value = elem.querySelector(".value").innerText.replace("\n", "").trim()
                  return { key, value }
                })
  
                return [{ title, description, imageURLs }, properties]
            })
            Object.assign(data, parsedData)
            
            for (const propery of properties) {
              switch(propery.key) {
                case "Описание":
                  data.description = propery.value
                  break
                case "Модель":
                    data.model = propery.value
                    break
              }
            }
  
            const vendorDB = await prisma.vendor.upsert({ where: { name: data.vendor },update: {}, create: { name: data.vendor } })
  
            const productsDB = await prisma.product.findMany({where: { vendor_id: vendorDB.id, vendor_partnumber: data.vendor_partnumber }}) 
            if (productsDB.length > 0) {
              for (const productDB of productsDB) {
                let supplierProductPriceDB = await prisma.supplierProductPrice.findFirst({ where: { supplier_id: supplierDB.id, supplier_partnumber: data.supplier_partnumber, currency_id: currencyDB.id, product_id: productDB.id } })
  
                if (!supplierProductPriceDB) {
                  console.log(productDB)
                  supplierProductPriceDB = await prisma.supplierProductPrice.create({
                    data: {
                      product_id: productDB.id,
                      supplier_id: supplierDB.id,
                      supplier_partnumber: data.supplier_partnumber,
                      currency_id: currencyDB.id,
                      price: data.price || 0,
                      price_date: new Date()
                    }
                  })
                }
              }
            } else {
              // Categories
              let categoryDB;
              categoryDB = await prisma.category.findFirst({ where: { name: data.category1, parent_id: null } })
              if (!categoryDB) categoryDB = await prisma.category.create({ data: { name: data.category1, parent_id: null } })
  
              if (data.category2) {
                const parentId = categoryDB.id
                categoryDB = await prisma.category.findFirst({ where: { name: data.category2, parent_id: parentId } })
                if (!categoryDB) categoryDB = await prisma.category.create({ data: { name: data.category2, parent_id: parentId } })
              }
  
              if (data.category3) {
                const parentId = categoryDB.id
                categoryDB = await prisma.category.findFirst({ where: { name: data.category3, parent_id: parentId } })
                if (!categoryDB) categoryDB = await prisma.category.create({ data: { name: data.category3, parent_id: parentId } })
              }
  
              // Images
              const documentIDs = []
              for (const url of data.imageURLs) {
                const { name, localURL } = await downloadImage(path.join(__dirname, "../", "static","img"), url)
                const documentDB = await prisma.document.create({ data: { url: localURL, name, type: DocumentTypeEnum.IMAGE } })
                documentIDs.push(documentDB.id)
              }
  
              console.log(documentIDs)
  
              // Description
              const descriptionDB = await prisma.description.create({
                data: {
                  text: data.description,
                  language_id: languageDB.id
                }
              })
  
              let productDB = await prisma.product.create({
                data: {
                  vendor_id: vendorDB.id,
                  vendor_partnumber: data.vendor_partnumber,
                  name: data.title,
                  category_id: categoryDB.id,
                  document_id: documentIDs,
                  description_id: descriptionDB.id
                }
              })
  
              supplierProductPriceDB = await prisma.supplierProductPrice.create({
                data: {
                  product_id: productDB.id,
                  supplier_id: supplierDB.id,
                  supplier_partnumber: data.supplier_partnumber,
                  price_date: new Date(),
                  price: data.price || 0,
                  currency_id: currencyDB.id
                }
              })

              // Model
              if (data.model) {
                let modelDB = await prisma.model.findFirst({ where: { vendor_id: vendorDB.id, name: data.model } })
                if (!modelDB) modelDB = await prisma.model.create({ data: { vendor_id: vendorDB.id, name: data.model } })

                let modelProductDB = await prisma.modelProduct.findFirst({ where: { model_id: modelDB.id, product_id: productDB.id } })
                if (!modelProductDB) modelProductDB = await prisma.modelProduct.create({ data: { model_id: modelDB.id, product_id: productDB.id } })
              }
            }
            
  
            logger(`Parsed ${data.supplier_partnumber} on line ${count + 1}`)
          } catch(e) {
            logger(`Line ${count + 1} was skipped with error: ${e}`)
          }
        } else {
          logger(`Line ${count + 1} was skipped.`)
        }

        count++
        parser.resume()
      },
      complete: () => {
        resolve(true)
      }
    })
  })
}

module.exports = {
  parse
}