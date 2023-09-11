const fs = require("fs");

const images = [
  "svg/baby.svg",
  "svg/tennisNew.svg",
  "svg/tennis2.svg",
  "svg/yakyuken.svg",
  "svg/takechi.svg",
  "svg/christine.svg",
  "svg/alice.svg",
];

const colors = [
  "white",
  "black",
  "aquamarine",
  "red",
  "blue",
  "yellow",
  "green",
];

const texts = ["石", "紙", "はさみ"];

let currentSVG = 1;
const numSVGs = colors.length * images.length * texts.length;

let attributes = [];

for (let i = 1; i <= numSVGs; i++) {
  const image = images[Math.floor((i-1) / (colors.length * texts.length))];
  const imageRemainder = (i-1) % (colors.length * texts.length);
  const bgColor = colors[Math.floor(imageRemainder / texts.length)];
  const bgColorRemainder = imageRemainder % texts.length;
  const text = texts[bgColorRemainder];
  
  attributes.push([image, bgColor, text]);

  // read the SVG file as a string
  const svgData = fs.readFileSync(image, 'utf8');

  // convert the SVG data to a Base64 data URI
  const base64Data = Buffer.from(svgData).toString('base64');
  const imageDataUri = `data:image/svg+xml;charset=utf-8;base64,${base64Data}`;


  let html = `<!DOCTYPE html>
  <html>
  <head>
    <title>Page ${i}</title>
    <meta property="text" content="${
      text
    }">
  </head>
  <body style="background-color: ${bgColor};">
    <object data="${
      imageDataUri
    }" type="image/svg+xml" id="svg232" style="overflow: hidden; width: 900px; height: 800px; object-fit: contain;">
    </object>
    </body>
    </html>`;

  fs.writeFileSync(`generatedHTMLs/${currentSVG++}.html`, html);
}

console.log(attributes);
