-- CreateTable
CREATE TABLE "Currency" (
    "id" SERIAL NOT NULL,
    "name" CHAR(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Currencies_pk" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CurrencyRate" (
    "id" INTEGER NOT NULL,
    "rate" DOUBLE PRECISION,
    "date" TIMESTAMP(6) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "currencyrate_pk" PRIMARY KEY ("id","date")
);

-- CreateTable
CREATE TABLE "Description" (
    "id" SERIAL NOT NULL,
    "text" CHAR(1000) NOT NULL,
    "language_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Descriptions_pk" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Document" (
    "id" SERIAL NOT NULL,
    "url" CHAR(100) NOT NULL,
    "name" CHAR(20) NOT NULL,
    "product_id" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Documents_pk" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Language" (
    "id" SERIAL NOT NULL,
    "language" CHAR(25) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Language_pk" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Model" (
    "id" SERIAL NOT NULL,
    "name" CHAR(200) NOT NULL,
    "vendor_id" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Models_pk" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Product" (
    "id" SERIAL NOT NULL,
    "vendor_id" INTEGER,
    "model_id" INTEGER,
    "vendor_partnumber" CHAR(100) NOT NULL,
    "name" CHAR(300) NOT NULL,
    "description_id" INTEGER,
    "description" CHAR(1000),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Products_pk" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Supplier" (
    "id" SERIAL NOT NULL,
    "name" CHAR(50) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Suppliers_pk" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SupplierProductPrice" (
    "product_id" INTEGER NOT NULL,
    "supplier_id" INTEGER NOT NULL,
    "price_date" TIMESTAMP(6) NOT NULL,
    "price" DOUBLE PRECISION,
    "currency_id" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "supplierproductprice_pk" PRIMARY KEY ("product_id","supplier_id","price_date")
);

-- CreateTable
CREATE TABLE "User" (
    "id" SERIAL NOT NULL,
    "name" CHAR(50),
    "email" CHAR(50) NOT NULL,
    "password" CHAR(60) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "user_pk" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Vendor" (
    "id" SERIAL NOT NULL,
    "name" CHAR(200) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Vendors_pk" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Cart" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Cart_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Cart_product" (
    "cart_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Cart_product_pkey" PRIMARY KEY ("cart_id","product_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Currencies_currency_id_key" ON "Currency"("id");

-- CreateIndex
CREATE UNIQUE INDEX "Descriptions_description_id_key" ON "Description"("id");

-- CreateIndex
CREATE UNIQUE INDEX "Documents_image_id_key" ON "Document"("id");

-- CreateIndex
CREATE UNIQUE INDEX "Language_language_id_key" ON "Language"("id");

-- CreateIndex
CREATE UNIQUE INDEX "Models_model_id_key" ON "Model"("id");

-- CreateIndex
CREATE UNIQUE INDEX "Products_product_id_key" ON "Product"("id");

-- CreateIndex
CREATE UNIQUE INDEX "Suppliers_supplier_id_key" ON "Supplier"("id");

-- CreateIndex
CREATE UNIQUE INDEX "user_id_uindex" ON "User"("id");

-- CreateIndex
CREATE UNIQUE INDEX "user_email_uindex" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "Vendors_vendor_id_key" ON "Vendor"("id");

-- CreateIndex
CREATE UNIQUE INDEX "Vendors_vendor_name_key" ON "Vendor"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Cart_id_user_id_key" ON "Cart"("id", "user_id");

-- AddForeignKey
ALTER TABLE "CurrencyRate" ADD CONSTRAINT "currency_id" FOREIGN KEY ("id") REFERENCES "Currency"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Description" ADD CONSTRAINT "description_language_id" FOREIGN KEY ("language_id") REFERENCES "Language"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Document" ADD CONSTRAINT "product_id" FOREIGN KEY ("product_id") REFERENCES "Product"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Model" ADD CONSTRAINT "model_vendor_id" FOREIGN KEY ("vendor_id") REFERENCES "Vendor"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Product" ADD CONSTRAINT "product_description_id_fk" FOREIGN KEY ("description_id") REFERENCES "Description"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Product" ADD CONSTRAINT "product_model_id_fk" FOREIGN KEY ("model_id") REFERENCES "Model"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Product" ADD CONSTRAINT "product_vendor_id_fk" FOREIGN KEY ("vendor_id") REFERENCES "Vendor"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SupplierProductPrice" ADD CONSTRAINT "currency_id" FOREIGN KEY ("currency_id") REFERENCES "Currency"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SupplierProductPrice" ADD CONSTRAINT "product_id" FOREIGN KEY ("product_id") REFERENCES "Product"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SupplierProductPrice" ADD CONSTRAINT "supplier_id" FOREIGN KEY ("supplier_id") REFERENCES "Supplier"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Cart" ADD CONSTRAINT "Cart_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Cart_product" ADD CONSTRAINT "Cart_product_cart_id_fkey" FOREIGN KEY ("cart_id") REFERENCES "Cart"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Cart_product" ADD CONSTRAINT "Cart_product_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "Product"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
