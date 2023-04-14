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
    path.join(__dirname, "../", "vendor", "dealer.csv")
  );
  let count = 0;
  let countProducts = 0;

  await prisma.$queryRaw`SELECT setval('"Product_id_seq"', (SELECT MAX(id) FROM "Product"));`;
  await prisma.$queryRaw`SELECT setval('"Description_id_seq"', (SELECT MAX(id) FROM "Description"));`;
  await prisma.$queryRaw`SELECT setval('"Supplier_id_seq"', (SELECT MAX(id) FROM "Supplier"));`

  let supplierDB = await prisma.supplier.findFirst({
    where: { name: "DEALER PRICE" },
  });
  if (!supplierDB) {
    supplierDB = await prisma.supplier.create({ data: { name: "DEALER PRICE" } });
  }
  let currencyDB = await prisma.currency.findFirst({ where: { name: "usd" } });
  if (!currencyDB) {
    currencyDB = await prisma.currency.create({ data: { name: "usd" } });
  }
  let languageID = await prisma.language.findFirst({
    where: { language: "ru" },
  });
  if (!languageID)
    languageID = await prisma.language.create({ data: { language: "ru" } });

  if (!supplierDB || !currencyDB) {
    console.error("Seed database first!");
    logger("Seed database first!");
    process.exit(0);
  }

  const vendorsDB = await prisma.vendor.findMany()
  const unknownVendorDB = await prisma.vendor.findFirst({where: {name: "Unknown"}})

  const r = await prisma.supplierProductPrice.deleteMany({
    where: { supplier_id: supplierDB.id },
  });

  console.log(`Deleted ${r.count} entities.`);

  await new Promise((resolve) => {
    papa.parse(file, {
      worker: true,
      skipEmptyLines: true,
      step: async ({ data }, parser) => {
        parser.pause();

        await (async () => {
          const result = {
            supplier_partnumber: data[0],
            title: data[2],
            vendor_partnumber: data[3],
            price: data[7],
            vendor_id: null,
          };

          if (
            !result.supplier_partnumber.length > 0 ||
            !result.vendor_partnumber.length > 0 ||
            !result.price.length > 0 ||
            !data[0].match(/^[0-9]+$/gm)
          )
            return;

          result.title = result.title.split(",")[0]
          result.price = parseFloat(result.price);

          for (const vendor of vendorsDB) {
            if (result.title.toLowerCase().includes(vendor.name.toLowerCase())) {
              result.vendor_id = vendor.id
            }
          }

          let productDB = await prisma.product.findFirst({
            where: { vendor_partnumber: result.vendor_partnumber },
          });
          if (!productDB) {
            let categoryDB = await prisma.category.findFirst({
              where: { name: "Unknown" },
            });

            let vendorDB = undefined;
            if (result.vendor_id) {
              vendorDB = await prisma.vendor.findFirst({
                where: { id: result.vendor_id },
              });
            }

            if (!vendorDB) vendorDB = unknownVendorDB

            productDB = await prisma.product.create({
              data: {
                vendor_id: vendorDB.id,
                vendor_partnumber: result.vendor_partnumber,
                name: result.title,
                category_id: categoryDB.id
              },
            });

            countProducts++;
          }

          if (productDB) {
            const supplierProductPrice =
              await prisma.supplierProductPrice.create({
                data: {
                  product_id: productDB.id,
                  supplier_id: supplierDB.id,
                  price_date: new Date(),
                  price: result.price,
                  supplier_partnumber: result.supplier_partnumber,
                  currency_id: currencyDB.id,
                },
              });
          }

          count++;
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
  await parse();
  console.log("end");
  await prisma.$disconnect();
}

main().catch(async (e) => {
  await prisma.$disconnect();
  console.error(e);
});
