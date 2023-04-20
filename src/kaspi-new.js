const fs = require("fs");
const path = require("path");
const papa = require("papaparse");
const { getUserAgent, downloadImage, createLogger } = require("./utils");
const puppeteer = require("puppeteer");
const { PrismaClient, DocumentTypeEnum } = require("@prisma/client");

const logger = createLogger();
const prisma = new PrismaClient();

async function parse() {
  const file = fs.createReadStream(
    path.join(__dirname, "../", "vendor", "kaspi-new.csv")
  );
  let count = 0;
  let countProducts = 0;

  await prisma.$queryRaw`SELECT setval('"Product_id_seq"', (SELECT MAX(id) FROM "Product"));`
  await prisma.$queryRaw`SELECT setval('"Description_id_seq"', (SELECT MAX(id) FROM "Description"));`
  await prisma.$queryRaw`SELECT setval('"Supplier_id_seq"', (SELECT MAX(id) FROM "Supplier"));`

  let supplierDB = await prisma.supplier.findFirst({
    where: { name: "Kaspi" },
  });
  if (!supplierDB) {
    supplierDB = await prisma.supplier.create({ data: { name: "Kaspi" } });
  }
  let currencyDB = await prisma.currency.findFirst({ where: { name: "usd" } });
  if (!currencyDB) {
    currencyDB = await prisma.currency.create({ data: { name: "usd" } });
  }
  let languageID = await prisma.language.findFirst({where: { language: "ru" }})
  if (!languageID)
    languageID = await prisma.language.create({ data: { language: "ru" } });

  // const r = await prisma.supplierProductPrice.deleteMany({
  //   where: { supplier_id: supplierDB.id },
  // });

  // console.log(`Deleted ${r.count} entities.`);

  await new Promise((resolve) => {
    papa.parse(file, {
      worker: true,
      skipEmptyLines: true,
      step: async ({ data }, parser) => {
        parser.pause();

        await (async () => {
          const result = {
            supplier_partnumber: data[0].trim(),
            name: data[1].trim(),
            currency: data[2].trim(),
            price: data[3].trim().toLowerCase(),
            categories: data[4].trim(),
            brand: data[7].trim().trim().toUpperCase(),
            vendor_partnumber: data[27].trim()
          };

          if (
            !result.supplier_partnumber.length > 0 ||
            !result.vendor_partnumber.length > 0 ||
            !result.price.length > 0 ||
            !data[0].trim().match(/^[0-9]+$/gm)
          ) return;
          result.price = result.price.replace(",", "")
          result.price = Math.ceil(parseFloat(result.price) * 0.002219 * 100) / 100;

          let vendorDB = await prisma.vendor.findFirst({ where: { name: result.brand } })
          if (!vendorDB) await prisma.vendor.create({ data: { name: result.brand } })

          let productDB = await prisma.product.findFirst({
            where: { vendor_partnumber: result.vendor_partnumber },
          });
          if (!productDB) {
            let categoryID = null;
            for (const categoryName of result.categories.split(",")) {
              categoryDB = (await prisma.category.findFirst({ where: { name: categoryName.trim() } }))?.id

              if (categoryID) break
            }

            productDB = await prisma.product.create({
              data: {
                vendor_id: vendorDB.id,
                vendor_partnumber: result.vendor_partnumber,
                name: result.name,
                category_id: categoryID
              },
            });

            countProducts++
          }

          if (productDB) {
            await prisma.supplierProductPrice.updateMany({
              where: { product_id: productDB.id, supplier_id: supplierDB.id },
              data: { deleted_at: new Date() }
            })

            const supplierProductPrice = await prisma.supplierProductPrice.create({
              data: {
                product_id: productDB.id,
                supplier_id: supplierDB.id,
                price_date: new Date(),
                price: result.price,
                supplier_partnumber: result.supplier_partnumber,
                currency_id: currencyDB.id
              }
            })
          }

          count++
        })();

        parser.resume();
      },
      complete: () => {
        console.log(count);
        console.log(countProducts);
        resolve(true);
      },
    });
  });
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