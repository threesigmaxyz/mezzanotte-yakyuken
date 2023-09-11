// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import { console } from "@forge-std/console.sol";
import { Vm } from "@forge-std/Vm.sol";

import { OnChainNFT } from "src/OnChainNFT.sol";

library Helpers {    
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function upload(bytes memory image_, string memory svgName_, uint256 weight_, OnChainNFT onChainNFT_) internal {
        uint256 initGas_ = gasleft();
        onChainNFT_.uploadNFT(image_, weight_);
        string memory message_ = string(abi.encodePacked("upload gas cost of: ", svgName_));
        console.log(message_, initGas_ - gasleft());
    }

    function getImagesAndWeights() internal view returns (bytes[] memory images_, uint256[] memory weights_) {
        string memory amiSVGPath_ = vm.readFile("svgPaths/ami.svg");
        string memory christineSVGPath_ = vm.readFile("svgPaths/christine.svg");
        string memory takechiSVGPath_ = vm.readFile("svgPaths/takechi.svg");
        string memory tennismallSVGPath_ = vm.readFile("svgPaths/tennissmall.svg");
        string memory yak2SVGPath_ = vm.readFile("svgPaths/yak2.svg");

        images_ = new bytes[](5);
        images_[0] = abi.encode(OnChainNFT.Image(amiSVGPath_, "0 0 300 500", "36", "Ami"));
        images_[1] = abi.encode(OnChainNFT.Image(christineSVGPath_, "0 0 500 470", "36", "Christine"));
        images_[2] = abi.encode(OnChainNFT.Image(takechiSVGPath_, "0 0 700 800", "60", "Takechi"));
        images_[3] = abi.encode(OnChainNFT.Image(tennismallSVGPath_, "0 0 320 210", "14", "Tennis")); // 0 0 320 210 -- 0 0 400 370
        images_[4] = abi.encode(OnChainNFT.Image(yak2SVGPath_, "0 0 230 300", "20", "Yakyuken"));

        weights_ = new uint256[](5);
        weights_[0] = type(uint256).max / 5;
        weights_[1] = type(uint256).max / 5;
        weights_[2] = type(uint256).max / 5;
        weights_[3] = type(uint256).max / 5;
        weights_[4] = type(uint256).max / 5;
    }

    function getEncodedTraits() internal pure returns (bytes memory) {
        OnChainNFT.Trait[] memory colorTraits_ = new OnChainNFT.Trait[](14);
        colorTraits_[0] = OnChainNFT.Trait("brown", type(uint256).max / 14);
        colorTraits_[1] = OnChainNFT.Trait("black", type(uint256).max / 14);
        colorTraits_[2] = OnChainNFT.Trait("aquamarine", type(uint256).max / 14);
        colorTraits_[3] = OnChainNFT.Trait("purple", type(uint256).max / 14);
        colorTraits_[4] = OnChainNFT.Trait("orange", type(uint256).max / 14);
        colorTraits_[5] = OnChainNFT.Trait("white", type(uint256).max / 14);
        colorTraits_[6] = OnChainNFT.Trait("lime", type(uint256).max / 14);
        colorTraits_[7] = OnChainNFT.Trait("red", type(uint256).max / 14);
        colorTraits_[8] = OnChainNFT.Trait("blue", type(uint256).max / 14);
        colorTraits_[9] = OnChainNFT.Trait("yellow", type(uint256).max / 14);
        colorTraits_[10] = OnChainNFT.Trait("green", type(uint256).max / 14);
        colorTraits_[11] = OnChainNFT.Trait("pink", type(uint256).max / 14);
        colorTraits_[12] = OnChainNFT.Trait("coral", type(uint256).max / 14);
        colorTraits_[13] = OnChainNFT.Trait("lavender", type(uint256).max / 14);

        OnChainNFT.Trait[] memory glowTimeTraits_ = new OnChainNFT.Trait[](3);
        glowTimeTraits_[0] = OnChainNFT.Trait("0.3", type(uint256).max / 3);
        glowTimeTraits_[1] = OnChainNFT.Trait("2", type(uint256).max / 3);
        glowTimeTraits_[2] = OnChainNFT.Trait("9", type(uint256).max / 3);

        OnChainNFT.Trait[] memory textLocationTraits_ = new OnChainNFT.Trait[](4);
        textLocationTraits_[0] = OnChainNFT.Trait('"start" x="5%" y="10%"', type(uint256).max / 4);
        textLocationTraits_[1] = OnChainNFT.Trait('"end" x="95%" y="90%"', type(uint256).max / 4);
        textLocationTraits_[2] = OnChainNFT.Trait('"end" x="95%" y="10%"', type(uint256).max / 4);
        textLocationTraits_[3] = OnChainNFT.Trait('"start" x="5%" y="90%"', type(uint256).max / 4);

        OnChainNFT.Trait[] memory textTraits_ = new OnChainNFT.Trait[](3);
        textTraits_[0] = OnChainNFT.Trait("\xE7\x9F\xB3", type(uint256).max / 3);
        textTraits_[1] = OnChainNFT.Trait("\xE7\xB4\x99", type(uint256).max / 3);
        textTraits_[2] = OnChainNFT.Trait("\xE3\x81\xAF\xE3\x81\x95\xE3\x81\xBF", type(uint256).max / 3);

        OnChainNFT.Traits memory traits_ = OnChainNFT.Traits(
            colorTraits_, // backgroundColors
            colorTraits_, // initialShadowColors
            colorTraits_, // finalShadowColors
            colorTraits_, // baseFillColors
            glowTimeTraits_, // glowTimes
            colorTraits_, // yakFillColors
            colorTraits_, // hoverColors
            textLocationTraits_, // textLocations
            textTraits_ // texts
        );

        return abi.encode(traits_);
    }
}