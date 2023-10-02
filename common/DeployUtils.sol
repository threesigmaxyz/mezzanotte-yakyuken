// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import { Vm } from "@forge-std/Vm.sol";

import { Yakyuken } from "../src/Yakyuken.sol";

library DeployUtils {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    struct ImageConfig {

    }

    function loadMetadata(string memory path_) internal returns (Yakyuken.Metadata memory metadata_) {
        string memory configData_ = vm.readFile(path_);

        bytes memory metadataDetails_ = configData_.parseRaw(".metadata");
        
        metadata_ = abi.decode(metadataDetails_, (Yakyuken.Metadata));
    }

    function loadImages(string memory path_) internal returns (Yakyuken.Image[] memory images_) {
        
    }
}