/*
  Warnings:

  - The primary key for the `CartProduct` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - A unique constraint covering the columns `[id,user_id,type]` on the table `Cart` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateEnum
CREATE TYPE "CartType" AS ENUM ('CART', 'PRODUCT_WATCHLIST', 'SUPPLIER_WATCHLIST');

-- DropForeignKey
ALTER TABLE "CartProduct" DROP CONSTRAINT "CartProduct_product_id_fkey";

-- DropForeignKey
ALTER TABLE "CartProduct" DROP CONSTRAINT "CartProduct_supplier_id_fkey";

-- DropIndex
DROP INDEX "Cart_id_user_id_key";

-- AlterTable
ALTER TABLE "Cart" ADD COLUMN     "type" "CartType" NOT NULL DEFAULT 'CART';

-- AlterTable
ALTER TABLE "CartProduct" DROP CONSTRAINT "CartProduct_pkey",
ADD COLUMN     "id" SERIAL NOT NULL,
ALTER COLUMN "product_id" DROP NOT NULL,
ALTER COLUMN "supplier_id" DROP NOT NULL,
ADD CONSTRAINT "CartProduct_pkey" PRIMARY KEY ("id");

-- CreateIndex
CREATE UNIQUE INDEX "Cart_id_user_id_type_key" ON "Cart"("id", "user_id", "type");

-- AddForeignKey
ALTER TABLE "CartProduct" ADD CONSTRAINT "CartProduct_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "Product"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CartProduct" ADD CONSTRAINT "CartProduct_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "Supplier"("id") ON DELETE SET NULL ON UPDATE CASCADE;
