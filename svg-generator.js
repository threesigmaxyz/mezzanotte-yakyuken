const fs = require("fs");
const ethers = require("ethers");

const numSVGs = 500;

const MAX_UINT256 = BigInt("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");

const images = [
  ["svgPaths/ami.svg", MAX_UINT256 * BigInt(1) / BigInt(5)],
  ["svgPaths/christine.svg", MAX_UINT256 * BigInt(1) / BigInt(5)],
  ["svgPaths/takechi.svg", MAX_UINT256 * BigInt(1) / BigInt(5)],
  ["svgPaths/tennisNew.svg", MAX_UINT256 * BigInt(1) / BigInt(5)],
  ["svgPaths/yak2.svg", MAX_UINT256 * BigInt(1) / BigInt(5)]
];

const backgroundColors = [
  ["brown", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["black", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["aquamarine", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["purple", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["orange", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["white", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["lime", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["red", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["blue", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["yellow", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["green", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["pink", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["coral", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["lavender", MAX_UINT256 * BigInt(1) / BigInt(14)]
];

const baseFillColors = [
  ["brown", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["black", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["aquamarine", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["purple", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["orange", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["white", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["lime", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["red", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["blue", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["yellow", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["green", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["pink", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["coral", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["lavender", MAX_UINT256 * BigInt(1) / BigInt(14)]
];

const initialShadowColors = [
  ["brown", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["black", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["aquamarine", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["purple", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["orange", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["white", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["lime", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["red", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["blue", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["yellow", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["green", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["pink", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["coral", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["lavender", MAX_UINT256 * BigInt(1) / BigInt(14)]
]

const finalShadowColors = [
  ["brown", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["black", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["aquamarine", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["purple", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["orange", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["white", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["lime", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["red", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["blue", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["yellow", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["green", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["pink", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["coral", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["lavender", MAX_UINT256 * BigInt(1) / BigInt(14)]
]

const glowTimes = [ 
  ["0.3", MAX_UINT256 * BigInt(1) / BigInt(3)], 
  ["2", MAX_UINT256 * BigInt(1) / BigInt(3)], 
  ["9", MAX_UINT256 * BigInt(1) / BigInt(3)] 
]

const yakFillColors = [
  ["brown", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["black", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["aquamarine", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["purple", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["orange", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["white", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["lime", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["red", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["blue", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["yellow", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["green", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["pink", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["coral", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["lavender", MAX_UINT256 * BigInt(1) / BigInt(14)]
];

const hoverColors = [
  ["brown", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["black", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["aquamarine", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["purple", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["orange", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["white", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["lime", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["red", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["blue", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["yellow", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["green", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["pink", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["coral", MAX_UINT256 * BigInt(1) / BigInt(14)],
  ["lavender", MAX_UINT256 * BigInt(1) / BigInt(14)]
];

const textLocations = [ 
  ['"start" x="5%" y="10%"', MAX_UINT256 * BigInt(1) / BigInt(4)], 
  ['"end" x="95%" y="90%"', MAX_UINT256 * BigInt(1) / BigInt(4)], 
  ['"end" x="95%" y="10%"', MAX_UINT256 * BigInt(1) / BigInt(4)], 
  ['"start" x="5%" y="90%"', MAX_UINT256 * BigInt(1) / BigInt(4)] 
];


const texts = [ 
  ["石", MAX_UINT256 * BigInt(1) / BigInt(3)], 
  ["紙", MAX_UINT256 * BigInt(1) / BigInt(3)], 
  ["はさみ", MAX_UINT256 * BigInt(1) / BigInt(3)] 
];

// Helpers
const imageToViewBox = { "svgPaths/ami.svg": "0 0 300 500", "svgPaths/christine.svg": "0 0 500 470", "svgPaths/takechi.svg": "0 0 700 800", "svgPaths/tennisNew.svg": "0 0 400 370", "svgPaths/yak2.svg": "0 0 230 300" };
const imageToFontSize = { "svgPaths/ami.svg": "36", "svgPaths/christine.svg": "36", "svgPaths/takechi.svg": "60", "svgPaths/tennisNew.svg": "14", "svgPaths/yak2.svg": "20" };

let attributes = [];
let collisions = {};
let imagesGenerated = { "svgPaths/ami.svg": 0, "svgPaths/christine.svg": 0, "svgPaths/takechi.svg": 0, "svgPaths/tennisNew.svg": 0, "svgPaths/yak2.svg": 0 };
let backgroundColorsGenerated = { "brown": 0, "black": 0, "aquamarine": 0, "red": 0, "blue": 0, "yellow": 0, "green": 0, "pink": 0, "coral": 0, "lavender": 0, "purple": 0, "orange": 0, "white": 0, "lime": 0 };
let baseFillColorsGenerated = { "brown": 0, "black": 0, "aquamarine": 0, "red": 0, "blue": 0, "yellow": 0, "green": 0, "pink": 0, "coral": 0, "lavender": 0, "purple": 0, "orange": 0, "white": 0, "lime": 0 };
let yakFillColorsGenerated = { "brown": 0, "black": 0, "aquamarine": 0, "red": 0, "blue": 0, "yellow": 0, "green": 0, "pink": 0, "coral": 0, "lavender": 0, "purple": 0, "orange": 0, "white": 0, "lime": 0 };
let hoverColorsGenerated = { "brown": 0, "black": 0, "aquamarine": 0, "red": 0, "blue": 0, "yellow": 0, "green": 0, "pink": 0, "coral": 0, "lavender": 0, "purple": 0, "orange": 0, "white": 0, "lime": 0 };
let initialShadowColorsGenerated = { "brown": 0, "black": 0, "aquamarine": 0, "red": 0, "blue": 0, "yellow": 0, "green": 0, "pink": 0, "coral": 0, "lavender": 0, "purple": 0, "orange": 0, "white": 0, "lime": 0 };
let finalShadowColorsGenerated = { "brown": 0, "black": 0, "aquamarine": 0, "red": 0, "blue": 0, "yellow": 0, "green": 0, "pink": 0, "coral": 0, "lavender": 0, "purple": 0, "orange": 0, "white": 0, "lime": 0 };
let textsGenerated = { "石": 0, "紙": 0, "はさみ": 0 };
let textLocationsGenerated = { '"start" x="5%" y="10%"': 0, '"end" x="95%" y="90%"': 0, '"end" x="95%" y="10%"': 0, '"start" x="5%" y="90%"': 0 };
let glowTimesGenerated = { "0.3": 0, "2": 0, "9": 0 };

let seed;
for (let currentSVG = 1; currentSVG <= numSVGs; currentSVG++) {
  seed = BigInt(currentSVG);

  const image = getTrait(images);
  const backgroundColor = getTrait(backgroundColors);
  const initialShadowColor = getTrait(initialShadowColors);
  const finalShadowColor = getTrait(finalShadowColors);
  const baseFillColor = getTrait(baseFillColors);
  const glowTime = getTrait(glowTimes);
  const yakFillColor = getTrait(yakFillColors);
  const hoverColor = getTrait(hoverColors);
  const textLocation = getTrait(textLocations);
  const text = getTrait(texts);

  attributes.push([image, backgroundColor, baseFillColor, yakFillColor, hoverColor, initialShadowColor, finalShadowColor, text, textLocation, glowTime]);

  imagesGenerated[image] = 1 + imagesGenerated[image];
  backgroundColorsGenerated[backgroundColor] = 1 + backgroundColorsGenerated[backgroundColor];
  baseFillColorsGenerated[baseFillColor] = 1 + baseFillColorsGenerated[baseFillColor];
  yakFillColorsGenerated[yakFillColor] = 1 + yakFillColorsGenerated[yakFillColor];
  hoverColorsGenerated[hoverColor] = 1 + hoverColorsGenerated[hoverColor];
  initialShadowColorsGenerated[initialShadowColor] = 1 + initialShadowColorsGenerated[initialShadowColor];
  finalShadowColorsGenerated[finalShadowColor] = 1 + finalShadowColorsGenerated[finalShadowColor];
  textsGenerated[text] = 1 + textsGenerated[text];
  textLocationsGenerated[textLocation] = 1 + textLocationsGenerated[textLocation];
  glowTimesGenerated[glowTime] = 1 + glowTimesGenerated[glowTime];

  let idx = image + backgroundColor + baseFillColor + yakFillColor + hoverColor + initialShadowColor + finalShadowColor + text + textLocation + glowTime;
  if (collisions[idx]) throw("collision detected!")
  collisions[idx] = true;

  // read the SVG file as a string
  const svgPath = fs.readFileSync(image, 'utf8');

  let svg = `<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet" viewBox="${imageToViewBox[image]}" style="background-color:${backgroundColor}">
              <style>
                  @keyframes glow {
                      0% {
                          filter: drop-shadow(16px 16px 20px ${initialShadowColor}) brightness(100%);
                      }

                      to {
                          filter: drop-shadow(16px 16px 20px ${finalShadowColor}) brightness(200%);
                      }
                  }

                  path {
                      fill: ${baseFillColor};
                      animation: glow ${glowTime}s ease-in-out infinite alternate
                  }

                  .yak {
                      fill: ${yakFillColor};
                  }

                  .yak:hover {
                      fill: ${hoverColor};
                  }
              </style>  
              ${svgPath}
              <text text-anchor=${textLocation} font-family="Helvetica" font-size="${imageToFontSize[image]}" fill="white">${text}</text>
            </svg>`;

  fs.writeFileSync(`generatedSVGs/${currentSVG}.svg`, svg);
}

function getTrait(traitWeights) {
  seed = BigInt(ethers.solidityPackedKeccak256(["uint256"], [seed.toString()]));
  let accumulator = BigInt(0);
  for (var i = 0; i < traitWeights.length; i++) {
    const [trait, weight] = traitWeights[i];
    accumulator += weight;
    if (accumulator >= seed) {
      return trait;
    }
  }
  return traitWeights[traitWeights.length - 1];
}

function logProbabilities(traitCounts, numSVGs, trait) {
  console.log("\n" + trait);
  for (const [trait, count] of Object.entries(traitCounts)) {
    console.log(`${trait}: ${count / numSVGs}`);
  }
}

logProbabilities(backgroundColorsGenerated, numSVGs, "backgroundColors");
logProbabilities(baseFillColorsGenerated, numSVGs, "baseFillColors");
logProbabilities(yakFillColorsGenerated, numSVGs, "yakFillColors");
logProbabilities(hoverColorsGenerated, numSVGs, "hoverColors");
logProbabilities(initialShadowColorsGenerated, numSVGs, "initialShadowColors");
logProbabilities(finalShadowColorsGenerated, numSVGs, "finalShadowColors");
logProbabilities(textsGenerated, numSVGs, "texts");
logProbabilities(textLocationsGenerated, numSVGs, "textLocations");
logProbabilities(glowTimesGenerated, numSVGs, "glowTimes");
logProbabilities(imagesGenerated, numSVGs, "images");
