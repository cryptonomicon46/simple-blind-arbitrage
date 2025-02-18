//This example of forking didn't work, as this test contract's unable to read
//back variables from the .env file

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
contract ForkTest is Test {
    // the identifiers of the forks
    uint256 mainnetFork;
    uint256 optimismFork;
    
    //Access variables from .env file via vm.envString("varname")
    //Replace ALCHEMY_KEY by your alchemy key or Etherscan key, change RPC url if need
    //inside your .env file e.g: 
    //MAINNET_RPC_URL = 'https://eth-mainnet.g.alchemy.com/v2/ALCHEMY_KEY'
    //string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
    //string OPTIMISM_RPC_URL = vm.envString("OPTIMISM_RPC_URL");

        string  MAINNET_RPC_URL = vm.envString("RPC_MAINNET");
        string  OPTIMISM_RPC_URL = vm.envString("RPC_OPTIMISM");
        string  GOERLI_RPC_URL  = vm.envString("RPC_GOERLI");


    function setUp() public {
    console2.log("Setup Mainnet and Optimism forks...");


        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        optimismFork = vm.createFork(OPTIMISM_RPC_URL);


    }

    // // demonstrate fork ids are unique
    function testForkIdDiffer() public view {
        assert(mainnetFork != optimismFork);
    }

    // // select a specific fork
    // function testCanSelectFork() public {
    //     // select the fork
    //     vm.selectFork(mainnetFork);
    //     assertEq(vm.activeFork(), mainnetFork);

    //     // from here on data is fetched from the `mainnetFork` if the EVM requests it and written to the storage of `mainnetFork`
    // }

    // // manage multiple forks in the same test
    // function testCanSwitchForks() public {
    //     vm.selectFork(mainnetFork);
    //     assertEq(vm.activeFork(), mainnetFork);

    //     vm.selectFork(optimismFork);
    //     assertEq(vm.activeFork(), optimismFork);
    // }

    // // forks can be created at all times
    // function testCanCreateAndSelectForkInOneStep() public {
    //     // creates a new fork and also selects it
    //     uint256 anotherFork = vm.createSelectFork(MAINNET_RPC_URL);
    //     assertEq(vm.activeFork(), anotherFork);
    // }

    // // set `block.number` of a fork
    // function testCanSetForkBlockNumber() public {
    //     vm.selectFork(mainnetFork);
    //     vm.rollFork(1_337_000);

    //     assertEq(block.number, 1_337_000);
    // }
}
