const fs = require("fs");
const { Prisma, PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

async function main() {
  return await prisma.$transaction(async (tx) => {
    const supplier = await tx.supplier.create({ data: { name: "Мерлион" } })
    const currency = await tx.currency.create({ data: { name: "rub" } })
    const currencyRate = await tx.currencyRate.create({data: { currency_id: currency.id, date: new Date(), rate: 1 }})
    const language = await tx.language.create({ data: { language: "ru" } })
  })
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
