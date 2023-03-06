const puppeteer = require("puppeteer");
const fakeUserAgents = require("./UserAgents");
const download = require("image-downloader");
const { imagePath } = require("./constants");

function* sliceIntoChunks(arr, chunkSize) {
  for (let i = 0; i < arr.length; i += chunkSize) {
    yield arr.slice(i, i + chunkSize);
  }
}

async function getImageURLs(products, url) {
  const chunks = sliceIntoChunks(products, 50);
  // const browser = await puppeteer.launch({ headles: false });
  const browser = await puppeteer.launch();
  let count = 0;
  for (const chunk of chunks) {
    await Promise.all(
      chunk.map(async (product) => {
        const page = await browser.newPage();
        await page.setUserAgent(
          fakeUserAgents[Math.floor(Math.random() * fakeUserAgents.length)]
        );
        await page.setViewport({ width: 1980, height: 1080 });
        await page.goto(url + product.partNumber, { waitUntil: "load", timeout: 0 });

        const imageURLs = await page.evaluate(() => {
          return [
            ...document.querySelectorAll("#productCardPhotoGallery a img"),
          ].map((anchor) => anchor.src);
        });

        await page.close();

        product.imageURLs = [];
        if (imageURLs) {
          product.imageURLs = imageURLs;
        };
      })
    );
    count++;
    console.log("Part:", count, "completed!");
  }
  await browser.close();
  return products;
}

async function downloadImages(products) {
  const chunks = sliceIntoChunks(products, 100);
  let count = 0;
  for (const chunk of chunks) {
    await Promise.all(chunk.map(async (product) => {
      product.images = [];
      if (product.imageURLs) {
        for (const imageURL of product.imageURLs) {
          let file;
          // Попытка получить картинку с наилучшим разрешением
          try {
            file = await download.image({
              url: imageURL.replace(/\_m/, "_b"),
              dest: imagePath,
            });
          } catch (error) {};

          if (!file) {
            try {
              file = await download.image({
                url: imageURL,
                dest: imagePath,
              });
            } catch (error) {
              console.log(error)
              file = { filename: '' };
            }
          };

          const filename = file.filename.split("/").at(-1);
          product.images.push({
            url: '/img/' + filename,
            name: filename 
          });
        };
      }
    }));
    count++;
    console.log("Image part:", count, "completed!");
  };
  return products;
}

async function fixImages(products) {
  await Promise.all(products.map((product)=> {
    product.images = [];
    for (const imageURL of product.imageURLs) {
      const filename = imageURL.split('/').at(-1)
      product.images.push({
        url: '/images/' + filename,
        name: filename 
      });
    }
  }));
  return products;
}

module.exports = {
  getImageURLs,
  downloadImages,
  fixImages
};
