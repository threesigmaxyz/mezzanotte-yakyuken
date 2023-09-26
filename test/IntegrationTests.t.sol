// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@forge-std/Test.sol";
import { console2 } from "@forge-std/console2.sol";
import { stdJson } from "@forge-std/StdJson.sol";

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { ZipUtils } from "../common/ZipUtils.sol";

import { Yakyuken } from "../src/Yakyuken.sol";
import { ZLib } from "../src/zip/ZLib.sol";

contract YakyukenIntegrationTests is Test {
    using Strings for uint256;
    using stdJson for string;

    Yakyuken private _yakyuken;
    Yakyuken.Metadata metadata;

    bytes7[] private _infoArray;

    struct ByteRepresentation {
        uint256 tokenId;
        string value;
    }

    string[] public bckColors;
    string[] public bFillColors;
    string[] public initialShCol;
    string[] public finalShCol;
    string[] public initialShBri;
    string[] public finalShBri;
    string[] public glTimes;
    string[] public ykFillCol;
    string[] public ykHvCol;
    string[] public txts;
    string[] public txtLoc;
    Yakyuken.Icon[] public icn;

    Yakyuken.Icon[] private _iconStruct;
    address[] private _owners;
    error DifferentValueError(string vl1, string vl2, string loc);

    function setUp() external {
        _setUpArrays();
        _yakyuken = new Yakyuken(address(new ZLib()));

        // READ JSON CONFIG DATA
        string memory root_ = vm.projectRoot();
        string memory configPath_ = string.concat(root_, "/test/yakyuken.config.json");
        string memory configData_ = vm.readFile(configPath_);
        bytes memory metadataDetails_ = configData_.parseRaw(".metadata");

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
            "130.709 2.143 640 499.207",
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

        uint256 totalImages_ = decompressedSizes_.length + decompressedSizesHardcoded_.length;

        // Icons
        bytes[] memory icons_ = new bytes[](4);
        uint128[] memory decompressedSizesIcons_ = new uint128[](4);
        //Note: the compiler does not me let initialize the array with "new Yakyuken.Icon[](4)"
        _iconStruct.push(Yakyuken.Icon("", "", ""));
        _iconStruct.push(Yakyuken.Icon("", "", ""));
        _iconStruct.push(Yakyuken.Icon("", "", ""));
        _iconStruct.push(Yakyuken.Icon("", "", ""));

        (icons_[0], decompressedSizesIcons_[0], _iconStruct[0]) =
            _loadIcon("/svgPaths/icon/stars.svg", "stars", "yellow");
        (icons_[1], decompressedSizesIcons_[1], _iconStruct[1]) =
            _loadIcon("/svgPaths/icon/scribble.svg", "scribble", "red");
        (icons_[2], decompressedSizesIcons_[2], _iconStruct[2]) =
            _loadIcon("/svgPaths/icon/abstract.svg", "abstract", "black");
        (icons_[3], decompressedSizesIcons_[3], _iconStruct[3]) =
            _loadIcon("/svgPaths/icon/empty.svg", "none", "transparent");

        ByteRepresentation[] memory nftInBytes_;

        string memory inputPath_ = string.concat(root_, "/test/byteRepresentation.json");
        string memory inputData_ = vm.readFile(inputPath_);
        bytes memory bytesData_ = inputData_.parseRaw(".");
        nftInBytes_ = abi.decode(bytesData_, (ByteRepresentation[]));
        bytes7[] memory sampleInfoArray_ = new bytes7[](1);
        bytes7[] memory infoArray_ = new bytes7[](nftInBytes_.length);

        _infoArray = new bytes7[](nftInBytes_.length);

        sampleInfoArray_[0] = bytes7(bytes(nftInBytes_[0].value));

        for (uint256 i_ = 0; i_ < infoArray_.length; i_++) {
            infoArray_[nftInBytes_[i_].tokenId] = bytes7(bytes(nftInBytes_[i_].value));
        }

        _infoArray = infoArray_;

        _yakyuken.initializeMetadata(metadataDetails_, sampleInfoArray_);
        _yakyuken.initializeImages(images_, decompressedSizes_);
        _yakyuken.initializeImagesHardcoded(imagesHardcoded_, decompressedSizesHardcoded_, totalImages_);
        _yakyuken.initializeIcons(icons_, decompressedSizesIcons_);
    }

    function test_integration_test() external {
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/nvSsdsnmevTS18z6U5lBnUrV-5sMuNNP");

        uint256 numberOwners_ = 2549;
        for (uint256 i_ = 0; i_ < numberOwners_; i_++){
            _owners.push(vm.parseAddress(vm.readLine("lib/mezzanote-sale/snapshot/Data/OwnersSnapshot.csv")));
            console2.log(_owners[i_]);
        }

        address saleContract_ = 0x9cFBEfda7d3dC8F0E55aEA40cc2F4e0e595A9D39;
        address mezzanotteContract_ = 0xAD908C887ee36A746De5A9496f3fB4053c6317F6;

    }

    function _compareOutputFromId(uint256 currentTokenId_) internal {
        string memory contractPathFile_ =
            string.concat(string.concat("test/out/", vm.toString(currentTokenId_)), ".svg");

        // Fetch generated svg with the contract code
        string memory contractSvg_ = _yakyuken.generateSVGfromBytes(currentTokenId_);
        vm.writeFile(contractPathFile_, contractSvg_);

        // Fetch generated svg with the svg generator
        string memory pythonPathFile_ =
            string.concat(string.concat("test/python-generated-svg/", currentTokenId_.toString()), ".svg");

        // Prepare output to run script
        string[] memory inputs = new string[](4);
        inputs[0] = "node";
        inputs[1] = "test/compareStrings.js";
        inputs[2] = contractPathFile_;
        inputs[3] = pythonPathFile_;

        // Run script
        bytes memory res = vm.ffi(inputs);

        // Assert outputd
        assertEq(string(res), "true");
    }

    function _compareOutputFromIdSample(uint256 currentTokenId_) internal {
        string memory contractPathFile_ =
            string.concat(string.concat("test/out/", vm.toString(currentTokenId_)), ".svg");

        // Fetch generated svg with the contract code
        string memory contractSvg_ = _yakyuken.generateSVGfromBytes(currentTokenId_);
        vm.writeFile(contractPathFile_, contractSvg_);

        // Fetch generated svg with the svg generator
        string memory pythonPathFile_ = string.concat("test/python-generated-svg/0.svg");

        // Prepare output to run script
        string[] memory inputs = new string[](4);
        inputs[0] = "node";
        inputs[1] = "test/compareStrings.js";
        inputs[2] = contractPathFile_;
        inputs[3] = pythonPathFile_;

        // Run script
        bytes memory res = vm.ffi(inputs);

        // Assert outputd
        assertEq(string(res), "true");
    }

    function _setUpArrays() internal {
        //Note: decided to hardcode the expected results so it is a different method than reading from the json file
        bckColors.push("mistyrose");
        bckColors.push("linen");
        bckColors.push("peach");
        bckColors.push("yellow");
        bckColors.push("lemonchiffon");
        bckColors.push("black");
        bckColors.push("red");
        bckColors.push("blue");
        bckColors.push("deepskyblue");
        bckColors.push("mediumblue");
        bckColors.push("antiquewhite");
        bckColors.push("darkblue");
        bckColors.push("aquamarine");

        bFillColors.push("beige");
        bFillColors.push("softpink");
        bFillColors.push("waterblue");
        bFillColors.push("lightneon");
        bFillColors.push("wintergreen");
        bFillColors.push("blue");
        bFillColors.push("yellow");
        bFillColors.push("mediumspringgreen");
        bFillColors.push("cadetblue");
        bFillColors.push("violet");
        bFillColors.push("thistle");
        bFillColors.push("plum");
        bFillColors.push("mediumvioletred");
        bFillColors.push("black");

        initialShCol.push("orange");
        initialShCol.push("navy");
        initialShCol.push("white");
        initialShCol.push("red");
        initialShCol.push("blue");
        initialShCol.push("yellow");
        initialShCol.push("pink");
        initialShCol.push("cyan");

        finalShCol.push("black");
        finalShCol.push("lavender");
        finalShCol.push("white");
        finalShCol.push("red");
        finalShCol.push("yellow");
        finalShCol.push("mintcream");
        finalShCol.push("paleolivegreen");
        finalShCol.push("mossygreen");
        finalShCol.push("pear");
        finalShCol.push("blue");
        finalShCol.push("marine");
        finalShCol.push("pink");

        initialShBri.push("1");
        initialShBri.push("25");
        initialShBri.push("50");
        initialShBri.push("75");
        initialShBri.push("100");
        initialShBri.push("125");
        initialShBri.push("150");
        initialShBri.push("175");
        initialShBri.push("200");
        initialShBri.push("300");
        initialShBri.push("4000");

        finalShBri.push("25");
        finalShBri.push("50");
        finalShBri.push("75");
        finalShBri.push("100");
        finalShBri.push("125");
        finalShBri.push("150");
        finalShBri.push("175");
        finalShBri.push("200");
        finalShBri.push("3000");
        finalShBri.push("5000");

        glTimes.push("1");
        glTimes.push("5");
        glTimes.push(".5");
        glTimes.push(".2");
        glTimes.push("32");
        glTimes.push("1.5");
        glTimes.push(".9");
        glTimes.push("3");
        glTimes.push("65");
        glTimes.push("2");
        glTimes.push("3");
        glTimes.push("4");
        glTimes.push("5.5");
        glTimes.push("6");
        glTimes.push("7");
        glTimes.push("8");
        glTimes.push(".01");
        glTimes.push(".3");
        glTimes.push(".4");

        ykFillCol.push("lightorange");
        ykFillCol.push("lavenderblush");
        ykFillCol.push("powderblue");
        ykFillCol.push("navy");
        ykFillCol.push("neon");
        ykFillCol.push("blue");
        ykFillCol.push("blue");
        ykFillCol.push("pink");
        ykFillCol.push("yellow");
        ykFillCol.push("pastel");
        ykFillCol.push("turqouise");
        ykFillCol.push("honeydew");

        ykHvCol.push("goldenrod");
        ykHvCol.push("mintcream");
        ykHvCol.push("red");
        ykHvCol.push("lightblue");
        ykHvCol.push("aquamarine");
        ykHvCol.push("coral");
        ykHvCol.push("white");
        ykHvCol.push("lavenderblush");
        ykHvCol.push("verylightpink");
        ykHvCol.push("pink");
        ykHvCol.push("whitesmoke");
        ykHvCol.push("lavender");
        ykHvCol.push("lightorange");
        ykHvCol.push("yellow");
        ykHvCol.push("black");

        txts.push("\u77f3");
        txts.push("\u7d19");
        txts.push("\u306f\u3055\u307f");

        icn.push(Yakyuken.Icon("yellow", "stars", _loadSVG("/svgPaths/icon/stars.svg"))); //
        icn.push(Yakyuken.Icon("red", "scribble", _loadSVG("/svgPaths/icon/scribble.svg")));
        icn.push(Yakyuken.Icon("black", "abstract", _loadSVG("/svgPaths/icon/abstract.svg")));
        icn.push(Yakyuken.Icon("transparent", "none", _loadSVG("/svgPaths/icon/empty.svg")));
    }

    function _compareValueTraitStruct(string[] memory s1_, string[] memory s2_, string memory name_) internal pure {
        require(s1_.length == s2_.length, "Array of structs do not match, different lengths");
        for (uint256 i_ = 0; i_ < s1_.length; i_++) {
            if (keccak256(abi.encodePacked((s1_[i_]))) != keccak256(abi.encodePacked((s2_[i_])))) {
                revert DifferentValueError(s1_[i_], s2_[i_], name_);
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
        compressedImage_ = fromHex(vm.readFile(realLocation_));

        bytes memory image_ = abi.encode(Yakyuken.Image(_loadSVG(path_), viewBox_, fontSize_, iconSize_, name_));
        decompressedSize_ = uint128(image_.length);
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
        console2.logBytes(image_);
    }

    function _loadIcon(string memory path_, string memory name_, string memory color_)
        internal
        returns (bytes memory compressedImage_, uint128 decompressedSize_, Yakyuken.Icon memory iconStruct_)
    {
        iconStruct_ = Yakyuken.Icon(color_, name_, _loadSVG(path_));
        bytes memory image_ = abi.encode(iconStruct_);
        compressedImage_ = ZipUtils.zip(image_);
        decompressedSize_ = uint128(image_.length);
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
}
