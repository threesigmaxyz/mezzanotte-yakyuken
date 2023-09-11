// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "@forge-std/Script.sol";
import { console2 } from "@forge-std/console2.sol";

import { Strings } from "@openzeppelin/utils/Strings.sol";

import { ZipUtils } from "../common/ZipUtils.sol";

import { Yakyuken } from "../src/Yakyuken.sol";
import { ZLib } from "../src/zip/ZLib.sol";

contract GenerateScript is Script {
    Yakyuken private _yakyuken;

    function setUp() public {
        _yakyuken = new Yakyuken(address(new ZLib()));
    }

    function run() public {        
    }
}