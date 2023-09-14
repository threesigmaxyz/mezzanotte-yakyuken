// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/access/Ownable.sol";
import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";
import { ERC721URIStorage } from "@openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";
import { Base64 } from "@openzeppelin/utils/Base64.sol";
import { Strings } from "@openzeppelin/utils/Strings.sol";

import { ERC721B } from "./ERC721B.sol";
import { ZLib } from "./zip/ZLib.sol";

contract Yakyuken is ERC721B, ERC721URIStorage, Ownable {
    using Strings for uint256;
    event LogBytes(bytes1 point);

    bytes32 private constant METADATA_POINTER = bytes32(keccak256("metadata"));

    uint16 private constant MEMORY_OFFSET = 20;

    address private immutable _zlib;

    ImageMetadata[] private _imageMetadata;
    IconMetadata[] private _iconMetadata;

    string public ICON_LOCATION = "TBD";

    struct Image {
        string path;
        string viewBox;
        string fontSize;
        string iconSize;
        string name;
    }

    struct ImageMetadata {
        uint128 decompressedSize;
        uint128 weight;
    }

    struct ValueTrait {
        string value;
        uint256 weight;
    }

    ///@dev must be in alphabetical order
    struct Icon {
        string color;
        string name;
        string path;
        uint256 weight;
    }

    struct IconMetadata {
        uint128 decompressedSize;
        uint128 weight;
    }

    struct MetadataBytes {
        uint8 glowTimes;
        uint8 backgroundColors;
        uint8 yakHoverColors;
        uint8 finalShadowColors;
        uint8 baseFillColors;
        uint8 yakFillColors;
        uint8 yak;
        uint8 initialShadowColors;
        uint8 initialShadowBrightness;
        uint8 finalShadowBrightness;
        uint8 icon;
        uint8 texts;
    }

    ///@dev  must be in alphabetical order
    struct Metadata {
        ValueTrait[] backgroundColors;
        ValueTrait[] baseFillColors;
        ValueTrait[] finalShadowBrightness;
        ValueTrait[] finalShadowColors;
        ValueTrait[] glowTimes;
        ValueTrait[] initialShadowBrightness;
        ValueTrait[] initialShadowColors;
        // ValueTrait[] yak;
        ValueTrait[] textLocations;
        ValueTrait[] texts;
        ValueTrait[] yakFillColors;
        ValueTrait[] yakHoverColors;
    }

    event LogResult(MetadataBytes result);

    constructor(address zlib_) ERC721("Yakyuken", "YNFT") Ownable(msg.sender) {
        _zlib = zlib_;
    }

    // TODO only callable once by the deployer.
    function initialize(
        bytes calldata metadata_,
        bytes[] calldata images_,
        uint128[] calldata decompressedSizes_,
        bytes[] calldata icons_,
        uint128[] calldata decompressedSizesIcons_
    ) external {
        _write(METADATA_POINTER, metadata_);

        uint256 imageCount_ = images_.length;
        for (uint256 i_; i_ < imageCount_; i_++) {
            _write(bytes32(keccak256(abi.encode(i_))), images_[i_]);
            _imageMetadata.push(ImageMetadata(decompressedSizes_[i_], uint128(100 / images_.length))); // TODO pass as init argument
        }

        uint256 iconCount_ = icons_.length;
        for (uint256 j_; j_ < iconCount_; j_++) {
            _write(bytes32(keccak256(abi.encode(j_ + MEMORY_OFFSET))), icons_[j_]);
            _iconMetadata.push(IconMetadata(decompressedSizesIcons_[j_], uint128(100 / icons_.length))); // TODO pass as init argument
        }
    }

    function tokenURI(uint256 tokenId_) public view override returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Yakyuken #',
            tokenId_.toString(),
            '", "description": "',
            "Yakyuken NFT on-chain collection.",
            '", "image_data": "',
            string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(_readSVG(tokenId_)))),
            '"',
            "}"
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function generateSVGfromBytes(bytes memory metadataInfo_ ) public{
        MetadataBytes memory data_ = processMetadataAsBytes(metadataInfo_);
    }

    function readSVG(uint256 tokenId_) external view returns (string memory svg_) {
        svg_ = string(_readSVG(tokenId_));
    }

    function processMetadataAsBytes(bytes memory metadataInfo_) public returns(MetadataBytes memory data_){
        data_.glowTimes = uint8(metadataInfo_[0]); // 7
        data_.backgroundColors = uint8(metadataInfo_[1]); // 16
        data_.yakHoverColors  = uint8(metadataInfo_[2] >> 4); // 3
        data_.finalShadowColors = uint8(metadataInfo_[2] & 0x0F); // 3
        data_.baseFillColors  = uint8(metadataInfo_[3] >> 4); // 4
        data_.yakFillColors  = uint8(metadataInfo_[3] & 0x0F); // 4
        data_.yak = uint8(metadataInfo_[4] >> 4); // 6
        data_.initialShadowColors = uint8(metadataInfo_[4] & 0x0F); // 6
        data_.initialShadowBrightness = uint8(metadataInfo_[5] >> 4); // 9
        data_.finalShadowBrightness = uint8(metadataInfo_[5] & 0x0F); // 9
        data_.icon = uint8(metadataInfo_[6] >> 4); // 4
        data_.texts = uint8(metadataInfo_[6] & 0x0F); // 4

        emit LogResult(data_);
    }

    function _readSVG(uint256 tokenId_) internal view returns (bytes memory) {
        Metadata memory metadata_ = abi.decode(_read(METADATA_POINTER), (Metadata));
        Image memory image_ = _weightedImageGenerator(uint256(keccak256(abi.encodePacked(tokenId_, "img"))));
        Icon memory icon_ = _weightedIconGenerator(uint256(keccak256(abi.encodePacked(tokenId_, "icn"))));

        return abi.encodePacked(
            _getHeader(
                image_.viewBox,
                _weightedRarityGenerator(
                    metadata_.backgroundColors, uint256(keccak256(abi.encodePacked(tokenId_, "bg")))
                )
            ),
            _getStyleHeader(
                _weightedRarityGenerator(
                    metadata_.initialShadowColors, uint256(keccak256(abi.encodePacked(tokenId_, "isc")))
                ),
                _weightedRarityGenerator(
                    metadata_.finalShadowColors, uint256(keccak256(abi.encodePacked(tokenId_, "fsc")))
                ),
                _weightedRarityGenerator(
                    metadata_.initialShadowBrightness, uint256(keccak256(abi.encodePacked(tokenId_, "isb")))
                ),
                _weightedRarityGenerator(
                    metadata_.finalShadowBrightness, uint256(keccak256(abi.encodePacked(tokenId_, "fsb")))
                ),
                _weightedRarityGenerator(
                    metadata_.baseFillColors, uint256(keccak256(abi.encodePacked(tokenId_, "bfc")))
                ),
                _weightedRarityGenerator(metadata_.glowTimes, uint256(keccak256(abi.encodePacked(tokenId_, "gt")))),
                _weightedRarityGenerator(metadata_.yakFillColors, uint256(keccak256(abi.encodePacked(tokenId_, "yfc")))),
                _weightedRarityGenerator(metadata_.yakHoverColors, uint256(keccak256(abi.encodePacked(tokenId_, "hc")))),
                icon_.color
            ),
            image_.path,
            _getIcon(icon_.path, image_.iconSize),
            _getHoverText(
                _weightedRarityGenerator(metadata_.texts, uint256(keccak256(abi.encodePacked(tokenId_, "t")))),
                image_.fontSize,
                _weightedRarityGenerator(metadata_.textLocations, uint256(keccak256(abi.encodePacked(tokenId_, "tl"))))
            ),
            "</svg>"
        );
    }

    function _getHeader(string memory viewBox_, string memory backgroundColor_) internal pure returns (bytes memory) {
        return abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet" viewBox="',
            viewBox_,
            '" style="background-color:',
            backgroundColor_,
            '">'
        );
    }

    function _getStyleHeader(
        string memory initialShadowColors_,
        string memory finalShadowColors_,
        string memory initialShadowBrightness_,
        string memory finalShadowBrightness_,
        string memory baseFillColors_,
        string memory glowTimes_,
        string memory yakFillColors_,
        string memory hoverColors_,
        string memory iconColor_
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(
            "<style>",
            "@keyframes glow {0% {filter: drop-shadow(16px 16px 20px ",
            initialShadowColors_,
            ") brightness(",
            initialShadowBrightness_,
            "%);}to {filter: drop-shadow(16px 16px 20px ",
            finalShadowColors_,
            ") brightness(",
            finalShadowBrightness_,
            "%);}}path {fill: ",
            baseFillColors_,
            ";animation: glow ",
            glowTimes_,
            "s ease-in-out infinite alternate}.yak {fill: ",
            yakFillColors_,
            ";}.yak:hover {fill: ",
            hoverColors_,
            ";}.icon {fill: ",
            iconColor_,
            ";}</style>"
        );
    }

    function _getHoverText(string memory text_, string memory fontSize_, string memory location_)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(
            "<text text-anchor=",
            location_,
            ' font-family="Helvetica" font-size="',
            fontSize_,
            '" fill="white">',
            text_,
            "</text>"
        );
    }

    function _getIcon(string memory path_, string memory iconSize_) internal pure returns (bytes memory) {
        string memory iconLocation_ = " x=\"5%\" y=\"5%\" ";
        //TODO: open path into string
        return abi.encodePacked("<svg ", iconSize_, iconLocation_, "> ", path_, "</svg>");
    }

    function _weightedImageGenerator(uint256 seed_) private view returns (Image memory image_) {
        uint256 totalWeight_;
        for (uint256 i_ = 0; i_ < _imageMetadata.length; i_++) {
            totalWeight_ += uint256(_imageMetadata[i_].weight);
            if (seed_ < (uint256(int256(-1)) / 100) * totalWeight_) {
                bytes memory data_ = _read(bytes32(keccak256(abi.encode(i_))));

                image_ = abi.decode(ZLib(_zlib).inflate(data_, _imageMetadata[i_].decompressedSize), (Image));

                return image_;
            }
        }

        // TODO abort
    }

    function _weightedIconGenerator(uint256 seed_) private view returns (Icon memory icon_) {
        uint256 totalWeight_;
        for (uint256 i_ = 0; i_ < _iconMetadata.length; i_++) {
            totalWeight_ += uint256(_iconMetadata[i_].weight);
            if (seed_ < (uint256(int256(-1)) / 100) * totalWeight_) {
                bytes memory data_ = _read(bytes32(keccak256(abi.encode(i_ + MEMORY_OFFSET))));

                icon_ = abi.decode(ZLib(_zlib).inflate(data_, _iconMetadata[i_].decompressedSize), (Icon));

                return icon_;
            }
        }

        // TODO abort
    }

    function _weightedRarityGenerator(ValueTrait[] memory traits_, uint256 seed_)
        private
        pure
        returns (string memory trait_)
    {
        uint256 totalWeight_ = 0;
        for (uint256 i_ = 0; i_ < traits_.length; i_++) {
            totalWeight_ += traits_[i_].weight;
            if (seed_ < (uint256(int256(-1)) / 100) * totalWeight_) {
                return traits_[i_].value;
            }
        }

        trait_ = traits_[traits_.length - 1].value;
    }
}
