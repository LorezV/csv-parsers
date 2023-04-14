-- CreateEnum
CREATE TYPE "DeliveryTypeEnum" AS ENUM ('USER', 'SUPPLIER');

-- AlterTable
ALTER TABLE "Supplier" ADD COLUMN     "array_of_delivery_ids" INTEGER[] DEFAULT ARRAY[]::INTEGER[],
ADD COLUMN     "currency_id" INTEGER,
ADD COLUMN     "deliver_goods_yourself" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "array_of_delivery_ids" INTEGER[] DEFAULT ARRAY[]::INTEGER[],
ADD COLUMN     "currency_id" INTEGER;

-- CreateTable
CREATE TABLE "Delivery" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "type" "DeliveryTypeEnum" NOT NULL,
    "parent_id" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Delivery_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Delivery_name_key" ON "Delivery"("name");

-- AddForeignKey
ALTER TABLE "Supplier" ADD CONSTRAINT "currency_id" FOREIGN KEY ("currency_id") REFERENCES "Currency"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Delivery" ADD CONSTRAINT "Delivery_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "Delivery"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "currency_id" FOREIGN KEY ("currency_id") REFERENCES "Currency"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
