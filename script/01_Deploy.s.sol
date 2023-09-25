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

    struct ByteRepresentation {
        uint256 tokenId;
        string value;
    }

    bytes[] private _images = new bytes[](8);
    uint128[] private _decompressedSizes = new uint128[](8);
    bytes[] private _imagesHardcoded = new bytes[](2);
    uint128[] private _decompressedSizesHardcoded = new uint128[](2);
    uint256 private _totalImages;
    bytes[] private _icons = new bytes[](4);
    uint128[] private _decompressedSizesIcons = new uint128[](4);
    bytes private _metadataDetails;
    bytes7[] private _infoArray;

    function setUp() public {
        // READ JSON CONFIG DATA
        string memory root_ = vm.projectRoot();
        string memory configPath_ = string.concat(root_, "/test/yakyuken.config.json");
        string memory configData_ = vm.readFile(configPath_);
        _metadataDetails = configData_.parseRaw(".metadata");

        // TODO Yakyuken.Metadata memory metadata_ = abi.decode(metadataDetails_, (Yakyuken.Metadata));

        bytes[] memory images_ = new bytes[](8);
        uint128[] memory decompressedSizes_ = new uint128[](8);
        bytes[] memory imagesHardcoded_ = new bytes[](2);
        uint128[] memory decompressedSizesHardcoded_ = new uint128[](2);
        (images_[0], decompressedSizes_[0]) = _loadImage(
            "/svgPaths/yak/ami.svg", "0 0 300 500", "0", "width=\"50px\" height=\"50px\" viewbox=\"0 0 50 50\"", "ami"
        );
        (images_[1], decompressedSizes_[1]) = _loadImage(
            "/svgPaths/yak/christine.svg",
            "0 0 500 470",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "christine"
        );
        (images_[2], decompressedSizes_[2]) = _loadImage(
            "/svgPaths/yak/yak2.svg",
            "0 0 230 300",
            "0",
            "width=\"50px\" height=\"50px\" viewbox=\"0 0 100 100\"",
            "yak2"
        );
        (images_[3], decompressedSizes_[3]) = _loadImage(
            "/svgPaths/yak/focusedgirl.svg",
            "10.551 0.897 786.819 630.439",
            "0",
            "width=\"100.00px\" height=\"100.00px\" viewbox=\"10.551 0.897 786.819 630.439\"",
            "focusedgirl"
        );
        (images_[4], decompressedSizes_[4]) = _loadImage(
            "/svgPaths/yak/takechi.svg",
            "0 0 700 800",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "Takechi"
        );
        (images_[5], decompressedSizes_[5]) = _loadImage(
            "/svgPaths/yak/sport.svg",
            "215.709 2.143 566.847 499.207",
            "0",
            "width=\"300px\" height=\"100px\" viewbox=\"115.709 1.143 466.847 499.207\"",
            "Sport"
        );
        (images_[6], decompressedSizes_[6]) = _loadImage(
            "/svgPaths/yak/thinker.svg",
            "0 0 1000 600",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "Thinker"
        );
        (images_[7], decompressedSizes_[7]) = _loadImage(
            "/svgPaths/yak/tennis.svg",
            "0 0 2000 1300",
            "0",
            "width=\"200px\" height=\"200px\" viewbox=\"0 0 200 200\"",
            "Tennis"
        );
        //NOTE: these two images need to be compressed with a different method
        (imagesHardcoded_[0], decompressedSizesHardcoded_[0]) = _loadImageHardcoded(
            "/svgPaths/yak/redlady.svg",
            "0 0 1000 600",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "RedLady",
            "/svgPaths/yak/redlady_compressed.txt"
        );
        (imagesHardcoded_[1], decompressedSizesHardcoded_[1]) = _loadImageHardcoded(
            "/svgPaths/yak/josei.svg",
            "0 0 1000 600",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "Josei",
            "/svgPaths/yak/josei_compressed.txt"
        );

        _images = images_;
        _decompressedSizes = decompressedSizes_;

        _imagesHardcoded = imagesHardcoded_;
        _decompressedSizesHardcoded = decompressedSizesHardcoded_;

        _totalImages = decompressedSizes_.length + decompressedSizesHardcoded_.length;

        // Icons
        bytes[] memory icons_ = new bytes[](4);
        uint128[] memory decompressedSizesIcons_ = new uint128[](4);

        (icons_[0], decompressedSizesIcons_[0]) = _loadIcon("/svgPaths/icon/stars.svg", "stars", "yellow");
        (icons_[1], decompressedSizesIcons_[1]) = _loadIcon("/svgPaths/icon/scribble.svg", "scribble", "red");
        (icons_[2], decompressedSizesIcons_[2]) = _loadIcon("/svgPaths/icon/abstract.svg", "abstract", "black");
        (icons_[3], decompressedSizesIcons_[3]) = _loadIcon("/svgPaths/icon/empty.svg", "none", "transparent");

        _icons = icons_;
        _decompressedSizesIcons = decompressedSizesIcons_;

        ByteRepresentation[] memory nftInBytes_;

        string memory inputPath_ = string.concat(root_, "/test/byteRepresentation.json");
        string memory inputData_ = vm.readFile(inputPath_);
        bytes memory bytesData_ = inputData_.parseRaw(".");
        nftInBytes_ = abi.decode(bytesData_, (ByteRepresentation[]));
        bytes7[] memory infoArray_ = new bytes7[](nftInBytes_.length);

        for (uint256 i_ = 0; i_ < infoArray_.length; i_++) {
            infoArray_[nftInBytes_[i_].tokenId] = bytes7(bytes(nftInBytes_[i_].value));
        }

        _infoArray = infoArray_;
    }

    /// @dev You can send multiple transactions inside a single script.
    function run() public {
        vm.startBroadcast();

        // Deploy Yakyuken contract with ZLib compression.
        Yakyuken _yakyuken = new Yakyuken(address(new ZLib()));

        // Deploy SVG files.
        _yakyuken.initializeMetadata(_metadataDetails, _infoArray);
        _yakyuken.initializeImages(_images, _decompressedSizes);
        _yakyuken.initializeImagesHardcoded(_imagesHardcoded, _decompressedSizesHardcoded, _totalImages);
        _yakyuken.initializeIcons(_icons, _decompressedSizesIcons);

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

    function _loadImageHardcoded(
        string memory path_,
        string memory viewBox_,
        string memory fontSize_,
        string memory iconSize_,
        string memory name_,
        string memory hardcodedLocation_
    ) internal view returns (bytes memory compressedImage_, uint128 decompressedSize_) {
        string memory root_ = vm.projectRoot();
        string memory realLocation_ = string.concat(root_, hardcodedLocation_);
        compressedImage_ = fromHex(vm.readFile(realLocation_));

        bytes memory image_ = abi.encode(Yakyuken.Image(_loadSVG(path_), viewBox_, fontSize_, iconSize_, name_));
        decompressedSize_ = uint128(image_.length);
    }

    function _loadSVG(string memory path_) internal view returns (string memory svg_) {
        string memory root_ = vm.projectRoot();
        string memory imagePath_ = string.concat(root_, path_);
        svg_ = vm.readFile(imagePath_);
    }

    function _loadIcon(string memory path_, string memory name_, string memory color_)
        internal
        returns (bytes memory compressedImage_, uint128 decompressedSize_)
    {
        bytes memory image_ = abi.encode(Yakyuken.Icon(color_, name_, _loadSVG(path_)));
        compressedImage_ = ZipUtils.zip(image_);
        decompressedSize_ = uint128(image_.length);
    }

    // Convert an hexadecimal string to raw bytes
    function fromHex(string memory s) public pure returns (bytes memory) {
        bytes memory ss = bytes(s);
        require(ss.length % 2 == 0); // length must be even
        bytes memory r = new bytes(ss.length/2);
        for (uint256 i = 0; i < ss.length / 2; ++i) {
            r[i] = bytes1(fromHexChar(uint8(ss[2 * i])) * 16 + fromHexChar(uint8(ss[2 * i + 1])));
        }
        return r;
    }

    // Convert an hexadecimal character to their value
    function fromHexChar(uint8 c) public pure returns (uint8) {
        if (bytes1(c) >= bytes1("0") && bytes1(c) <= bytes1("9")) {
            return c - uint8(bytes1("0"));
        }
        if (bytes1(c) >= bytes1("a") && bytes1(c) <= bytes1("f")) {
            return 10 + c - uint8(bytes1("a"));
        }
        if (bytes1(c) >= bytes1("A") && bytes1(c) <= bytes1("F")) {
            return 10 + c - uint8(bytes1("A"));
        }
        revert("fail");
    }
}
