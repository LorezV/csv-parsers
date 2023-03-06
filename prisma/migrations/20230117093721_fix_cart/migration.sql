/*
  Warnings:

  - You are about to drop the `Cart_product` table. If the table is not empty, all the data it contains will be lost.
  - Made the column `updated_at` on table `Cart` required. This step will fail if there are existing NULL values in that column.

*/
-- DropForeignKey
ALTER TABLE "Cart_product" DROP CONSTRAINT "Cart_product_cart_id_fkey";

-- DropForeignKey
ALTER TABLE "Cart_product" DROP CONSTRAINT "Cart_product_product_id_fkey";

-- AlterTable
ALTER TABLE "Cart" ALTER COLUMN "updated_at" SET NOT NULL;

-- DropTable
DROP TABLE "Cart_product";

-- CreateTable
CREATE TABLE "CartProduct" (
    "cart_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3)
);

-- CreateIndex
CREATE UNIQUE INDEX "CartProduct_cart_id_product_id_key" ON "CartProduct"("cart_id", "product_id");

-- AddForeignKey
ALTER TABLE "CartProduct" ADD CONSTRAINT "CartProduct_cart_id_fkey" FOREIGN KEY ("cart_id") REFERENCES "Cart"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CartProduct" ADD CONSTRAINT "CartProduct_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "Product"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
