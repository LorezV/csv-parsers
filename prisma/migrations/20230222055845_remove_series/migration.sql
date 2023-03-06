/*
  Warnings:

  - You are about to drop the column `series_id` on the `Model` table. All the data in the column will be lost.
  - You are about to drop the `Series` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "Model" DROP CONSTRAINT "model_series_id";

-- DropForeignKey
ALTER TABLE "Series" DROP CONSTRAINT "series_vendor_id";

-- AlterTable
ALTER TABLE "Model" DROP COLUMN "series_id",
ADD COLUMN     "vendor_id" INTEGER;

-- DropTable
DROP TABLE "Series";

-- AddForeignKey
ALTER TABLE "Model" ADD CONSTRAINT "model_vendor_id_fk" FOREIGN KEY ("vendor_id") REFERENCES "Vendor"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
