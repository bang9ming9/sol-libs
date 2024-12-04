// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

library DoubleLinkedList {
    struct Node {
        bytes32 prev;
        bytes32 next;
    }

    struct B32List {
        uint256 length;
        bytes32 head;
        bytes32 tail;
        mapping(bytes32 => Node) nodes;
    }

    function empty(B32List storage _list) internal view returns (bool) {
        return _list.length == 0;
    }

    function contains(B32List storage _list, bytes32 _data) internal view returns (bool) {
        if (_data == 0) revert("1"); // todo
        return _data == _list.head || _linked(_list.nodes[_data]);
    }

    function _linked(Node memory node) private pure returns (bool) {
        return node.prev != 0 || node.next != 0;
    }

    function at(B32List storage _list, uint256 _index) internal view returns (bytes32) {
        if (_index >= _list.length) revert();

        bytes32 data = _list.head;
        for (uint256 i = 0; i < _index; i++) {
            data = _list.nodes[data].next;
        }
        return data;
    }

    function values(B32List storage _list) internal view returns (bytes32[] memory) {
        bytes32[] memory result = new bytes32[](_list.length);
        uint256 length = _list.length;
        bytes32 data = _list.head;
        for (uint256 i = 0; i < length; i++) {
            result[i] = data;
            data = _list.nodes[data].next;
        }
        return result;
    }

    function insert(B32List storage _list, bytes32 _data, bytes32 _prev) internal returns (bool) {
        if (contains(_list, _data)) return false;

        Node storage prevNode = _list.nodes[_prev];
        Node memory newNode;

        if (_prev == 0) {
            // change head
            bytes32 _head = _list.head;
            _list.head = _data;

            if (_head != 0) _list.nodes[_head].prev = _data;
            newNode = Node({prev: 0, next: _head});
        } else {
            if (!(_linked(prevNode) || _prev == _list.head)) revert("1"); // invalid prev node
            newNode = Node({prev: _prev, next: prevNode.next});
            prevNode.next = _data;
        }

        if (newNode.next == 0) {
            _list.tail = _data;
        }

        _list.nodes[_data] = newNode;
        ++_list.length;

        return true;
    }

    function push(B32List storage _list, bytes32 _data) internal returns (bool) {
        return insert(_list, _data, _list.tail);
    }

    function remove(B32List storage _list, bytes32 _data) internal returns (bool) {
        if (!contains(_list, _data)) return false;

        Node storage node = _list.nodes[_data];
        Node storage prevNode = _list.nodes[node.prev];
        Node storage nextNode = _list.nodes[node.next];

        prevNode.next = node.next;
        nextNode.prev = node.prev;

        if (_list.head == _data) {
            _list.head = node.next;
        }
        if (_list.tail == _data) {
            _list.tail = node.prev;
        }

        delete _list.nodes[_data];
        --_list.length;

        return true;
    }

    function shift(B32List storage _list) internal returns (bytes32) {
        if (_list.length == 0) return 0;

        bytes32 data = _list.head;
        if (!remove(_list, data)) revert();
        return data;
    }

    struct U256List {
        B32List _inner;
    }

    function empty(U256List storage _list) internal view returns (bool) {
        return empty(_list._inner);
    }

    function contains(U256List storage _list, uint256 _data) internal view returns (bool) {
        return contains(_list._inner, bytes32(_data));
    }

    function at(U256List storage _list, uint256 _index) internal view returns (uint256) {
        return uint256(at(_list._inner, _index));
    }

    function values(U256List storage _list) internal view returns (uint256[] memory) {
        bytes32[] memory b32Values = values(_list._inner);
        uint256[] memory result;
        assembly {
            result := b32Values
        }
        return result;
    }

    function insert(U256List storage _list, uint256 _data, uint256 _prev) internal returns (bool) {
        return insert(_list._inner, bytes32(_data), bytes32(_prev));
    }

    function push(U256List storage _list, uint256 _data) internal returns (bool) {
        return push(_list._inner, bytes32(_data));
    }

    function remove(U256List storage _list, uint256 _data) internal returns (bool) {
        return remove(_list._inner, bytes32(_data));
    }

    function shift(U256List storage _list) internal returns (uint256) {
        return uint256(shift(_list._inner));
    }

    struct AddressList {
        B32List _inner;
    }

    function empty(AddressList storage _list) internal view returns (bool) {
        return empty(_list._inner);
    }

    function contains(AddressList storage _list, address _data) internal view returns (bool) {
        return contains(_list._inner, bytes32(uint256(uint160(_data))));
    }

    function at(AddressList storage _list, uint256 _index) internal view returns (address) {
        return address(uint160(uint256(at(_list._inner, _index))));
    }

    function values(AddressList storage _list) internal view returns (address[] memory) {
        bytes32[] memory b32Values = values(_list._inner);
        address[] memory result;
        assembly {
            result := b32Values
        }
        return result;
    }

    function insert(AddressList storage _list, address _data, address _prev) internal returns (bool) {
        return insert(_list._inner, bytes32(uint256(uint160(_data))), bytes32(uint256(uint160(_prev))));
    }

    function push(AddressList storage _list, address _data) internal returns (bool) {
        return push(_list._inner, bytes32(uint256(uint160(_data))));
    }

    function remove(AddressList storage _list, address _data) internal returns (bool) {
        return remove(_list._inner, bytes32(uint256(uint160(_data))));
    }

    function shift(AddressList storage _list) internal returns (address) {
        return address(uint160(uint256(shift(_list._inner))));
    }
}
