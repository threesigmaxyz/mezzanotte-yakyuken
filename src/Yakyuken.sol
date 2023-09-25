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

    uint16 private constant MEMORY_OFFSET = 100;

    address private immutable _zlib;

    uint128[] private _imageMetadata;
    uint128[] private _iconMetadata;
    bytes7[] private _imageTraits;

    bool[4] private _initialized;
    address private _saleContract;

    struct Image {
        string path;
        string viewBox;
        string fontSize;
        string iconSize;
        string name;
    }

    ///@dev must be in alphabetical order
    struct Icon {
        string color;
        string name;
        string path;
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
        string[] backgroundColors;
        string[] baseFillColors;
        string[] finalShadowBrightness;
        string[] finalShadowColors;
        string[] glowTimes;
        string[] initialShadowBrightness;
        string[] initialShadowColors;
        string[] texts;
        string[] yakFillColors;
        string[] yakHoverColors;
    }

    error OutOfBondsTraitValueError(string trait);
    error AlreadyInitializedError();
    error NotSaleContractError();

    modifier initialize(uint256 id_) {
        if (_initialized[id_]) revert AlreadyInitializedError();
        _initialized[id_] = true;
        _;
    }

    modifier onlySale() {
        if (msg.sender != _saleContract) revert NotSaleContractError();
        _;
    }

    constructor(address zlib_) ERC721("Yakyuken", "YNFT") Ownable(msg.sender) {
        _zlib = zlib_;
    }

    function initializeMetadata(bytes calldata metadata_, bytes7[] memory imageTraits_)
        external
        onlyOwner
        initialize(0)
    {
        _write(METADATA_POINTER, metadata_);
        _imageTraits = imageTraits_;
    }

    function initializeImages(bytes[] calldata images_, uint128[] calldata decompressedSizes_)
        external
        onlyOwner
        initialize(1)
    {
        uint256 imageCount_ = images_.length;
        for (uint256 i_; i_ < imageCount_; i_++) {
            _write(bytes32(keccak256(abi.encode(i_))), images_[i_]);
            _imageMetadata.push(decompressedSizes_[i_]);
        }
    }

    ///@dev  must be called after initializeImages().
    function initializeImagesHardcoded(
        bytes[] calldata images_,
        uint128[] calldata decompressedSizes_,
        uint256 totalImages_
    ) external onlyOwner initialize(2) {
        uint256 imageCount_ = totalImages_ - images_.length;
        for (uint256 i_; i_ < images_.length; i_++) {
            _write(bytes32(keccak256(abi.encode(i_ + imageCount_))), images_[i_]);
            _imageMetadata.push(decompressedSizes_[i_]);
        }
    }

    function initializeIcons(bytes[] calldata icons_, uint128[] calldata decompressedSizesIcons_)
        external
        onlyOwner
        initialize(3)
    {
        uint256 iconCount_ = icons_.length;
        for (uint256 j_; j_ < iconCount_; j_++) {
            _write(bytes32(keccak256(abi.encode(j_ + MEMORY_OFFSET))), icons_[j_]);
            _iconMetadata.push(decompressedSizesIcons_[j_]); // TODO pass as init argument
        }
    }

    function tokenURI(uint256 tokenId_) public view override returns (string memory) {
        MetadataBytes memory data_ = processMetadataAsBytes(_imageTraits[tokenId_]);
        Metadata memory metadata_ = abi.decode(_read(METADATA_POINTER), (Metadata));

        Image memory image_ = abi.decode(
            ZLib(_zlib).inflate(_read(bytes32(keccak256(abi.encode(data_.yak)))), _imageMetadata[data_.yak]), (Image)
        );

        Icon memory icon_ = abi.decode(
            ZLib(_zlib).inflate(
                _read(bytes32(keccak256(abi.encode(data_.icon + MEMORY_OFFSET)))), _iconMetadata[data_.icon]
            ),
            (Icon)
        );

        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Yakyuken #',
            tokenId_.toString(),
            '", "description": "',
            "Yakyuken NFT on-chain collection.",
            '", "image_data": "',
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,", Base64.encode(_generateSVGfromBytes(data_, metadata_, image_, icon_))
                )
            ),
            '",',
            _getAttributes(data_, metadata_, image_.name, icon_.name),
            "}"
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function generateSVGfromBytes(uint256 tokenId_) external view returns (string memory svg_) {
        MetadataBytes memory data_ = processMetadataAsBytes(_imageTraits[tokenId_]);
        Metadata memory metadata_ = abi.decode(_read(METADATA_POINTER), (Metadata));

        Image memory image_ = abi.decode(
            ZLib(_zlib).inflate(_read(bytes32(keccak256(abi.encode(data_.yak)))), _imageMetadata[data_.yak]), (Image)
        );

        Icon memory icon_ = abi.decode(
            ZLib(_zlib).inflate(
                _read(bytes32(keccak256(abi.encode(data_.icon + MEMORY_OFFSET)))), _iconMetadata[data_.icon]
            ),
            (Icon)
        );
        svg_ = string(_generateSVGfromBytes(data_, metadata_, image_, icon_));
    }

    function processMetadataAsBytes(bytes7 metadataInfo_) public view returns (MetadataBytes memory data_) {
        Metadata memory metadata_ = abi.decode(_read(METADATA_POINTER), (Metadata));

        data_.glowTimes = uint8(metadataInfo_[0]);
        if (data_.glowTimes > metadata_.glowTimes.length) revert OutOfBondsTraitValueError("glowTimes");

        data_.backgroundColors = uint8(metadataInfo_[1]);
        if (data_.backgroundColors > metadata_.backgroundColors.length) {
            revert OutOfBondsTraitValueError("backgroundColors");
        }

        data_.yakHoverColors = uint8(metadataInfo_[2] >> 4);
        if (data_.yakHoverColors > metadata_.yakHoverColors.length) revert OutOfBondsTraitValueError("yakHoverColors");

        data_.finalShadowColors = uint8(metadataInfo_[2] & 0x0F);
        if (data_.finalShadowColors > metadata_.finalShadowColors.length) {
            revert OutOfBondsTraitValueError("finalShadowColors");
        }

        data_.baseFillColors = uint8(metadataInfo_[3] >> 4);
        if (data_.baseFillColors > metadata_.baseFillColors.length) revert OutOfBondsTraitValueError("baseFillColors");

        data_.yakFillColors = uint8(metadataInfo_[3] & 0x0F);
        if (data_.yakFillColors > metadata_.yakFillColors.length) revert OutOfBondsTraitValueError("yakFillColors");

        data_.yak = uint8(metadataInfo_[4] >> 4);
        if (data_.yak > _imageMetadata.length) revert OutOfBondsTraitValueError("yak/character");

        data_.initialShadowColors = uint8(metadataInfo_[4] & 0x0F);
        if (data_.initialShadowColors > metadata_.initialShadowColors.length) {
            revert OutOfBondsTraitValueError("initialShadowColors");
        }

        data_.initialShadowBrightness = uint8(metadataInfo_[5] >> 4);
        if (data_.initialShadowBrightness > metadata_.initialShadowBrightness.length) {
            revert OutOfBondsTraitValueError("initialShadowBrightness");
        }

        data_.finalShadowBrightness = uint8(metadataInfo_[5] & 0x0F);
        if (data_.finalShadowBrightness > metadata_.finalShadowBrightness.length) {
            revert OutOfBondsTraitValueError("finalShadowBrightness");
        }

        data_.icon = uint8(metadataInfo_[6] >> 4);
        if (data_.icon > _iconMetadata.length) revert OutOfBondsTraitValueError("icon");

        data_.texts = uint8(metadataInfo_[6] & 0x0F);
        if (data_.texts > metadata_.texts.length) revert OutOfBondsTraitValueError("texts");
    }

    function mint(address to_, uint256 tokenId_) external onlySale {
        _mint(to_, tokenId_);
    }

    function setSaleContract(address sale_) external onlyOwner {
        _saleContract = sale_;
    }

    function _generateSVGfromBytes(
        MetadataBytes memory data_,
        Metadata memory metadata_,
        Image memory image_,
        Icon memory icon_
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(
            _getHeader(image_.viewBox, metadata_.backgroundColors[data_.backgroundColors]),
            _getStyleHeader(
                metadata_.initialShadowColors[data_.initialShadowColors],
                metadata_.finalShadowColors[data_.finalShadowColors],
                metadata_.initialShadowBrightness[data_.initialShadowBrightness],
                metadata_.finalShadowBrightness[data_.finalShadowBrightness],
                metadata_.baseFillColors[data_.baseFillColors],
                metadata_.glowTimes[data_.glowTimes],
                metadata_.yakFillColors[data_.yakFillColors],
                metadata_.yakHoverColors[data_.yakHoverColors],
                metadata_.yakFillColors[data_.yakFillColors]
            ),
            image_.path,
            _getIcon(icon_.path, image_.iconSize),
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
            "s ease-in-out infinite alternate;}.yak {fill: ",
            yakFillColors_,
            ";}.yak:hover {fill: ",
            hoverColors_,
            ";}.icon {fill: ",
            iconColor_,
            ";}</style>"
        );
    }

    function _getIcon(string memory path_, string memory iconSize_) internal pure returns (bytes memory) {
        string memory iconLocation_ = " x=\"5%\" y=\"5%\" ";
        return abi.encodePacked("<svg ", iconSize_, iconLocation_, "> ", path_, "</svg>");
    }

    function _getAttributes(
        MetadataBytes memory data_,
        Metadata memory metadata_,
        string memory imageName_,
        string memory iconName_
    ) internal pure returns (string memory) {
        return (
            string(
                abi.encodePacked(
                    ' "attributes" : [{ "trait_type": "Character", "value":"',
                    imageName_,
                    '" },  { "trait_type": "Icon", "value": "',
                    iconName_,
                    '"},  { "trait_type": "Background Color", "value": "',
                    metadata_.backgroundColors[data_.backgroundColors],
                    '" }, { "trait_type": "Initial Shadow Color", "value":"',
                    metadata_.initialShadowColors[data_.initialShadowColors],
                    '" }, { "trait_type": "Initial Shadow Brightness", "value":"',
                    metadata_.initialShadowBrightness[data_.initialShadowBrightness],
                    '" }, { "trait_type": "Final Shadow Color ", "value":"',
                    metadata_.finalShadowColors[data_.finalShadowColors],
                    '" }, { "trait_type": "Final Shadow Brightness", "value":"',
                    metadata_.finalShadowBrightness[data_.finalShadowBrightness],
                    '" }, { "trait_type": "Base Fill Colors", "value":"',
                    metadata_.baseFillColors[data_.baseFillColors],
                    '" }, { "trait_type": "Glow Times", "value":"',
                    metadata_.glowTimes[data_.glowTimes],
                    '" }, { "trait_type": "Yak Fill Colors", "value":"',
                    metadata_.yakFillColors[data_.yakFillColors],
                    '" }, { "trait_type": "Hover Colors", "value":"',
                    metadata_.yakHoverColors[data_.yakHoverColors],
                    '" }, { "trait_type": "Rock, Paper, Scissors", "value":"',
                    metadata_.texts[data_.texts],
                    '"} ]'
                )
            )
        );
    }
}
