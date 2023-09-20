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
    Yakyuken.Metadata metadata;

    struct ByteRepresentation {
        uint256 tokenId;
        string value;
    }

    Yakyuken.ValueTrait[] public bckColors;
    Yakyuken.ValueTrait[] public bFillColors;
    Yakyuken.ValueTrait[] public initialShCol;
    Yakyuken.ValueTrait[] public finalShCol;
    Yakyuken.ValueTrait[] public initialShBri;
    Yakyuken.ValueTrait[] public finalShBri;
    Yakyuken.ValueTrait[] public glTimes;
    Yakyuken.ValueTrait[] public ykFillCol;
    Yakyuken.ValueTrait[] public ykHvCol;
    Yakyuken.ValueTrait[] public txts;
    Yakyuken.ValueTrait[] public txtLoc;
    Yakyuken.Icon[] public icn;

    error DifferentValueError(string vl1, string vl2, string loc);
    error DifferentWeightError(uint256 vl1, uint256 vl2, string loc);

    event LogBytes(bytes output);

    function setUp() external {
        _setUpArrays();

        _yakyuken = new Yakyuken(address(new ZLib()));

        // READ JSON CONFIG DATA
        string memory root_ = vm.projectRoot();
        string memory configPath_ = string.concat(root_, "/test/yakyuken.config.json");
        string memory configData_ = vm.readFile(configPath_);
        bytes memory metadataDetails_ = configData_.parseRaw(".metadata");

        //Yakyuken.Metadata memory metadata_ = abi.decode(metadataDetails_, (Yakyuken.Metadata));
        bytes[] memory images_ = new bytes[](10);
        uint128[] memory decompressedSizes_ = new uint128[](10);
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

        /*(images_[7], decompressedSizes_[7]) = _loadImage(
            "/svgPaths/yak/tennis.svg",
            "0 0 2000 1300",
            "0",
            "width=\"200px\" height=\"200px\" viewbox=\"0 0 200 200\"",
            "Tennis"
        );*/

        (images_[7], decompressedSizes_[7]) = _loadImageHardcoded(
            "/svgPaths/yak/tennis.svg",
            "0 0 2000 1300",
            "0",
            "width=\"200px\" height=\"200px\" viewbox=\"0 0 200 200\"",
            "Tennis",
            "/svgPaths/yak/tennis_compressed.txt"
        );


        //NOTE: currently these two images are too big to be compressed
        /*(images_[8], decompressedSizes_[8]) = _loadImageHardcoded(
            "/svgPaths/yak/redlady.svg",
            "0 0 1000 600",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "RedLady",
            "/svgPaths/yak/redlady_compressed.txt"
        );*/
        /*
        (images_[9], decompressedSizes_[9]) = _loadImageHardcoded(
            "/svgPaths/yak/josei.svg",
            "0 0 1000 600",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "Josei",
            "/svgPaths/yak/josei_compressed.txt"
        );*/
        bytes[] memory icons_ = new bytes[](4);
        uint128[] memory decompressedSizesIcons_ = new uint128[](4);
        (icons_[0], decompressedSizesIcons_[0]) = _loadIcon("/svgPaths/icon/stars.svg", "stars", "yellow", 10);
        (icons_[1], decompressedSizesIcons_[1]) = _loadIcon("/svgPaths/icon/scribble.svg", "scribble", "red", 5);
        (icons_[2], decompressedSizesIcons_[2]) = _loadIcon("/svgPaths/icon/abstract.svg", "abstract", "black", 10);
        (icons_[3], decompressedSizesIcons_[3]) = _loadIcon("/svgPaths/icon/empty.svg", "none", "transparent", 75);
        //Yakyuken.Metadata memory metadata_ = Yakyuken.Metadata({});

        ByteRepresentation[] memory nftInBytes_;

        string memory inputPath_ = string.concat(root_, "/test/byteRepresentation.json");
        string memory inputData_ = vm.readFile(inputPath_);
        bytes memory bytesData_ = inputData_.parseRaw(".");
        nftInBytes_ = abi.decode(bytesData_, (ByteRepresentation[]));
        bytes[] memory infoArray_ = new bytes[](nftInBytes_.length);

        for (uint256 i_ = 0; i_ < infoArray_.length; i_++) {
            infoArray_[nftInBytes_[i_].tokenId] = bytes(nftInBytes_[i_].value);
        }

        _yakyuken.initialize(metadataDetails_, images_, decompressedSizes_, icons_, decompressedSizesIcons_, infoArray_);
    }

    function test_get_bytes() external {
        /*_getBytesOfImage( "/svgPaths/yak/redlady.svg",
            "0 0 1000 600",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "RedLady.txt");

        _getBytesOfImage(  "/svgPaths/yak/josei.svg",
            "0 0 1000 600",
            "0",
            "width=\"100px\" height=\"100px\" viewbox=\"0 0 100 100\"",
            "Josei.txt");


        _getBytesOfImage(
            "/svgPaths/yak/tennis.svg",
            "0 0 2000 1300",
            "0",
            "width=\"200px\" height=\"200px\" viewbox=\"0 0 200 200\"",
            "/tennis.txt"
        );*/
    }

    function test_ok() external {
        uint128 maxToken_ = 2;
        for (uint128 tokenId_ = 0; tokenId_ < maxToken_; tokenId_++) {
            string memory svg_ = _yakyuken.generateSVGfromBytes(tokenId_);
            vm.writeFile(string.concat(string.concat("test/out/", vm.toString(tokenId_)), ".svg"), svg_);
        }
    }

    function test_read_file() external view {
        ByteRepresentation[] memory nftInBytes_;
        string memory root_ = vm.projectRoot();

        string memory inputPath_ = string.concat(root_, "/test/byteRepresentation.json");
        string memory inputData_ = vm.readFile(inputPath_);
        bytes memory bytesData_ = inputData_.parseRaw(".");
        nftInBytes_ = abi.decode(bytesData_, (ByteRepresentation[]));
        bytes[] memory infoArray_ = new bytes[](nftInBytes_.length);
        for (uint256 i_ = 0; i_ < infoArray_.length; i_++) {
            infoArray_[nftInBytes_[i_].tokenId] = bytes(nftInBytes_[i_].value);
        }
    }

    function test_read_traits() external view {
        // READ JSON CONFIG DATA
        string memory root_ = vm.projectRoot();
        string memory configPath_ = string.concat(root_, "/test/yakyuken.config.json");
        string memory configData_ = vm.readFile(configPath_);
        bytes memory metadataDetails_ = configData_.parseRaw(".metadata");
        Yakyuken.Metadata memory metadata_ = abi.decode(metadataDetails_, (Yakyuken.Metadata));

        // Compare results
        _compareValueTraitStruct(metadata_.backgroundColors, bckColors, "Background Colors");
        _compareValueTraitStruct(metadata_.baseFillColors, bFillColors, "Base Fill Colors");
        _compareValueTraitStruct(metadata_.initialShadowColors, initialShCol, "Initial Shadow Colors");
        _compareValueTraitStruct(metadata_.finalShadowColors, finalShCol, "Final Shadow Colors");
        _compareValueTraitStruct(metadata_.initialShadowBrightness, initialShBri, "Initial Shadow Brightness");
        _compareValueTraitStruct(metadata_.finalShadowBrightness, finalShBri, "Final Shadow Brightness");
        _compareValueTraitStruct(metadata_.glowTimes, glTimes, "Glow Times");
        _compareValueTraitStruct(metadata_.yakFillColors, ykFillCol, "Yak Fill Colors");
        _compareValueTraitStruct(metadata_.yakHoverColors, ykHvCol, "Yak Hover Colors");
        //_compareValueTraitStruct(metadata_.texts, txts); // NOTE: see init struct of texts
        //_compareIconStruct(metadata_.icons, icn, "Icons"); // TODO: compare unzipping
    }

    function test_process_bytes_info() external {
        bytes memory info_ = hex"07103346642311";
        Yakyuken.MetadataBytes memory result = _yakyuken.processMetadataAsBytes(info_);
        assertEq(result.glowTimes, 7);
        assertEq(result.backgroundColors, 16);
        assertEq(result.yakHoverColors, 3);
        assertEq(result.finalShadowColors, 3);
        assertEq(result.baseFillColors, 4);
        assertEq(result.yakFillColors, 6);
        assertEq(result.yak, 6);
        assertEq(result.initialShadowColors, 4);
        assertEq(result.initialShadowBrightness, 2);
        assertEq(result.finalShadowBrightness, 3);
        assertEq(result.icon, 1);
        assertEq(result.texts, 1);
    }

    function test_generate_from_bytes_data() external {
        uint16 tokenId_ = 0;
        string memory svg_ = _yakyuken.generateSVGfromBytes(tokenId_);
        vm.writeFile(string.concat(string.concat("test/out/", vm.toString(tokenId_)), ".svg"), svg_);
    }

    function _setUpArrays() internal {
        //Note: decided to hardcode the expected results so it is a different method than reading from the json file

        bckColors.push(Yakyuken.ValueTrait("mistyrose", 5));
        bckColors.push(Yakyuken.ValueTrait("linen", 5));
        bckColors.push(Yakyuken.ValueTrait("mintcream", 5));
        bckColors.push(Yakyuken.ValueTrait("peach", 1));
        bckColors.push(Yakyuken.ValueTrait("yellow", 10));
        bckColors.push(Yakyuken.ValueTrait("lemonchiffon", 2));
        bckColors.push(Yakyuken.ValueTrait("black", 20));
        bckColors.push(Yakyuken.ValueTrait("thistle1", 9));
        bckColors.push(Yakyuken.ValueTrait("aliceblue", 10));
        bckColors.push(Yakyuken.ValueTrait("red", 12));
        bckColors.push(Yakyuken.ValueTrait("blue4", 6));
        bckColors.push(Yakyuken.ValueTrait("azure", 10));
        bckColors.push(Yakyuken.ValueTrait("darkseagreen1", 1));
        bckColors.push(Yakyuken.ValueTrait("mediumblue", 1));
        bckColors.push(Yakyuken.ValueTrait("antiquewhite2", 1));
        bckColors.push(Yakyuken.ValueTrait("deepskyblue", 1));
        bckColors.push(Yakyuken.ValueTrait("aquamarine3", 1));

        bFillColors.push(Yakyuken.ValueTrait("beige", 7));
        bFillColors.push(Yakyuken.ValueTrait("lime0", 7));
        bFillColors.push(Yakyuken.ValueTrait("softpink", 7));
        bFillColors.push(Yakyuken.ValueTrait("waterblue", 12));
        bFillColors.push(Yakyuken.ValueTrait("lightneon", 7));
        bFillColors.push(Yakyuken.ValueTrait("wintergreen", 12));
        bFillColors.push(Yakyuken.ValueTrait("blue", 12));
        bFillColors.push(Yakyuken.ValueTrait("yellow", 12));
        bFillColors.push(Yakyuken.ValueTrait("ivory", 12));
        bFillColors.push(Yakyuken.ValueTrait("cadetblue3", 6));
        bFillColors.push(Yakyuken.ValueTrait("LightCyan3", 6));

        initialShCol.push(Yakyuken.ValueTrait("orange", 12));
        initialShCol.push(Yakyuken.ValueTrait("navy", 12));
        initialShCol.push(Yakyuken.ValueTrait("white", 12));
        initialShCol.push(Yakyuken.ValueTrait("red", 12));
        initialShCol.push(Yakyuken.ValueTrait("blue", 12));
        initialShCol.push(Yakyuken.ValueTrait("yellow", 24));
        initialShCol.push(Yakyuken.ValueTrait("pink", 2));
        initialShCol.push(Yakyuken.ValueTrait("cyan3", 14));

        finalShCol.push(Yakyuken.ValueTrait("black", 16));
        finalShCol.push(Yakyuken.ValueTrait("lavender", 6));
        finalShCol.push(Yakyuken.ValueTrait("white", 12));
        finalShCol.push(Yakyuken.ValueTrait("red", 6));
        finalShCol.push(Yakyuken.ValueTrait("yellow", 6));
        finalShCol.push(Yakyuken.ValueTrait("mintcream", 12));
        finalShCol.push(Yakyuken.ValueTrait("paleolivegreen", 6));
        finalShCol.push(Yakyuken.ValueTrait("mossygreen", 6));
        finalShCol.push(Yakyuken.ValueTrait("pear", 12));
        finalShCol.push(Yakyuken.ValueTrait("midblue", 6));
        finalShCol.push(Yakyuken.ValueTrait("marine", 6));
        finalShCol.push(Yakyuken.ValueTrait("verylightpink", 6));

        initialShBri.push(Yakyuken.ValueTrait("0", 20));
        initialShBri.push(Yakyuken.ValueTrait("25", 20));
        initialShBri.push(Yakyuken.ValueTrait("50", 20));
        initialShBri.push(Yakyuken.ValueTrait("75", 20));
        initialShBri.push(Yakyuken.ValueTrait("100", 20));

        finalShBri.push(Yakyuken.ValueTrait("100", 20));
        finalShBri.push(Yakyuken.ValueTrait("125", 20));
        finalShBri.push(Yakyuken.ValueTrait("150", 20));
        finalShBri.push(Yakyuken.ValueTrait("175", 20));
        finalShBri.push(Yakyuken.ValueTrait("200", 20));

        glTimes.push(Yakyuken.ValueTrait("1", 4));
        glTimes.push(Yakyuken.ValueTrait("5", 2));
        glTimes.push(Yakyuken.ValueTrait(".1", 20));
        glTimes.push(Yakyuken.ValueTrait(".2", 5));
        glTimes.push(Yakyuken.ValueTrait("32", 1));
        glTimes.push(Yakyuken.ValueTrait("1.5", 6));
        glTimes.push(Yakyuken.ValueTrait(".9", 16));
        glTimes.push(Yakyuken.ValueTrait("3", 8));
        glTimes.push(Yakyuken.ValueTrait("65", 1));
        glTimes.push(Yakyuken.ValueTrait("2", 5));
        glTimes.push(Yakyuken.ValueTrait("3", 2));
        glTimes.push(Yakyuken.ValueTrait("4", 3));
        glTimes.push(Yakyuken.ValueTrait("5.5", 6));
        glTimes.push(Yakyuken.ValueTrait("6", 5));
        glTimes.push(Yakyuken.ValueTrait("7", 3));
        glTimes.push(Yakyuken.ValueTrait("8", 2));
        glTimes.push(Yakyuken.ValueTrait(".01", 5));
        glTimes.push(Yakyuken.ValueTrait(".3", 4));
        glTimes.push(Yakyuken.ValueTrait(".4", 2));

        ykFillCol.push(Yakyuken.ValueTrait("floralwhite", 9));
        ykFillCol.push(Yakyuken.ValueTrait("lavenderblush", 9));
        ykFillCol.push(Yakyuken.ValueTrait("indianred1", 9));
        ykFillCol.push(Yakyuken.ValueTrait("snow2", 9));
        ykFillCol.push(Yakyuken.ValueTrait("blush", 16));
        ykFillCol.push(Yakyuken.ValueTrait("blue", 8));
        ykFillCol.push(Yakyuken.ValueTrait("verylightpink", 8));
        ykFillCol.push(Yakyuken.ValueTrait("yellow", 8));
        ykFillCol.push(Yakyuken.ValueTrait("orange0", 8));
        ykFillCol.push(Yakyuken.ValueTrait("teal3", 8));
        ykFillCol.push(Yakyuken.ValueTrait("honeydew", 8));

        ykHvCol.push(Yakyuken.ValueTrait("lightcoral", 10));
        ykHvCol.push(Yakyuken.ValueTrait("mintcream", 5));
        ykHvCol.push(Yakyuken.ValueTrait("white", 8));
        ykHvCol.push(Yakyuken.ValueTrait("red", 8));
        ykHvCol.push(Yakyuken.ValueTrait("blue", 14));
        ykHvCol.push(Yakyuken.ValueTrait("aquamarine2", 16));
        ykHvCol.push(Yakyuken.ValueTrait("honeydew", 8));
        ykHvCol.push(Yakyuken.ValueTrait("lavenderblush", 4));
        ykHvCol.push(Yakyuken.ValueTrait("verylightpink", 4));
        ykHvCol.push(Yakyuken.ValueTrait("peach", 5));
        ykHvCol.push(Yakyuken.ValueTrait("whitesmoke", 8));
        ykHvCol.push(Yakyuken.ValueTrait("neon", 7));
        ykHvCol.push(Yakyuken.ValueTrait("red3", 2));
        ykHvCol.push(Yakyuken.ValueTrait("yellow", 1));

        //TODO: texts is being ignored because one of the char is not recognized by solidity
        //txts.push(Yakyuken.ValueTrait("石", 33));
        //txts.push(Yakyuken.ValueTrait("紙", 33));
        //txts.push(Yakyuken.ValueTrait("はさみ", 34));

        icn.push(Yakyuken.Icon("yellow", "Stars", _loadSVG("/svgPaths/icon/stars.svg"), 10)); //
        icn.push(Yakyuken.Icon("red", "Scribble", _loadSVG("/svgPaths/icon/scribble.svg"), 5));
        icn.push(Yakyuken.Icon("black", "Abstract", _loadSVG("/svgPaths/icon/abstract.svg"), 10));
        icn.push(Yakyuken.Icon("transparent", "None", _loadSVG("/svgPaths/icon/empty.svg"), 75));
    }

    function _compareValueTraitStruct(
        Yakyuken.ValueTrait[] memory s1_,
        Yakyuken.ValueTrait[] memory s2_,
        string memory name_
    ) internal pure {
        require(s1_.length == s2_.length, "Array of structs do not match, different lengths");
        for (uint256 i_ = 0; i_ < s1_.length; i_++) {
            if (keccak256(abi.encodePacked((s1_[i_].value))) != keccak256(abi.encodePacked((s2_[i_].value)))) {
                revert DifferentValueError(s1_[i_].value, s2_[i_].value, name_);
            }

            if (s1_[i_].weight != s2_[i_].weight) {
                revert DifferentWeightError(s1_[i_].weight, s2_[i_].weight, name_);
            }
        }
    }

    function _compareIconStruct(Yakyuken.Icon[] memory s1_, Yakyuken.Icon[] memory s2_, string memory name_)
        internal
        pure
    {
        require(s1_.length == s2_.length, "Array of structs do not match, different lengths");
        for (uint256 i_ = 0; i_ < s1_.length; i_++) {
            if (keccak256(abi.encodePacked((s1_[i_].path))) != keccak256(abi.encodePacked((s2_[i_].path)))) {
                revert DifferentValueError(s1_[i_].path, s2_[i_].path, name_);
            }
            if (keccak256(abi.encodePacked((s1_[i_].color))) != keccak256(abi.encodePacked((s2_[i_].color)))) {
                revert DifferentValueError(s1_[i_].color, s2_[i_].color, name_);
            }
            if (keccak256(abi.encodePacked((s1_[i_].name))) != keccak256(abi.encodePacked((s2_[i_].name)))) {
                revert DifferentValueError(s1_[i_].name, s2_[i_].name, name_);
            }

            if (s1_[i_].weight != s2_[i_].weight) {
                revert DifferentWeightError(s1_[i_].weight, s2_[i_].weight, name_);
            }
        }
    }

    function _loadSVG(string memory path_) internal view returns (string memory svg_) {
        string memory root_ = vm.projectRoot();
        string memory imagePath_ = string.concat(root_, path_);
        svg_ = vm.readFile(imagePath_);
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
        compressedImage_ = bytes(vm.readFile(realLocation_));
        
        bytes memory image_ = abi.encode(Yakyuken.Image(_loadSVG(path_), viewBox_, fontSize_, iconSize_, name_));
        decompressedSize_ = uint128(image_.length);
        console2.log(decompressedSize_);
    }

    function _getBytesOfImage(
        string memory path_,
        string memory viewBox_,
        string memory fontSize_,
        string memory iconSize_,
        string memory name_
    ) internal {
        bytes memory image_ = abi.encode(Yakyuken.Image(_loadSVG(path_), viewBox_, fontSize_, iconSize_, name_));
        string memory result = string.concat("svgPaths/yak/", name_);
        vm.writeFile(result, string(image_));
        emit LogBytes(image_);
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
