pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/TokenForTesting.sol";
import "../src/blindBackrunDebug.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/ERC20.sol";
import {IUniswapV2Router,IUniswapFactory,IV2Pair} from "./interfaces/IUniswap.sol";
import {Iweth} from "./interfaces/IWeth.sol";

error Unauthorized();




contract BlindBackrunTest is Test {
    BlindBackrun public blindBackrun;
    TokenForTesting public testToken;

    // address wethTokenAddress = address(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);//Goerli
    address wethTokenAddress = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);//mainnet
    // IWETH WETH = IWETH(wethTokenAddress);
    Iweth weth = Iweth(wethTokenAddress);

    address uniswapV2RouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    // address sushiswapRouterAddress = address(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);//goerli
    address sushiswapRouterAddress = address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);//mainnet

    address uniswapv2FactoryAddress = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    // address sushiswapFactoryAddress = address(0xc35DADB65012eC5796536bD9864eD8773aBc74C4);//goerli
    address sushiswapFactoryAddress = address(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac);//mainnet



    IUniswapV2Router public uniswapv2Router = IUniswapV2Router(uniswapV2RouterAddress);
    IUniswapV2Router public sushiswapRouter = IUniswapV2Router(sushiswapRouterAddress);
    
    IUniswapFactory public uniswapFactory = IUniswapFactory(uniswapv2FactoryAddress);
    IUniswapFactory public sushiswapFactory = IUniswapFactory(sushiswapFactoryAddress);
    address here = address(this);
    
    function setUp() public {
        vm.createSelectFork("mainnet",17_033_152);

        console.log("Address of here is %s", here);
        // blindBackrun = new BlindBackrun(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6); // WETH address on goerli
                blindBackrun = new BlindBackrun(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // WETH address on mainnet

        vm.deal(address(blindBackrun), 10_000 ether);//10000 000000000000000000
        console.log("Balance of blindBackRun contract=%s ether", address(blindBackrun).balance/1e18);
        console.log("Depositing into the WETH contract...");
        // WETH.deposit{value: 1e19}();
        weth.deposit{value: 10 ether}();

        emit log_named_decimal_uint("WETH balnace of this contract", weth.balanceOf(here),18);
        // WETH.transfer(address(blindBackrun), 1e19);
        weth.transfer(address(blindBackrun), 1e19);

        testToken = new TokenForTesting();
        console.log("Address of test token is:", address(testToken));
        emit log_named_decimal_uint("Token Balance of here is", testToken.balanceOf(here),18);
    }

    function test_newArb() public {
        console.log("Starting test_newArb()...");
        testToken.approve(address(uniswapv2Router), 10 ether);
        testToken.approve(address(sushiswapRouter), 1 ether);

        uniswapv2Router.addLiquidityETH{value: 1 ether}(address(testToken), 10 ether, 1, 1, msg.sender, 1e20);

        sushiswapRouter.addLiquidityETH{value: 1 ether}(address(testToken), 1 ether, 1, 1, msg.sender, 1e20);

        address firstPair = uniswapFactory.getPair(address(testToken), wethTokenAddress);
        IV2Pair uniPairV2 = IV2Pair(firstPair);
        (uint256 reserve0, uint256 reserve1, )= uniPairV2.getReserves();

        console.log("Address of the uniSwapPair :", address(firstPair));
        emit log_named_decimal_uint("Uni-reserve0-WETH", reserve0,18);
        emit log_named_decimal_uint("Uni-reserve1-TFT", reserve1,18);

    
        
        address secondPair = sushiswapFactory.getPair(address(testToken), wethTokenAddress);
        console.log("Address of sushiSwap pair:", address(secondPair));

        blindBackrun.executeArbitrage(firstPair, secondPair, 80);
    }

    function test_RevertWhen_CallerIsNotOwner() public {
        console.log("Starting test_RevertWhen_CallerIsNotOwner()...");
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0));
        blindBackrun.withdrawWETHToOwner();
    }
}
