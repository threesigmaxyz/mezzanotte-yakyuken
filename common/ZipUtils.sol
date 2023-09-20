// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import { Vm } from "@forge-std/Vm.sol";
import { console2 } from "@forge-std/console2.sol";

library ZipUtils {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function zip(bytes memory data) internal returns (bytes memory zipped) {
        string memory compressScript = './compress.py';
        if (!_doesFileExist(compressScript, 'text/x-script.python')) {
            compressScript = './lib/zipped-contracts/compress.py';
        }
        string[] memory args = new string[](4);
        args[0] = 'env';
        args[1] = 'python3';
        args[2] = compressScript;
        args[3] = vm.toString(data);
        zipped = vm.ffi(args);

        console.log(string(abi.encodePacked(
            'Compression information:',
            ' Size: ', vm.toString(zipped.length),
            ', Unzipped size: ', vm.toString(data.length),
            ', Compression: ', string(abi.encodePacked(vm.toString(100 - int256(zipped.length * 100 / data.length)), '%'))
        )));
    }

    function _doesFileExist(string memory path, string memory mimeType) private returns (bool) {
        string[] memory args = new string[](4);
        args[0] = 'file';
        args[1] = '--mime-type';
        args[2] = '-b';
        args[3] = path;
        return keccak256(vm.ffi(args)) == keccak256(bytes(mimeType));
    }
}