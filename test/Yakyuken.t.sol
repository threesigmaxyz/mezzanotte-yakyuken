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

    event LogMetadata(Yakyuken.Metadata mt);
    event LogTrait(Yakyuken.ValueTrait[]);
    event LogIcon(Yakyuken.Icon[]);
    event LogBytes(bytes);

    error DifferentValueError(string vl1, string vl2, string loc);
    error DifferentWeightError(uint256 vl1, uint256 vl2, string loc);

    function _loadSVG(string memory path_) internal view returns (string memory svg_) {
        string memory root_ = vm.projectRoot();
        string memory imagePath_ = string.concat(root_, path_);
        svg_ = vm.readFile(imagePath_);
    }

    function _loadImage(string memory path_, string memory viewBox_, string memory fontSize_, string memory name_)
        internal
        returns (bytes memory compressedImage_, uint128 decompressedSize_)
    {
        bytes memory image_ = abi.encode(Yakyuken.Image(_loadSVG(path_), viewBox_, fontSize_, name_));
        compressedImage_ = ZipUtils.zip(image_);
        decompressedSize_ = uint128(image_.length);
    }

    function setUp() external {
        _setUpArrays();

        _yakyuken = new Yakyuken(address(new ZLib()));

        // READ JSON CONFIG DATA
        string memory root_ = vm.projectRoot();
        string memory configPath_ = string.concat(root_, "/test/yakyuken.config.json");
        string memory configData_ = vm.readFile(configPath_);
        console2.log(configData_);
        bytes memory metadataDetails_ = configData_.parseRaw(".metadata");
        //emit LogBytes(metadataDetails_);
        console2.log("gotten metadata details");
        Yakyuken.Metadata memory metadata_ = abi.decode(metadataDetails_, (Yakyuken.Metadata));
        emit LogMetadata(metadata_);

        bytes[] memory images_ = new bytes[](5);
        uint128[] memory decompressedSizes_ = new uint128[](5);
        (images_[0], decompressedSizes_[0]) = _loadImage("/svgPaths/v3/focusedgirl.svg", "0 0 300 500", "36", "Ami");
        (images_[1], decompressedSizes_[1]) = _loadImage("/svgPaths/christine.svg", "0 0 500 470", "36", "Christine");
        (images_[2], decompressedSizes_[2]) = _loadImage("/svgPaths/takechi.svg", "0 0 700 800", "60", "Takechi");
        (images_[3], decompressedSizes_[3]) = _loadImage("/svgPaths/tennisNew.svg", "0 0 320 210", "210", "Tennis");
        (images_[4], decompressedSizes_[4]) = _loadImage("/svgPaths/yak2.svg", "0 0 230 300", "20", "Yakyuken");
        //NOTE: add other images here

        //Yakyuken.Metadata memory metadata_ = Yakyuken.Metadata({});

        _yakyuken.initialize(metadataDetails_, images_, decompressedSizes_);
    }

    function test_ok() external {
        //_yakyuken.readSVG(2);
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
        _compareValueTraitStruct(metadata_.textLocations, txtLoc, "Text Locations");
        _compareIconStruct(metadata_.icons, icn, "Icons");
    }

    /*function test_metadata() external {
        for (uint256 i_; i_ < 10; i_++) {
            string memory svg_ = _yakyuken.readSVG(i_);
            vm.writeFile(
                string(abi.encodePacked("generatedSVGs/solidity/", Strings.toString(i_), ".svg")),
                svg_);
        }
    }*/

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

        txtLoc.push(Yakyuken.ValueTrait("\"start\" x=\"5%\" y=\"10%\"", 25));
        txtLoc.push(Yakyuken.ValueTrait("\"end\" x=\"95%\" y=\"90%\"", 25));
        txtLoc.push(Yakyuken.ValueTrait("\"end\" x=\"95%\" y=\"10%\"", 25));
        txtLoc.push(Yakyuken.ValueTrait("\"start\" x=\"5%\" y=\"90%\"", 25));

        icn.push(Yakyuken.Icon("yellow", "svgPaths/icon/stars.svg", 10));
        icn.push(Yakyuken.Icon("red", "svgPaths/icon/scribble.svg", 5));
        icn.push(Yakyuken.Icon("black", "svgPaths/icon/abstract.svg", 10));
        icn.push(Yakyuken.Icon("transparent", "svgPaths/icon/empty.svg", 75));
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

            if (s1_[i_].weight != s2_[i_].weight) {
                revert DifferentWeightError(s1_[i_].weight, s2_[i_].weight, name_);
            }
        }
    }
}
