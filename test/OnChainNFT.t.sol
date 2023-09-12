// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import { Test } from "@forge-std/Test.sol";
import { console } from "@forge-std/console.sol";

import { Base64 } from "@openzeppelin/utils/Base64.sol";
import { Strings } from "@openzeppelin/utils/Strings.sol";

import { SSTORE2 } from "@solmate/src/utils/SSTORE2.sol";

import { OnChainNFT } from "src/OnChainNFT.sol";

import { Helpers } from "common/Helpers.sol";

import { Base64 as Base64v2 } from "@base64WithDecode/base64.sol";

contract OnChainNFTTests is Test {
    using Strings for uint256;

    OnChainNFT onChainNFT;

    function testGenerateURIs() public {
        _setUpOnChainContract();
        uint256 numNFTsToGenerate_ = 2;

        for (uint256 i = 1; i <= numNFTsToGenerate_; i++) {
            string memory svg_ = onChainNFT.tokenURI(i);
            vm.writeFile(string(abi.encodePacked("generatedTokenURIs/tokenURI", i.toString())), svg_);
        }
    }

    function testConstructorOnly() public {
        (bytes[] memory images_, uint256[] memory weights_) = Helpers.getImagesAndWeights();

        uint256 gasLeft = gasleft();
        onChainNFT = new OnChainNFT(Helpers.getEncodedTraits());
        console.log("constructor gas cost: ", gasLeft - gasleft());
    }

    function testGeneratedURIsToSvgGenerator1_125_SkipCI() public {
        _setUpOnChainContract();

        for (uint256 i_ = 1; i_ <= 125; i_++) {
            // total outputs = 500
            console.log("Checking image: ", i_);
            _compareOutputFromId(i_);
        }
    }

    function testGeneratedURIsToSvgGenerator126_250_SkipCI() public {
        _setUpOnChainContract();

        for (uint256 i_ = 126; i_ <= 250; i_++) {
            // total outputs = 500
            console.log("Checking image: ", i_);
            _compareOutputFromId(i_);
        }
    }

    function testGeneratedURIsToSvgGenerator251_375_SkipCI() public {
        _setUpOnChainContract();

        for (uint256 i_ = 251; i_ <= 375; i_++) {
            // total outputs = 500
            console.log("Checking image: ", i_);
            _compareOutputFromId(i_);
        }
    }

    function testGeneratedURIsToSvgGenerator376_500_SkipCI() public {
        _setUpOnChainContract();

        for (uint256 i_ = 376; i_ <= 500; i_++) {
            // total outputs = 500
            console.log("Checking image: ", i_);
            _compareOutputFromId(i_);
        }
    }

    function testBase64Encode() public {
        // Encode
        string memory var1_ = "svg-generated-image";
        string memory output_ = Base64.encode(bytes(var1_));

        // Decode
        string memory var2_ = Base64v2.decode(output_);

        //Assert they are equal
        assertEq(var1_, var2_);
    }

    function _setUpOnChainContract() internal {
        (bytes[] memory images_, uint256[] memory weights_) = Helpers.getImagesAndWeights();

        uint256 gasLeft = gasleft();
        onChainNFT = new OnChainNFT(Helpers.getEncodedTraits());
        console.log("constructor gas cost: ", gasLeft - gasleft());

        Helpers.upload(images_[0], "ami", weights_[0], onChainNFT);
        Helpers.upload(images_[1], "christine", weights_[1], onChainNFT);
        Helpers.upload(images_[2], "takechi", weights_[2], onChainNFT);
        Helpers.upload(images_[3], "tennisTest1", weights_[3], onChainNFT);
        Helpers.upload(images_[4], "yak2", weights_[4], onChainNFT);
    }

    function _getGeneratedSVG(uint256 tokenId_) internal view returns (bytes memory) {
        // Rebuild image with the given token id
        (OnChainNFT.Image memory image_, uint256 seed_) = onChainNFT.rebuildImage(tokenId_);

        // Return the generated output
        return (onChainNFT.generateSVG(seed_, image_));
    }

    function _compareOutputFromId(uint256 currentTokenId_) internal {
        // Fetch generated svg with the contract code
        bytes memory contractSvg_ = _getGeneratedSVG(currentTokenId_);

        // Fetch generated svg with the svg generator
        bytes memory svgGeneratorSvg_ =
            bytes(vm.readFile(string.concat(string.concat("generatedSVGs/", currentTokenId_.toString()), ".svg")));

        // Prepare output to run script
        string[] memory inputs = new string[](4);
        inputs[0] = "node";
        inputs[1] = "test/compareStrings.js";
        inputs[2] = string(contractSvg_);
        inputs[3] = string(svgGeneratorSvg_);

        // Run script
        bytes memory res = vm.ffi(inputs);

        // Assert outputd
        assertEq(string(res), "true");
    }
}
