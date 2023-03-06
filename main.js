const fs = require("fs");
const { getImageURLs, downloadImages } = require("./web");
const { getProducts, extendProducts } = require("./merlion");
const { url, categoryNames, filePath } = require("./constants");

async function main() {
  console.time('parsing')
  let products;
  try {
    const rawdata = fs.readFileSync("products.json");
    products = JSON.parse(rawdata);
    console.log(products.length);
  } catch (error) {
    products = await getProducts("files/merlion-price.csv", categoryNames);
    // products = await getImageURLs(products, url);
    // products = await downloadImages(products);

    // Сохранить в файл
    const data = JSON.stringify(products);
    fs.writeFileSync("products.json", data);
    console.log("Parsing completed!");
  }
  // products = await getImageURLs(products, url);
  products = await downloadImages(products);

  // const changedProducts = await getProducts(filePath, categoryNames);

  // products = await extendProducts(products, changedProducts);

  const data = JSON.stringify(products);
  fs.writeFileSync("products-all.json", data);
  console.log("Parsing completed!");
  console.timeEnd('parsing')
}

main();
