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

    bytes32 private constant METADATA_POINTER = bytes32(keccak256("metadata"));

    address private immutable _zlib;

    ImageMetadata[] private _imageMetadata;

    struct Image {
        string path;
        string viewBox;
        string fontSize;
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

    struct Metadata {
        ValueTrait[] backgroundColors;
        ValueTrait[] baseFillColors;
        ValueTrait[] finalShadowColors;
        ValueTrait[] glowTimes;
        ValueTrait[] hoverColors;
        ValueTrait[] initialShadowColors;
        ValueTrait[] textLocations;
        ValueTrait[] texts;
        ValueTrait[] yakFillColors;
    }

    constructor(address zlib_) ERC721("Yakyuken", "YNFT") Ownable(msg.sender)
    {
        _zlib = zlib_;
    }

    // TODO only callable once by the deployer.
    function initialize(
        bytes calldata metadata_,
        bytes[] calldata images_,
        uint128[] calldata decompressedSizes_
    ) external {
        _write(METADATA_POINTER, metadata_);
        
        uint256 imageCount_ = images_.length;
        for (uint256 i_; i_ < imageCount_; i_++) {
            _write(bytes32(keccak256(abi.encode(i_))), images_[i_]);
            _imageMetadata.push(ImageMetadata(
                decompressedSizes_[i_],
                uint128(100 / images_.length)));   // TODO pass as init argument
        }
    }

    function tokenURI(uint256 tokenId_) public view override returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Yakyuken #', tokenId_.toString(),
            '", "description": "',
            "Yakyuken NFT on-chain collection.",
            '", "image_data": "',
            string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(_readSVG(tokenId_)))),
            '"',
            "}"
        );
        
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function readSVG(uint256 tokenId_) external view returns (string memory svg_) {
        svg_ = string(_readSVG(tokenId_));
    }

    function _readSVG(uint256 tokenId_) internal view returns (bytes memory) {
        Metadata memory metadata_ = abi.decode(_read(METADATA_POINTER), (Metadata));
        Image memory image_ = _weightedImageGenerator(uint256(keccak256(abi.encodePacked(tokenId_, "img"))));

        return abi.encodePacked(
            _getHeader(
                image_.viewBox,
                _weightedRarityGenerator(metadata_.backgroundColors, uint256(keccak256(abi.encodePacked(tokenId_, "bg"))))
            ),
            _getStyleHeader(
                _weightedRarityGenerator(metadata_.initialShadowColors, uint256(keccak256(abi.encodePacked(tokenId_, "isc")))),
                _weightedRarityGenerator(metadata_.finalShadowColors, uint256(keccak256(abi.encodePacked(tokenId_, "fsc")))),
                _weightedRarityGenerator(metadata_.baseFillColors, uint256(keccak256(abi.encodePacked(tokenId_, "bfc")))),
                _weightedRarityGenerator(metadata_.glowTimes, uint256(keccak256(abi.encodePacked(tokenId_, "gt")))),
                _weightedRarityGenerator(metadata_.yakFillColors, uint256(keccak256(abi.encodePacked(tokenId_, "yfc")))),
                _weightedRarityGenerator(metadata_.hoverColors, uint256(keccak256(abi.encodePacked(tokenId_, "hc"))))),
            image_.path,
            _getHoverText(
                _weightedRarityGenerator(metadata_.texts, uint256(keccak256(abi.encodePacked(tokenId_, "t")))),
                image_.fontSize,
                _weightedRarityGenerator(metadata_.textLocations, uint256(keccak256(abi.encodePacked(tokenId_, "tl"))))),
            "</svg>"
        );
    }

    function _getHeader(
        string memory viewBox_,
        string memory backgroundColor_
    ) internal view returns (bytes memory) {
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
        string memory baseFillColors_,
        string memory glowTimes_,
        string memory yakFillColors_,
        string memory hoverColors_
    ) internal view returns (bytes memory) {
        return abi.encodePacked(
            "<style>",
            "@keyframes glow {0% {filter: drop-shadow(16px 16px 20px ",
            initialShadowColors_,
            ") brightness(100%);}to {filter: drop-shadow(16px 16px 20px ",
            finalShadowColors_,
            ") brightness(200%);}}path {fill: ",
            baseFillColors_,
            ";animation: glow ",
            glowTimes_,
            "s ease-in-out infinite alternate}.yak {fill: ",
            yakFillColors_,
            ";}.yak:hover {fill: ",
            hoverColors_,
            ";}</style>"
        );
    }

    function _getHoverText(
        string memory text_,
        string memory fontSize_,
        string memory location_
    ) internal view returns (bytes memory) {
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

    function _weightedImageGenerator(uint256 seed_) private view returns (Image memory image_) {
        uint256 totalWeight_;
        for (uint256 i_ = 0; i_ < _imageMetadata.length; i_++) {
            totalWeight_ += uint256(_imageMetadata[i_].weight);
            if (seed_ < (uint256(int(-1)) / 100) * totalWeight_) {
                bytes memory data_ = _read(bytes32(keccak256(abi.encode(i_))));

                image_ = abi.decode(ZLib(_zlib).inflate(data_, _imageMetadata[i_].decompressedSize), (Image));
                
                return image_;
            }
        }

        // TODO abort
    }

    function _weightedRarityGenerator(
        ValueTrait[] memory traits_, uint256 seed_
    ) private view returns (string memory trait_) {
        uint256 totalWeight_ = 0;
        for (uint256 i_ = 0; i_ < traits_.length; i_++) {
            totalWeight_ += traits_[i_].weight;
            if (seed_ < (uint256(int(-1)) / 100) * totalWeight_) {
                return traits_[i_].value;
            }
        }

        trait_ = traits_[traits_.length - 1].value;
    }
}