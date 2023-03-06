const fs = require("fs")
const path = require("path")
const papa = require("papaparse")
const { getUserAgent, downloadImage, createLogger } = require("./utils")
const puppeteer = require("puppeteer")
const { PrismaClient, DocumentTypeEnum } = require("@prisma/client");

const logger = createLogger()
const prisma = new PrismaClient()

async function parse() {
  const file = fs.createReadStream(path.join(__dirname, "../", "vendor", "al-style.csv"))
  const browser = await puppeteer.launch()
  const page = await browser.newPage()
  await page.setViewport({ width: 1980, height: 1080 });
  let count = 0

  const [supplierDB, currencyDB, languageDB ] = await (async () => {
    return [
      await prisma.supplier.findFirst({ where: { name: "Al-Style" } }),
      await prisma.currency.findFirst({ where: { name: "kzt" } }),
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

        if (/[0-9]+/g.test(data[0]) && /[0-9A-Z]+/g.test(data[1])) {
          const r = await prisma.product.findMany({where: {vendor_partnumber: data[1]}})
          if (r.length > 0) console.log(r)
        }

        count++;
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