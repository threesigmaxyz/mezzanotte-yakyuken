// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { SSTORE2 } from "@solmate/src/utils/SSTORE2.sol";

contract ERC721B {
    mapping(bytes32 => bytes) _data;

    function _write(bytes32 id_, bytes calldata data_) internal {
        _data[id_] = data_;
    }

    function _read(bytes32 id_) internal view returns (bytes memory data_) {
        data_ = _data[id_];
    }
}
