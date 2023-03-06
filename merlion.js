const fs = require("fs");
const papa = require("papaparse");
const iconv = require("iconv-lite");

async function getProducts(fileName, categoryNames) {
  const file = fs
    .createReadStream(fileName)
    .pipe(iconv.decodeStream("UTF-8"))
    .pipe(iconv.encodeStream("UTF-8"));

  const allProducts = [];
  const products = [];

  return await new Promise((resolve) => {
    papa.parse(file, {
      // preview: 10,
      // dynamicTyping: true,
      skipEmptyLines: true,
      worker: true,
      step: (result) => {
        for(const categoryName of categoryNames){
          if (result.data[0] == categoryName) {
            allProducts.push({
              brand: result.data[3],
              partNumber: result.data[4],
              vendorPartNumber: result.data[6],
              title: result.data[7].slice(0, 300),
              price: parseFloat(result.data[10].replace(/,/, '.')),
              category1: categoryName,
              category2: result.data[1],
              category3: result.data[2]
            });
          }
        }
      },
      complete: () => {
        for (const category of categoryNames) {
          let count = 0;
          for (const product of allProducts) {
            if (product.category1 === category) {
              products.push(product);
              count++;
            };
          };
          console.log(category, count)
        };
        console.log('.csv file parsed')
        resolve(true);
      },
    });
  }).then(() => products)
};

async function extendProducts(products, changedProducts) {
  return await Promise.all(products.map((product) => {
    for (const changedProduct of changedProducts) {
      if (changedProduct.partNumber == product.partNumber) {
        product.vendorPartNumber = changedProduct.vendorPartNumber
        product.category1 = changedProduct.category1
        product.category2 = changedProduct.category2
        product.category3 = changedProduct.category3
      };
    };
  })).then(() => products);
};

module.exports = {
  getProducts,
  extendProducts
};
