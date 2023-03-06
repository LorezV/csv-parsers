const fs = require("fs")
const path = require("path")
const { v4: uuidv4 } = require("uuid");
const download = require("image-downloader");

function getUserAgent() {
    const agents = [
        'Mozilla/5.0 (Linux; Android 12; LM-K420 Build/SKQ1.211103.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/107.0.5304.105 Mobile Safari/537.36 [FB_IAB/FB4A;FBAV/393.0.0.35.106;]',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9',
        'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36',
        'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1',
        'Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10_44_91) AppleWebKit/532.85.32 (KHTML, like Gecko) Chrome/56.2.7371.2009 Safari/533.24 Edge/36.19219',
        'Mozilla/5.0 (Linux; Android 7.0; Pixel C Build/NRD90M; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/52.0.2743.98 Safari/537.36',
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
        'Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1',
        'Mozilla/5.0 (iPhone13,2; U; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Mobile/15E148 Safari/602.1',
        'Mozilla/5.0 (iPhone14,3; U; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Mobile/19A346 Safari/602.1',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4182.0 Safari/537.36',
    ]
    return agents[Math.floor(Math.random() * agents.length)]
}

function createLogger() {
    try {
        const date = new Date()
        const dest = path.join(__dirname, "../", "logs", `${date.toDateString()} ${date.toLocaleTimeString().replace(":", ".").replace(":", ".")}.txt`)
        function logger(data) {
            const date = new Date()
            data = `[${date.toDateString()} ${date.toLocaleTimeString()}] ` + data + "\n"
            fs.appendFileSync(dest, data)
        }
        logger("Logger successfuly created.")
        return logger
    } catch (e) {
        console.error(e)
        logger(e)
        return console.log
    }
}

async function downloadImage(dir, url) {
    let file
    try {
      file = await download.image({ url: url, dest: path.join(dir, `${uuidv4().replace(/-/g, "")}.jpg`) });
    } catch (error) {
      console.error(error);
      logger(error)
      file = { filename: "" };
    }
  
    const filename = file.filename.split("\\").pop();
    return { name: filename, localURL: "/static/img/" + filename }
  }

module.exports = {
    getUserAgent,
    createLogger,
    downloadImage
}