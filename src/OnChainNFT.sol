// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721URIStorage } from "@openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";
import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";
import { Base64 } from "@openzeppelin/utils/Base64.sol";
import { Strings } from "@openzeppelin/utils/Strings.sol";
import { Ownable } from "@openzeppelin/access/Ownable.sol";
import { SSTORE2 } from "@solmate/src/utils/SSTORE2.sol";
import { console } from "@forge-std/console.sol";

contract OnChainNFT is ERC721URIStorage, Ownable {
    using Strings for uint256;

    struct Image {
        string path;
        string viewBox;
        string fontSize;
        string name;
    }

    struct Trait {
        string trait;
        uint256 weight;
    }

    struct ImageTrait {
        address[] trait;
        uint256 weight;
    }

    struct Traits {
        Trait[] backgroundColors;
        Trait[] initialShadowColors;
        Trait[] finalShadowColors;
        Trait[] baseFillColors;
        Trait[] glowTimes;
        Trait[] yakFillColors;
        Trait[] hoverColors;
        Trait[] textLocations;
        Trait[] texts;
    }

    ImageTrait[] public images;

    event Uint(uint256);

    address public immutable traitsPointer;
    uint256 constant MAX_STORAGE = 24_576 - 1; // 1 extra by for stop opcode

    constructor(bytes memory traits_) Ownable(msg.sender) ERC721("OnChainNFT", "OCNFT") {
        traitsPointer = SSTORE2.write(traits_);
        //NOTE: NFTs cannot be upload in the constructor because constructor is unable to take calldata as an argument and splicing arrays requires a calldata array
    }

    function uploadNFT(bytes calldata svg_, uint256 weight_) external onlyOwner {
        address[] memory svgAddresses_ = new address[](svg_.length/MAX_STORAGE + 1);
        for (uint256 i_; i_ < svgAddresses_.length; i_++) {
            svgAddresses_[i_] = SSTORE2.write(
                svg_[i_ * MAX_STORAGE:svg_.length > (i_ + 1) * MAX_STORAGE ? (i_ + 1) * MAX_STORAGE : svg_.length]
            );
        }
        images.push(ImageTrait(svgAddresses_, weight_));
    }

    function tokenURI(uint256 tokenId_) public view override returns (string memory) {
        (Image memory image_, uint256 seed_) = rebuildImage(tokenId_);
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "TestNFT #',
            tokenId_.toString(),
            '", "description": "',
            image_.name,
            '", "image_data": "',
            string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(generateSVG(seed_, image_)))),
            '"',
            "}"
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function rebuildImage(uint256 tokenId_) public view returns (Image memory image_, uint256 seed_) {
        // Rebuild image in the Image struct corresponding to a tokenId_
        address[] memory imagePointers_;

        // Get contract addresses and seed to reconstruct svg image
        (imagePointers_, seed_) = _getTraitFromSeedImage(images, tokenId_);
        bytes memory imageBytes_;
        for (uint256 i_; i_ < imagePointers_.length; i_++) {
            imageBytes_ = bytes.concat(imageBytes_, SSTORE2.read(imagePointers_[i_]));
        }

        // Decode image from bytes to the struct
        image_ = abi.decode(imageBytes_, (Image));
    }

    function generateSVG(uint256 seed_, Image memory image_) public view returns (bytes memory) {
        Traits memory traits_ = abi.decode(SSTORE2.read(traitsPointer), (Traits));

        string[] memory info_ = new string[](9);

        string memory aux_;
        (aux_, seed_) = _getTraitFromSeed(traits_.backgroundColors, seed_);
        info_[0] = aux_;
        (aux_, seed_) = _getTraitFromSeed(traits_.initialShadowColors, seed_);
        info_[1] = aux_;
        (aux_, seed_) = _getTraitFromSeed(traits_.finalShadowColors, seed_);
        info_[2] = aux_;
        (aux_, seed_) = _getTraitFromSeed(traits_.baseFillColors, seed_);
        info_[3] = aux_;
        (aux_, seed_) = _getTraitFromSeed(traits_.glowTimes, seed_);
        info_[4] = aux_;
        (aux_, seed_) = _getTraitFromSeed(traits_.yakFillColors, seed_);
        info_[5] = aux_;
        (aux_, seed_) = _getTraitFromSeed(traits_.hoverColors, seed_);
        info_[6] = aux_;
        (aux_, seed_) = _getTraitFromSeed(traits_.textLocations, seed_);
        info_[7] = aux_;
        (aux_, seed_) = _getTraitFromSeed(traits_.texts, seed_);
        info_[8] = aux_;

        bytes memory svg_ = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet" viewBox="',
            image_.viewBox,
            '" style="background-color:',
            info_[0],
            '">',
            _getStyleHeader(info_[1], info_[2], info_[3], info_[4], info_[5], info_[6]),
            image_.path,
            _getHoverText(info_[8], image_.fontSize, info_[7]),
            "</svg>"
        );

        return svg_;
    }

    function _getStyleHeader(
        string memory initialShadowColors_,
        string memory finalShadowColors_,
        string memory baseFillColors_,
        string memory glowTimes_,
        string memory yakFillColors_,
        string memory hoverColors_
    ) internal pure returns (bytes memory) {
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

    function _getTraitFromSeed(Trait[] memory traitPossibilities_, uint256 seed_)
        internal
        pure
        returns (string memory trait_, uint256 newSeed_)
    {
        newSeed_ = uint256(keccak256(abi.encodePacked(seed_)));

        uint256 totalWeight_ = 0;
        for (uint256 i_ = 0; i_ < traitPossibilities_.length; i_++) {
            totalWeight_ += traitPossibilities_[i_].weight;
            if (totalWeight_ > newSeed_) {
                return (traitPossibilities_[i_].trait, newSeed_);
            }
        }
        trait_ = traitPossibilities_[traitPossibilities_.length].trait;
    }

    function _getTraitFromSeedImage(ImageTrait[] memory traitPossibilities_, uint256 seed_)
        internal
        pure
        returns (address[] memory trait_, uint256 newSeed_)
    {
        newSeed_ = uint256(keccak256(abi.encodePacked(seed_)));

        uint256 totalWeight_ = 0;
        for (uint256 i_ = 0; i_ < traitPossibilities_.length; i_++) {
            totalWeight_ += traitPossibilities_[i_].weight;
            if (totalWeight_ > newSeed_) {
                return (traitPossibilities_[i_].trait, newSeed_);
            }
        }
        trait_ = traitPossibilities_[traitPossibilities_.length].trait;
    }
}
