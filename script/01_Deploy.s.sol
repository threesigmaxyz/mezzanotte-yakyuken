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
    bytes[] private _icons = new bytes[](4);
    uint128[] private _decompressedSizesIcons = new uint128[](4);
    bytes private _metadataDetails;
    bytes[] private _infoArray;

    function setUp() public {
        // Read JSON config data.
        string memory root_ = vm.projectRoot();
        string memory configPath_ = string.concat(root_, "/test/yakyuken.config.json");
        string memory configData_ = vm.readFile(configPath_);

        // Parse JSON config data.
        _metadataDetails = configData_.parseRaw(".metadata");
        // TODO Yakyuken.Metadata memory metadata_ = abi.decode(metadataDetails_, (Yakyuken.Metadata));

        // Load SVG files.
        /*(_images[0], _decompressedSizes[0]) = _loadImage(
            "/svgPaths/yak/ami.svg", "0 0 300 500", "0", "width=\"50px\" height=\"50px\" viewbox=\"0 0 50 50\"", "Ami"
        );
        (_images[1], _decompressedSizes[1]) = _loadImage(
            "/svgPaths/yak/christine.svg",
            "0 0 500 470",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "Christine"
        );
        (_images[2], _decompressedSizes[2]) = _loadImage(
            "/svgPaths/yak/redlady.svg",
            "0 0 1000 600",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "RedLady"
        );
        (_images[3], _decompressedSizes[3]) = _loadImage(
            "/svgPaths/yak/josei.svg",
            "0 0 1000 600",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "Josei"
        );
        (_images[4], _decompressedSizes[4]) = _loadImage(
            "/svgPaths/yak/takechi.svg",
            "0 0 700 800",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "Takechi"
        );
        (_images[5], _decompressedSizes[5]) = _loadImage(
            "/svgPaths/yak/sport.svg",
            "215.709 2.143 566.847 499.207",
            "0",
            "width=\"300px\" height=\"100px\" viewbox=\"115.709 1.143 466.847 499.207\"",
            "Sport"
        );
        (_images[6], _decompressedSizes[6]) = _loadImage(
            "/svgPaths/yak/thinker.svg",
            "0 0 1000 600",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "Thinker"
        );
        (_images[7], _decompressedSizes[7]) = _loadImage(
            "/svgPaths/yak/tennis.svg",
            "0 0 2000 1300",
            "0",
            "width=\"200px\" height=\"200px\" viewbox=\"0 0 200 200\"",
            "Tennis"
        );
        (_images[8], _decompressedSizes[8]) = _loadImage(
            "/svgPaths/yak/yak2.svg",
            "0 0 230 300",
            "0",
            "width=\"50px\" height=\"50px\" viewbox=\"0 0 100 100\"",
            "Yak2"
        );
        (_images[9], _decompressedSizes[9]) = _loadImage(
            "/svgPaths/yak/focusedgirl.svg",
            "10.551 0.897 786.819 630.439",
            "0",
            "width=\"100.00px\" height=\"100.00px\" viewbox=\"10.551 0.897 786.819 630.439\"",
            "FocusedGirl"
        ); */

        (_icons[0], _decompressedSizesIcons[0]) = _loadIcon("/svgPaths/icon/stars.svg", "Stars", "yellow", 10);
        (_icons[1], _decompressedSizesIcons[1]) = _loadIcon("/svgPaths/icon/scribble.svg", "Scribble", "red", 5);
        (_icons[2], _decompressedSizesIcons[2]) = _loadIcon("/svgPaths/icon/abstract.svg", "Abstract", "black", 10);
        (_icons[3], _decompressedSizesIcons[3]) = _loadIcon("/svgPaths/icon/empty.svg", "None", "transparent", 75);
        //Yakyuken.Metadata memory metadata_ = Yakyuken.Metadata({});

        //(_images[5], _decompressedSizes[5]) = _loadImage("/svgPaths/v3/focusedgirl.svg", "0 0 300 500", "36", "Focused Girl");
        //(_images[6], _decompressedSizes[6]) = _loadImage("/svgPaths/v3/josei.svg", "0 0 300 500", "36", "Josei");
        //(_images[6], _decompressedSizes[6]) = _loadImage("/svgPaths/v3/redlady.svg", "0 0 300 500", "36", "Red Lady");
        //(_images[7], _decompressedSizes[7]) = _loadImage("/svgPaths/v3/sport.svg", "0 0 300 500", "36", "Sport");
        bytes memory info_ = hex"07103346642311"; // example
        _infoArray[0] = info_;
    }

    /// @dev You can send multiple transactions inside a single script.
    function run() public {
        vm.startBroadcast();

        // Deploy Yakyuken contract with ZLib compression.
        Yakyuken _yakyuken = new Yakyuken(address(new ZLib()));

        // Deploy SVG files.
        _yakyuken.initialize(_metadataDetails, _images, _decompressedSizes, _icons, _decompressedSizesIcons, _infoArray);

        vm.stopBroadcast();
    }

    function _loadImage(
        string memory path_,
        string memory viewBox_,
        string memory fontSize_,
        string memory iconSize_,
        string memory name_
    ) internal returns (bytes memory compressedImage_, uint128 decompressedSize_) {
        bytes memory image_ = abi.encode(Yakyuken.Image(_loadSVG(path_), viewBox_, fontSize_, iconSize_, name_));
        compressedImage_ = ZipUtils.zip(image_);
        decompressedSize_ = uint128(image_.length);
    }

    function _loadSVG(string memory path_) internal view returns (string memory svg_) {
        string memory root_ = vm.projectRoot();
        string memory imagePath_ = string.concat(root_, path_);
        svg_ = vm.readFile(imagePath_);
    }

    function _loadIcon(string memory path_, string memory name_, string memory color_, uint256 weight_)
        internal
        returns (bytes memory compressedImage_, uint128 decompressedSize_)
    {
        bytes memory image_ = abi.encode(Yakyuken.Icon(color_, name_, _loadSVG(path_), weight_));
        compressedImage_ = ZipUtils.zip(image_);
        decompressedSize_ = uint128(image_.length);
    }
}
