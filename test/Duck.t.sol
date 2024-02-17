// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "../src/Duck.sol";
import "../src/test/Blast.sol";

contract DuckTest is Test {
    Duck duck;

    function setUp() public {
        vm.etch(0x4300000000000000000000000000000000000002, type(TestBlast).runtimeCode);
        duck = new Duck();
        duck.setLP(address(0x1));
        duck.setWETH(address(0x2));
        duck.mint(address(this), 100);
    }

    function test_setPlayFee() public {
        duck.setPlayFee(100);
        assertEq(duck.playFee(), 100);
    }

    function test_mint() public {
        duck.mint(address(0x3), 100);
        assertEq(duck.balanceOf(address(0x3)), 100);
    }

    function test_setLP() public {
        duck.setLP(address(0x3));
        assert(address(duck.LP()) == address(0x3));
    }

    function test_setWETH() public {
        duck.setWETH(address(0x3));
        assert(address(duck.WETH()) == address(0x3));
    }

    function test_transfer() public {
        duck.transfer(address(0x3), 100);
        assertEq(duck.balanceOf(address(this)), 0);
        assertEq(duck.balanceOf(address(0x3)), 100);
    }

    function test_transferFrom() public {
        duck.approve(address(0x3), 100);
        vm.startPrank(address(0x3));
        duck.transferFrom(address(this), address(0x4), 100);
        assertEq(duck.balanceOf(address(this)), 0);
        assertEq(duck.balanceOf(address(0x4)), 100);
    }
}
