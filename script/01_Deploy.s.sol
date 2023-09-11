// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "@forge-std/Script.sol";
import { stdJson } from "@forge-std/StdJson.sol";

import { Strings } from "@openzeppelin/utils/Strings.sol";

import { ZipUtils } from "../common/ZipUtils.sol";
import { Yakyuken } from "../src/Yakyuken.sol";
import { ZLib } from "../src/zip/ZLib.sol";

contract Deploy is Script {
    using Strings for uint256;
    using stdJson for string;

    bytes[] private _images = new bytes[](9);
    uint128[] private _decompressedSizes = new uint128[](9);
    bytes private _metadataDetails;

    function setUp() public {
        // Read JSON config data.
        string memory root_ = vm.projectRoot();
        string memory configPath_ = string.concat(root_, "/test/yakyuken.config.json");
        string memory configData_ = vm.readFile(configPath_);

        // Parse JSON config data.
        _metadataDetails = configData_.parseRaw(".metadata");
        // TODO Yakyuken.Metadata memory metadata_ = abi.decode(metadataDetails_, (Yakyuken.Metadata));

        // Load SVG files.
        (_images[0], _decompressedSizes[0]) = _loadImage("/svgPaths/v3/ami.svg", "0 0 300 500", "36", "Ami");
        (_images[1], _decompressedSizes[1]) = _loadImage("/svgPaths/v3/christine.svg", "0 0 500 470", "36", "Christine");
        (_images[2], _decompressedSizes[2]) = _loadImage("/svgPaths/v3/takechi.svg", "0 0 700 800", "60", "Takechi");
        (_images[3], _decompressedSizes[3]) = _loadImage("/svgPaths/v3/tennis.svg", "0 0 320 210", "210", "Tennis");
        (_images[4], _decompressedSizes[4]) = _loadImage("/svgPaths/v3/yak2.svg", "0 0 230 300", "20", "Yakyuken");

        //(_images[5], _decompressedSizes[5]) = _loadImage("/svgPaths/v3/focusedgirl.svg", "0 0 300 500", "36", "Focused Girl");
        //(_images[6], _decompressedSizes[6]) = _loadImage("/svgPaths/v3/josei.svg", "0 0 300 500", "36", "Josei");
        //(_images[6], _decompressedSizes[6]) = _loadImage("/svgPaths/v3/redlady.svg", "0 0 300 500", "36", "Red Lady");
        //(_images[7], _decompressedSizes[7]) = _loadImage("/svgPaths/v3/sport.svg", "0 0 300 500", "36", "Sport");
    }

    /// @dev You can send multiple transactions inside a single script.
    function run() public {
        vm.startBroadcast();

        // Deploy Yakyuken contract with ZLib compression.
        Yakyuken _yakyuken = new Yakyuken(address(new ZLib()));

        // Deploy SVG files.
        _yakyuken.initialize(_metadataDetails, _images, _decompressedSizes);

        vm.stopBroadcast();
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

    function _loadSVG(string memory path_) internal returns (string memory svg_) {
        string memory root_ = vm.projectRoot();
        string memory imagePath_ = string.concat(root_, path_);
        svg_ = vm.readFile(imagePath_);
    }
}
