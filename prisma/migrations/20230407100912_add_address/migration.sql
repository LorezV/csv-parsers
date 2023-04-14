-- CreateEnum
CREATE TYPE "AddressType" AS ENUM ('DELIVERY', 'WAREHOUSE');

-- CreateTable
CREATE TABLE "Address" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "supplier_id" INTEGER,
    "type" "AddressType" NOT NULL DEFAULT 'DELIVERY',
    "name" TEXT NOT NULL,
    "postcode" INTEGER,
    "country" TEXT NOT NULL,
    "region" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "street" TEXT NOT NULL,
    "house_number" INTEGER NOT NULL,
    "apartment_number_or_office" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "address_pk" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "address_id_uindex" ON "Address"("id");

-- AddForeignKey
ALTER TABLE "Address" ADD CONSTRAINT "user_id" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Address" ADD CONSTRAINT "supplier_id" FOREIGN KEY ("supplier_id") REFERENCES "Supplier"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
