// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "@forge-std/Script.sol";

import { console } from "@forge-std/console.sol";

import { Base64 } from "@openzeppelin/utils/Base64.sol";

import { OnChainNFT } from "src/OnChainNFT.sol";

import { Helpers } from "common/Helpers.sol";

/// @dev See the "Solidity Scripting" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/tutorials/solidity-scripting?highlight=scripts#solidity-scripting
contract Deploy is Script {
    OnChainNFT onChainNFT;

    function setUp() public {
        // solhint-disable-previous-line no-empty-blocks
    }

    /// @dev You can send multiple transactions inside a single script.
    function run() public {
        vm.startBroadcast();

        // deploy contract

        (bytes[] memory images_, uint256[] memory weights_) = Helpers.getImagesAndWeights();

        uint256 gasLeft = gasleft();
        onChainNFT = new OnChainNFT(Helpers.getEncodedTraits());
        console.log("constructor gas cost: ", gasLeft - gasleft());

        Helpers.upload(images_[0], "ami", weights_[0], onChainNFT);
        Helpers.upload(images_[1], "christine", weights_[1], onChainNFT);
        Helpers.upload(images_[2], "takechi", weights_[2], onChainNFT);
        Helpers.upload(images_[3], "tennismall", weights_[3], onChainNFT);
        Helpers.upload(images_[4], "yak2", weights_[4], onChainNFT);

        vm.stopBroadcast();
    }
}
