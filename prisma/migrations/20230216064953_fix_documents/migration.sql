/*
  Warnings:

  - You are about to drop the column `product_id` on the `Document` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[document_id]` on the table `Profile` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[document_id]` on the table `Vendor` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateEnum
CREATE TYPE "DocumentTypeEnum" AS ENUM ('IMAGE', 'FILE');

-- DropForeignKey
ALTER TABLE "Document" DROP CONSTRAINT "product_id";

-- AlterTable
ALTER TABLE "Document" DROP COLUMN "product_id",
ADD COLUMN     "type" "DocumentTypeEnum" NOT NULL DEFAULT 'IMAGE';

-- AlterTable
ALTER TABLE "Product" ADD COLUMN     "document_id" INTEGER[];

-- AlterTable
ALTER TABLE "Profile" ADD COLUMN     "document_id" INTEGER;

-- AlterTable
ALTER TABLE "Vendor" ADD COLUMN     "document_id" INTEGER;

-- CreateIndex
CREATE UNIQUE INDEX "Profile_document_id_key" ON "Profile"("document_id");

-- CreateIndex
CREATE UNIQUE INDEX "Vendor_document_id_key" ON "Vendor"("document_id");
