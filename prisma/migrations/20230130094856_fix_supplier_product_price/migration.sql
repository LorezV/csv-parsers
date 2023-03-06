/*
  Warnings:

  - Made the column `price` on table `SupplierProductPrice` required. This step will fail if there are existing NULL values in that column.
  - Made the column `currency_id` on table `SupplierProductPrice` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "SupplierProductPrice" ALTER COLUMN "price" SET NOT NULL,
ALTER COLUMN "currency_id" SET NOT NULL;
