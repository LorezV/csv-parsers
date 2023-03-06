/*
  Warnings:

  - You are about to drop the column `vendor_id` on the `Model` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "Model" DROP CONSTRAINT "model_vendor_id";

-- AlterTable
ALTER TABLE "Model" DROP COLUMN "vendor_id",
ADD COLUMN     "series_id" INTEGER;

-- CreateTable
CREATE TABLE "Series" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "vendor_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Series_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Series_id_key" ON "Series"("id");

-- AddForeignKey
ALTER TABLE "Series" ADD CONSTRAINT "series_vendor_id" FOREIGN KEY ("vendor_id") REFERENCES "Vendor"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Model" ADD CONSTRAINT "model_series_id" FOREIGN KEY ("series_id") REFERENCES "Series"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
