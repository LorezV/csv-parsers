/*
  Warnings:

  - You are about to drop the column `model_id` on the `Product` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "Product" DROP CONSTRAINT "product_model_id_fk";

-- AlterTable
ALTER TABLE "Product" DROP COLUMN "model_id";

-- CreateTable
CREATE TABLE "ModelProduct" (
    "product_id" INTEGER NOT NULL,
    "model_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "modelproduct_pk" PRIMARY KEY ("product_id","model_id")
);

-- AddForeignKey
ALTER TABLE "ModelProduct" ADD CONSTRAINT "modelProdcut_model_id" FOREIGN KEY ("model_id") REFERENCES "Model"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ModelProduct" ADD CONSTRAINT "modelProdcut_prodcut_id" FOREIGN KEY ("product_id") REFERENCES "Product"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
