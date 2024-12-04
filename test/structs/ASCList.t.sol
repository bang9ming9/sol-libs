// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ASCList} from "../../src/structs/ASCList.sol";

contract ASCListTest is Test {
    using ASCList for ASCList.B32;

    ASCList.B32 private _list;

    function testFuzz_asc(bytes32[] memory data, uint256 count) external {
        vm.assume(count > 10);

        uint256 length = data.length;
        for (uint256 i = 0; i < length; i++) {
            bytes32 d = data[0];
            if (d != 0) _list.push(d);
        }
        vm.assume(!_list.empty());

        _check_asc(_list.values());

        uint256 seed = uint256(keccak256(abi.encode(0, count)));

        while (!_list.empty()) {
            if (count == 0) break;
            --count;

            bytes32 d = _list.at(seed % _list.length());
            seed = uint256(keccak256(abi.encode(seed, count)));

            _list.remove(d);
            _check_asc(_list.values());
        }
    }

    function _check_asc(bytes32[] memory values) private pure {
        bytes32 current = 0;
        for (uint256 i = 0; i < values.length; i++) {
            bytes32 value = values[i];
            assertTrue(current < value);
            current = value;
        }
    }
}
