/*
  Warnings:

  - Made the column `supplier_id` on table `CartProduct` required. This step will fail if there are existing NULL values in that column.

*/
-- DropForeignKey
ALTER TABLE "CartProduct" DROP CONSTRAINT "CartProduct_supplier_id_fkey";

-- AlterTable
ALTER TABLE "CartProduct" ALTER COLUMN "supplier_id" SET NOT NULL;

-- AddForeignKey
ALTER TABLE "CartProduct" ADD CONSTRAINT "CartProduct_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "Supplier"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
