// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function mul (uint a, uint b) internal pure returns (uint c) {
        if (a == 0) {
            return 0;
        }

        c = a*b;
        assert (c/a == b);
        return c;
    }

    function div (uint a, uint b) internal pure returns (uint) {
        return a/b;
    }

    function sub (uint a, uint b) internal pure returns (uint) {
        assert (b <= a);
        return a - b;
    }

    function add (uint a, uint b) internal pure returns (uint) {
        c = a + b;
        assert ( c >= a);
        return c;
    }
}