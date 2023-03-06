/*
  Warnings:

  - You are about to drop the column `document_id` on the `Profile` table. All the data in the column will be lost.
  - You are about to drop the column `supplier_id` on the `Profile` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[userName]` on the table `User` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[document_id]` on the table `User` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[supplier_id]` on the table `User` will be added. If there are existing duplicate values, this will fail.
  - Made the column `name` on table `User` required. This step will fail if there are existing NULL values in that column.

*/
-- DropForeignKey
ALTER TABLE "Profile" DROP CONSTRAINT "supplier_id";

-- DropIndex
DROP INDEX "Profile_document_id_key";

-- DropIndex
DROP INDEX "Profile_supplier_id_key";

-- AlterTable
ALTER TABLE "Profile" DROP COLUMN "document_id",
DROP COLUMN "supplier_id";

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "document_id" INTEGER,
ADD COLUMN     "supplier_id" INTEGER,
ADD COLUMN     "userName" TEXT,
ALTER COLUMN "name" SET NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "User_userName_key" ON "User"("userName");

-- CreateIndex
CREATE UNIQUE INDEX "User_document_id_key" ON "User"("document_id");

-- CreateIndex
CREATE UNIQUE INDEX "User_supplier_id_key" ON "User"("supplier_id");

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "supplier_id" FOREIGN KEY ("supplier_id") REFERENCES "Supplier"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
