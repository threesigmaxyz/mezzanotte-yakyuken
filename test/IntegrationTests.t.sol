// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@forge-std/Test.sol";
import { console2 } from "@forge-std/console2.sol";
import { stdJson } from "@forge-std/StdJson.sol";

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { ZipUtils } from "../common/ZipUtils.sol";

import { Yakyuken } from "../src/Yakyuken.sol";
import { ZLib } from "../src/zip/ZLib.sol";
import { Yakyuken } from "src/Yakyuken.sol";
import { MezzanotteSale } from "lib/mezzanote-sale/src/MezzanotteSale.sol";
import { MerkleTreeTest } from "lib/mezzanote-sale/src/dependencies/threesigma-contracts/contracts/foundry-test-helpers/MerkleTreeTestHelper.sol";

contract YakyukenIntegrationTests is MerkleTreeTest {
    using Strings for uint256;
    using stdJson for string;

    event LogSale(uint256 indexed saleId, address indexed to, uint256 quantity);

    Yakyuken private _yakyuken;
    MezzanotteSale private _saleContract;

    address[] private _owners;
    error DifferentValueError(string vl1, string vl2, string loc);

    function setUp() external {
         setMerkleTree("lib/mezzanote-sale/snapshot/Data/OwnersSnapshot.csv");
        _saleContract = MezzanotteSale(0x9cFBEfda7d3dC8F0E55aEA40cc2F4e0e595A9D39);
        _yakyuken = Yakyuken(0xAD908C887ee36A746De5A9496f3fB4053c6317F6);
    }

    function test_integration_test_mintedOutWhitelistPhase() external {
        
        vm.createSelectFork(vm.envString("RPC_URL_GOERLI"));

        uint256 numberOwners_ = 2549;
        for (uint256 i_ = 0; i_ < numberOwners_; i_++){
            _owners.push(vm.parseAddress(vm.readLine("lib/mezzanote-sale/snapshot/Data/OwnersSnapshot.csv")));
        }

        vm.warp(1695746783);

        uint256 maxMint_ = 100; //_saleContract.maxMint();

        vm.prank(_saleContract.owner());
        _saleContract.setMaxMint(maxMint_);

        uint64 price_ = _saleContract.getSale(0).price;
        for (uint256 i_ = 25; i_ < maxMint_; i_++) {
            _saleMint(0, _owners[i_+500], 1, 1, price_, merkleProofs[i_+500]);
        }
        assertEq(_saleContract.nextToMint(), 100);

        vm.expectRevert();
        _saleContract.whitelistSaleMint{ value: price_ }(0, _owners[maxMint_], 1, merkleProofs[maxMint_]);
    }

    function test_integration_test_notMintedOutWhitelistPhase() external {
        vm.createSelectFork(vm.envString("RPC_URL_GOERLI"));

        uint256 numberOwners_ = 2549;
        for (uint256 i_ = 0; i_ < numberOwners_; i_++){
            _owners.push(vm.parseAddress(vm.readLine("lib/mezzanote-sale/snapshot/Data/OwnersSnapshot.csv")));
        }

        vm.warp(1695746783);

        uint256 maxMint_ = 100; //_saleContract.maxMint();

        uint64 price_ = _saleContract.getSale(0).price;
        for (uint256 i_ = 25; i_ < maxMint_; i_++) {
            _saleMint(0, _owners[i_], 1, 1, price_, merkleProofs[i_]);
        }
        assertEq(_saleContract.nextToMint(), 100);

        uint256 newMaxMint_ = 200;

        vm.prank(_saleContract.owner());
        _saleContract.setMaxMint(newMaxMint_);

        vm.warp(_saleContract.getSale(1).start + 1);

        for (uint256 i_ = maxMint_; i_ < newMaxMint_; i_++) {
            _saleMint(1, vm.addr(i_), 0, 1, price_, merkleProofs[i_]);
        }

        assertEq(_saleContract.nextToMint(), newMaxMint_);
        vm.expectRevert();
        _saleContract.publicSaleMint{value: price_ }(1, _owners[newMaxMint_], 1);
    }

    function _compareOutputFromId(uint256 currentTokenId_) internal {
        string memory contractPathFile_ =
            string.concat(string.concat("test/out/", vm.toString(currentTokenId_)), ".svg");

        // Fetch generated svg with the contract code
        string memory contractSvg_ = _yakyuken.generateSVGfromBytes(currentTokenId_);
        vm.writeFile(contractPathFile_, contractSvg_);

        // Fetch generated svg with the svg generator
        string memory pythonPathFile_ =
            string.concat(string.concat("test/python-generated-svg/", currentTokenId_.toString()), ".svg");

        // Prepare output to run script
        string[] memory inputs = new string[](4);
        inputs[0] = "node";
        inputs[1] = "test/compareStrings.js";
        inputs[2] = contractPathFile_;
        inputs[3] = pythonPathFile_;

        // Run script
        bytes memory res = vm.ffi(inputs);

        // Assert outputd
        assertEq(string(res), "true");
    }

    function _compareOutputFromIdSample(uint256 currentTokenId_) internal {
        string memory contractPathFile_ =
            string.concat(string.concat("test/out/", vm.toString(currentTokenId_)), ".svg");

        // Fetch generated svg with the contract code
        string memory contractSvg_ = _yakyuken.generateSVGfromBytes(currentTokenId_);
        vm.writeFile(contractPathFile_, contractSvg_);

        // Fetch generated svg with the svg generator
        string memory pythonPathFile_ = string.concat("test/python-generated-svg/0.svg");

        // Prepare output to run script
        string[] memory inputs = new string[](4);
        inputs[0] = "node";
        inputs[1] = "test/compareStrings.js";
        inputs[2] = contractPathFile_;
        inputs[3] = pythonPathFile_;

        // Run script
        bytes memory res = vm.ffi(inputs);

        // Assert outputd
        assertEq(string(res), "true");
    }

    function _saleMint(
        uint256 saleId_,
        address user_,
        uint256 userAllowance_,
        uint256 quantity_,
        uint64 price_,
        bytes32[] memory proof_
    ) internal {
        // setup
        vm.deal(user_, quantity_ * price_);
        uint256 prevMinted = _saleContract.nextToMint();
        uint256 prevBalance = address(_saleContract).balance;

        uint256 prevUserMinted_ = _saleContract.getMintedAmount(saleId_, user_);
        // sale mint
        vm.expectEmit(true, false, false, true);
        emit LogSale(saleId_, user_, quantity_);
        vm.prank(user_);
        userAllowance_ == 0
            ? _saleContract.publicSaleMint{ value: quantity_ * price_ }(saleId_, user_, quantity_)
            : _saleContract.whitelistSaleMint{ value: quantity_ * price_ }(saleId_, user_, quantity_, proof_);

        // perform assertions
        assertEq(_saleContract.nextToMint(), prevMinted + quantity_);
        assertEq(_saleContract.getMintedAmount(saleId_, user_), quantity_ + prevUserMinted_);
        assertEq(_yakyuken.balanceOf(user_), quantity_ + prevUserMinted_);
        for (uint256 i = 0; i < quantity_; i++) {
            assertEq(_yakyuken.ownerOf(prevMinted + i), user_);
        }
        assertEq(user_.balance, 0);
        assertEq(address(_saleContract).balance, prevBalance + quantity_ * price_);
    }
}
