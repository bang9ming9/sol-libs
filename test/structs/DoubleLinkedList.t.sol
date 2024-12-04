// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DoubleLinkedList} from "../../src/structs/DoubleLinkedList.sol";

contract DoubleLinkedListTest is Test {
    using DoubleLinkedList for DoubleLinkedList.B32;

    DoubleLinkedList.B32 public list;

    bytes32[] data;

    function setUp() external {
        data = [
            bytes32(uint256(1)),
            bytes32(uint256(2)),
            bytes32(uint256(3)),
            bytes32(uint256(4)),
            bytes32(uint256(5)),
            bytes32(uint256(6)),
            bytes32(uint256(7)),
            bytes32(uint256(8)),
            bytes32(uint256(9)),
            bytes32(uint256(10))
        ];
    }

    function test_list_push() public {
        // 1. push
        uint256 length = data.length;
        assertEq(length, 10);

        for (uint256 i = 0; i < length; i++) {
            list.push(data[i]);
        }
        // 1-1. check 순서대로 잘 들어가 있는지 확인
        for (uint256 i = 0; i < length; i++) {
            assertEq(list.at(i), data[i]);
        }
    }

    function test_push_zero() public {
        vm.expectRevert(DoubleLinkedList.DoubleLinkedListZeroData.selector);
        list.push(0);
    }

    function test_push_duplicate() public {
        assertEq(0, list.length);
        assertTrue(list.push(data[0]));
        assertEq(1, list.length);
        assertFalse(list.push(data[0]));
        assertEq(1, list.length);
    }

    function test_list_insert() public {
        // set data
        data = [
            bytes32(uint256(1)),
            bytes32(uint256(2)),
            bytes32(uint256(3)),
            bytes32(uint256(4)),
            bytes32(uint256(5)),
            bytes32(uint256(6)),
            bytes32(uint256(7)),
            bytes32(uint256(8)),
            bytes32(uint256(9)),
            bytes32(uint256(10))
        ];
        uint256 length = data.length;
        for (uint256 i = 0; i < length; i++) {
            list.push(data[i]);
        }

        // 1. insert
        // 1-1. insert in the first [change head]
        bytes32 newHead = bytes32(uint256(11));
        list.insert(newHead, 0);
        ++length;
        // check
        {
            assertEq(list.head, newHead);
            assertEq(list.at(0), newHead);
            for (uint256 i = 1; i < length; i++) {
                assertEq(list.at(i), data[i - 1]);
            }
        }

        // 1-2. insert in the middle
        bytes32 middleData = bytes32(uint256(55));
        bytes32 prev = bytes32(uint256(5));
        list.insert(middleData, prev);
        ++length;
        // check
        {
            uint256 index = 0;
            for (uint256 i = 1; i < length; i++) {
                bytes32 at = list.at(i);
                assertEq(at, data[index++]);
                if (at == prev) {
                    assertEq(list.at(++i), middleData);
                }
            }
        }

        // 1-3. insert in the end
        bytes32 newTail = bytes32(uint256(99));
        list.insert(newTail, list.tail);
        ++length;
        // check
        {
            vm.assertEq(list.tail, newTail);
            uint256 index = 0;
            for (uint256 i = 1; i < length - 1; i++) {
                bytes32 at = list.at(i);
                assertEq(at, data[index++]);
                if (at == prev) {
                    assertEq(list.at(++i), middleData);
                }
            }
            assertEq(list.at(length - 1), newTail);
        }
    }

    function test_insert_zero() public {
        vm.expectRevert(DoubleLinkedList.DoubleLinkedListZeroData.selector);
        list.insert(0, 0);
    }

    function test_insert_invalid_prev() public {
        vm.expectRevert(DoubleLinkedList.DoubleLinkedListInvalidPrevNode.selector);
        list.insert(bytes32(uint256(100)), bytes32(uint256(100)));
    }

    function test_insert_duplicate() public {
        assertEq(0, list.length);
        assertTrue(list.insert(data[0], 0));
        assertEq(1, list.length);
        assertFalse(list.insert(data[0], 0));
        assertEq(1, list.length);
    }

    function test_list_remove() public {
        // set data
        data = [
            bytes32(uint256(1)),
            bytes32(uint256(2)),
            bytes32(uint256(3)),
            bytes32(uint256(4)),
            bytes32(uint256(5)),
            bytes32(uint256(6)),
            bytes32(uint256(7)),
            bytes32(uint256(8)),
            bytes32(uint256(9)),
            bytes32(uint256(10))
        ];
        uint256 length = data.length;
        for (uint256 i = 0; i < length; i++) {
            list.push(data[i]);
        }

        // 1. remove
        // 1-1. remove head
        list.remove(list.head);
        --length;
        //check
        {
            assertEq(list.head, data[1]);
            for (uint256 i = 0; i < length; i++) {
                assertEq(list.at(i), data[i + 1]);
            }
        }

        // 1-2. remove middle
        bytes32 middleData = data[length / 2];
        list.remove(middleData);
        --length;
        // check
        {
            uint256 index = 0;
            for (uint256 i = 1; i < data.length; i++) {
                bytes32 d = data[i];
                if (d == middleData) continue;
                bytes32 at = list.at(index++);
                assertEq(at, d);
            }
        }

        // 1-3. remove tail
        list.remove(list.tail);
        --length;
        // check
        {
            assertEq(list.tail, data[data.length - 2]);
            uint256 index = 0;
            for (uint256 i = 1; i < data.length - 1; i++) {
                bytes32 d = data[i];
                if (d == middleData) continue;
                bytes32 at = list.at(index++);
                assertEq(at, d);
            }
        }
    }

    function test_remove_zero() public {
        vm.expectRevert(DoubleLinkedList.DoubleLinkedListZeroData.selector);
        list.remove(0);
    }

    function test_remove_invalid_data() public {
        bytes32 d = bytes32(uint256(100));
        list.push(d);
        assertTrue(list.remove(d));
        assertFalse(list.remove(d));
    }

    function test_list_shift() public {
        // set data
        data = [
            bytes32(uint256(1)),
            bytes32(uint256(2)),
            bytes32(uint256(3)),
            bytes32(uint256(4)),
            bytes32(uint256(5)),
            bytes32(uint256(6)),
            bytes32(uint256(7)),
            bytes32(uint256(8)),
            bytes32(uint256(9)),
            bytes32(uint256(10))
        ];
        uint256 length = data.length;
        for (uint256 i = 0; i < length; i++) {
            list.push(data[i]);
        }

        for (uint256 i = 0; i < length; i++) {
            assertEq(list.shift(), data[i]);
        }
        assertTrue(list.empty());
    }

    function test_invalid_index_empty() external {
        vm.expectRevert(DoubleLinkedList.DoubleLinkedListInvalidIndex.selector);
        list.at(0);
    }

    function test_invalid_index() external {
        list.push(bytes32(uint256(1)));
        vm.expectRevert(DoubleLinkedList.DoubleLinkedListInvalidIndex.selector);
        list.at(1);
    }

    function test_shift_empty() external {
        vm.expectRevert(DoubleLinkedList.DoubleLinkedListZeroData.selector);
        list.shift();
    }
}
