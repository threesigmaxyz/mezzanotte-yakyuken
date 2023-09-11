// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@forge-std/Test.sol";
import { console2 } from "@forge-std/console2.sol";
import { stdJson } from "@forge-std/StdJson.sol";

import { Strings } from "@openzeppelin/utils/Strings.sol";

import { ZipUtils } from "../common/ZipUtils.sol";

import { Yakyuken } from "../src/Yakyuken.sol";
import { ZLib } from "../src/zip/ZLib.sol";

contract YakyukenTests is Test {
    using Strings for uint256;
    using stdJson for string;

    Yakyuken private _yakyuken;

    function _loadSVG(string memory path_) internal returns (string memory svg_) {
        string memory root_ = vm.projectRoot();
        string memory imagePath_ = string.concat(root_, path_);
        svg_ = vm.readFile(imagePath_);
    }

    function _loadImage(
        string memory path_,
        string memory viewBox_,
        string memory fontSize_,
        string memory name_
    ) internal returns (bytes memory compressedImage_, uint128 decompressedSize_) {
        bytes memory image_ = abi.encode(Yakyuken.Image(_loadSVG(path_), viewBox_, fontSize_, name_));
        compressedImage_ = ZipUtils.zip(image_);
        decompressedSize_ = uint128(image_.length);
    }

    function setUp() external {
        _yakyuken = new Yakyuken(address(new ZLib()));

        // READ JSON CONFIG DATA
        string memory root_ = vm.projectRoot();
        string memory configPath_ = string.concat(root_, "/test/yakyuken.config.json");
        string memory configData_ = vm.readFile(configPath_);

        bytes memory metadataDetails_ = configData_.parseRaw(".metadata");
        Yakyuken.Metadata memory metadata_ = abi.decode(metadataDetails_, (Yakyuken.Metadata));

        bytes[] memory images_ = new bytes[](5);
        uint128[] memory decompressedSizes_ = new uint128[](5);
        (images_[0], decompressedSizes_[0]) = _loadImage("/svgPaths/v3/focusedgirl.svg", "0 0 300 500", "36", "Ami");
        (images_[1], decompressedSizes_[1]) = _loadImage("/svgPaths/christine.svg", "0 0 500 470", "36", "Christine");
        (images_[2], decompressedSizes_[2]) = _loadImage("/svgPaths/takechi.svg", "0 0 700 800", "60", "Takechi");
        (images_[3], decompressedSizes_[3]) = _loadImage("/svgPaths/tennisNew.svg", "0 0 320 210", "210", "Tennis");
        (images_[4], decompressedSizes_[4]) = _loadImage("/svgPaths/yak2.svg", "0 0 230 300", "20", "Yakyuken");

        // TODO read from json
        //Yakyuken.Metadata memory metadata_ = Yakyuken.Metadata({});

        _yakyuken.initialize(metadataDetails_, images_, decompressedSizes_);
    }

    function test_ok() external {

    }

    /*function test_metadata() external {
        for (uint256 i_; i_ < 10; i_++) {
            string memory svg_ = _yakyuken.readSVG(i_);
            vm.writeFile(
                string(abi.encodePacked("generatedSVGs/solidity/", Strings.toString(i_), ".svg")),
                svg_);
        }
    }*/
}