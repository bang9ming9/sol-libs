// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./DoubleLinkedList.sol";

library DESCList {
    using DoubleLinkedList for DoubleLinkedList.B32;

    error DESCListPushFailed();
    error DESCListZeroData();

    struct B32 {
        DoubleLinkedList.B32 _inner;
    }

    function empty(B32 storage _list) internal view returns (bool) {
        return _list._inner.empty();
    }

    function length(B32 storage _list) internal view returns (uint256) {
        return _list._inner.length;
    }

    function contains(B32 storage _list, bytes32 _data) internal view returns (bool) {
        if (_data == 0) revert DESCListZeroData();
        return _list._inner.contains(_data);
    }

    function at(B32 storage _list, uint256 _index) internal view returns (bytes32) {
        return _list._inner.at(_index);
    }

    function first(B32 storage _list) internal view returns (bytes32) {
        return _list._inner.head;
    }

    function last(B32 storage _list) internal view returns (bytes32) {
        return _list._inner.tail;
    }

    function values(B32 storage _list) internal view returns (bytes32[] memory) {
        return _list._inner.values();
    }

    function push(B32 storage _list, bytes32 _data, bytes32 _search) internal returns (bool) {
        if (_data == 0) revert DESCListZeroData();

        DoubleLinkedList.B32 storage list = _list._inner;
        if (list.contains(_data)) {
            return false;
        }

        if (_data > list.head) {
            return list.insert(_data, 0);
        } else if (_data < list.tail) {
            return list.insert(_data, list.tail);
        } else {
            bytes32 current = list.contains(_search) ? _search : list.head;
            if (current > _data) {
                while (current != 0) {
                    if (_data > current) {
                        return list.insert(_data, list.nodes[current].prev);
                    }
                    current = list.nodes[current].next;
                }
            } else {
                while (current != 0) {
                    if (_data < current) {
                        return list.insert(_data, current);
                    }
                    current = list.nodes[current].prev;
                }
            }
            revert DESCListPushFailed();
        }
    }

    function push(B32 storage _list, bytes32 _data) internal returns (bool) {
        if (_data == 0) revert DESCListZeroData();
        return push(_list, _data, _list._inner.head);
    }

    function remove(B32 storage _list, bytes32 _data) internal returns (bool) {
        if (_data == 0) revert DESCListZeroData();
        return _list._inner.remove(_data);
    }

    struct U256 {
        B32 _inner;
    }

    function empty(U256 storage _list) internal view returns (bool) {
        return empty(_list._inner);
    }

    function contains(U256 storage _list, uint256 _data) internal view returns (bool) {
        return contains(_list._inner, bytes32(_data));
    }

    function at(U256 storage _list, uint256 _index) internal view returns (uint256) {
        return uint256(at(_list._inner, _index));
    }

    function push(U256 storage _list, uint256 _data) internal returns (bool) {
        return push(_list._inner, bytes32(_data));
    }

    function push(U256 storage _list, uint256 _data, uint256 _search) internal returns (bool) {
        return push(_list._inner, bytes32(_data), bytes32(_search));
    }

    function remove(U256 storage _list, uint256 _data) internal returns (bool) {
        return remove(_list._inner, bytes32(_data));
    }
}
