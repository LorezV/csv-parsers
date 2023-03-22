const fs = require("fs")
const path = require("path")
const papa = require("papaparse")
const { getUserAgent, downloadImage, createLogger } = require("./utils")
const puppeteer = require("puppeteer")
const { PrismaClient, DocumentTypeEnum } = require("@prisma/client");

const logger = createLogger()
const prisma = new PrismaClient()

async function parse() {
  const file = fs.createReadStream(path.join(__dirname, "../", "vendor", "ysoft.csv"))
  let count = 0

  let supplierDB = await prisma.supplier.findFirst({where: {name: "YSoft"}})
  if (!supplierDB) supplierDB = await prisma.supplier.create({data: { name: "YSoft" }})

  let currencyDB = await prisma.currency.findFirst({ where: { name: "usd" } });
  if (!currencyDB) currencyDB = await prisma.currency.create({ data: { name: "usd", CurrencyRate: { create: { rate: 1, date: new Date() } } } });

  let languageDB = await prisma.language.findFirst({ where: { language: "eu" } })
  if (!languageDB) languageDB = await prisma.language.create({ data: { language: "eu" } })

  let uCategoryDB = await prisma.category.findFirst({ where: { name: "Unknown" } })
  if (!uCategoryDB) uCategoryDB = await prisma.category.create({ data: { name: "Unknown" } })

  let vendorDB = await prisma.vendor.findFirst({ where: { name: "YSoft" } })
  if (!vendorDB) vendorDB = await prisma.vendor.create({ data: { name: "YSoft" } })

  await new Promise((resolve) => {
    papa.parse(file, {
      worker: true,
      skipEmptyLines: true,
      delimiter: ";",
      step: async ({ data }, parser) => {
        const result = {
          vendor: data[0],
          xerox_partnumber: data[1],
          partnumber: data[2],
          description: data[3],
          category: data[4],
          partner_price: parseFloat(data[6].replace("$", "").replace(",", ".")) || 0,
          price: parseFloat(data[7].replace("$", "").replace(",", ".")) || 0
        }
        if (result.xerox_partnumber == "TBC") return

        parser.pause()

        let category = uCategoryDB
        if (result.category.length > 0) {
          let category = await prisma.category.findFirst({ where: { name: result.category } })
          if (!category) category = await prisma.category.create({ data: { name: result.category } }) 
        }

        let productName = result.description.split(",")[0].replace(/^ysoft/mi, "").replace(/^ys/mi, "").trim()
        const description = result.description.split(",").slice(1).join(", ")
        const price  = result.price || 0

        let productDB = await prisma.product.findFirst({ where: { vendor_partnumber: result.xerox_partnumber } })
        if (!productDB) {
          const descriptionDB = await prisma.description.create({
            data: {
              text: description,
              language_id: languageDB.id
            }
          })

          productDB = await prisma.product.create({ data: {
            vendor_id: vendorDB.id,
            vendor_partnumber: result.xerox_partnumber,
            name: productName,
            description_id: descriptionDB.id,
            category_id: category.id
          } })
        }

        let supplierProductPriceDB = await prisma.supplierProductPrice.findFirst({
          where: {
            product_id: productDB.id,
            supplier_id: supplierDB.id,
          }
        })

        if (!supplierProductPriceDB) {
          supplierProductPriceDB = await prisma.supplierProductPrice.create({
            data: {
              product_id: productDB.id,
              supplier_id: supplierDB.id,
              price_date: new Date(),
              price: result.price,
              supplier_partnumber: result.partnumber,
              currency_id: currencyDB.id
            }
          })
        }

        parser.resume()
      },
      complete: () => {
        resolve(true)
      }
    })
  })
}

async function main() {
  await parse()
  console.log("end")
  await prisma.$disconnect()
}

main().catch(async e => {
  await prisma.$disconnect()
  console.error(e)
})