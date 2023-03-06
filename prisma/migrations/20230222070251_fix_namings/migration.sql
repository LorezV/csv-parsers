/*
  Warnings:

  - You are about to drop the column `parentId` on the `Category` table. All the data in the column will be lost.
  - The primary key for the `CurrencyRate` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `id` on the `CurrencyRate` table. All the data in the column will be lost.
  - You are about to drop the column `userName` on the `User` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[supplier_id,supplier_partnumber]` on the table `SupplierProductPrice` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[user_name]` on the table `User` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `currency_id` to the `CurrencyRate` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "Category" DROP CONSTRAINT "Category_parentId_fkey";

-- DropForeignKey
ALTER TABLE "CurrencyRate" DROP CONSTRAINT "currency_id";

-- DropIndex
DROP INDEX "User_userName_key";

-- AlterTable
ALTER TABLE "Category" RENAME COLUMN "parentId" TO "parent_id";

-- AlterTable
ALTER TABLE "CurrencyRate" DROP CONSTRAINT "currencyrate_pk",
DROP COLUMN "id",
ADD COLUMN     "currency_id" INTEGER NOT NULL,
ADD CONSTRAINT "currencyrate_pk" PRIMARY KEY ("currency_id", "date");

-- AlterTable
ALTER TABLE "SupplierProductPrice" ADD COLUMN     "supplier_partnumber" TEXT;

-- AlterTable
ALTER TABLE "User" DROP COLUMN "userName",
ADD COLUMN     "user_name" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "SupplierProductPrice_supplier_id_supplier_partnumber_key" ON "SupplierProductPrice"("supplier_id", "supplier_partnumber");

-- CreateIndex
CREATE UNIQUE INDEX "User_user_name_key" ON "User"("user_name");

-- AddForeignKey
ALTER TABLE "CurrencyRate" ADD CONSTRAINT "currency_id" FOREIGN KEY ("currency_id") REFERENCES "Currency"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Category" ADD CONSTRAINT "Category_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "Category"("id") ON DELETE SET NULL ON UPDATE CASCADE;
