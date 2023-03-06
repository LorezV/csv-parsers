-- AlterTable
ALTER TABLE "CartProduct" ADD COLUMN     "supplier_id" INTEGER,
ADD CONSTRAINT "CartProduct_pkey" PRIMARY KEY ("cart_id", "product_id");

-- AddForeignKey
ALTER TABLE "CartProduct" ADD CONSTRAINT "CartProduct_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "Supplier"("id") ON DELETE SET NULL ON UPDATE CASCADE;
