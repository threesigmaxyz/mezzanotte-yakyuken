# Mezzanotte Yakyuken Benchmarks [![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gha]: https://github.com/threesigmaxyz/foundry-template/actions
[gha-badge]: https://github.com/threesigmaxyz/foundry-template/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

A Proof of Concept for on chain nfts.

Gas costs estimation

|     svg     |   size   | gas cost ETH per 10 gwei of gas price |
|:-----------:|:--------:|:-------------------------------------:|
|   contract  |    -     |                 0.074                 |
|     ami     |  5.81 kB |                 0.013                 |
|  christine  |  4.61 kB |                 0.010                 |
|   takechi   |  17.4 kB |                 0.038                 |
|    tennis   |  47.2 kB |                 0.110                 |
|     yak     |  5.20 kB |                 0.012                 |
|    total    |    -     |                 0.257                 |

Considering a gas cost of 70 gwei / gas (current price)

|     svg     |   size   | gas cost ETH per 70 gwei of gas price |
|:-----------:|:--------:|:-------------------------------------:|
|   contract  |    -     |                 0.518                 |
|     ami     |  5.81 kB |                 0.091                 |
|  christine  |  4.61 kB |                 0.070                 |
|   takechi   |  17.4 kB |                 0.266                 |
|    tennis   |  47.2 kB |                 0.770                 |
|     yak     |  5.20 kB |                 0.084                 |
|    total    |    -     |                 1.799                 |


## Getting Started

```sh
git clone git@github.com:threesigmaxyz/mezzanotte-yakyuken-benchmarks.git
cd mezzanotte-yakyuken-benchmarks
make update
make install
```

## Usage

### Generate all svg combinations

```
node svg-generator.js
```

Files will be inside `generatedSVGs`.

### Generate all svg combinations to html files

```
node html-generator.js
```

Files will be inside `generatedHTMLs`.

### Generate tokenURIs 
```
make tests
```

TokenURIs will be inside `generatedTokenURIs`. Copy the text in a tokenURI file into a browser, it should be a regular NFT.

# About Us
[Three Sigma](https://threesigma.xyz/) is a venture builder firm focused on blockchain engineering, research, and investment. Our mission is to advance the adoption of blockchain technology and contribute towards the healthy development of the Web3 space.

If you are interested in joining our team, please contact us [here](mailto:info@threesigma.xyz).

---

<p align="center">
  <img src="https://threesigma.xyz/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Fthree-sigma-labs-research-capital-white.0f8e8f50.png&w=2048&q=75" width="75%" />
</p>
