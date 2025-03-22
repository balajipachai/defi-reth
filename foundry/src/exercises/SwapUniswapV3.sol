// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IRETH} from "../interfaces/rocket-pool/IRETH.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {ISwapRouter} from "../interfaces/uniswap/ISwapRouter.sol";
import {
    RETH,
    WETH,
    UNISWAP_V3_SWAP_ROUTER_02,
    UNISWAP_V3_POOL_FEE_RETH_WETH
} from "@src/Constants.sol";

/// @title SwapUniswapV3
/// @notice This contract facilitates swaps between rETH and WETH using Uniswap V3.
/// @dev The contract interacts with Uniswap V3's swap router for token swaps.
contract SwapUniswapV3 {
    IRETH constant reth = IRETH(RETH);
    IERC20 constant weth = IERC20(WETH);
    ISwapRouter public constant router = ISwapRouter(UNISWAP_V3_SWAP_ROUTER_02);

    /// @notice Executes a token swap using Uniswap V3.
    /// @param tokenIn The address of the token to swap from.
    /// @param tokenOut The address of the token to swap to.
    /// @param fee The fee tier of the Uniswap V3 pool.
    /// @param amountIn The amount of `tokenIn` to be swapped.
    /// @param amountOutMin The minimum amount of `tokenOut` to be received.
    /// @param receiver The address to receive the swapped tokens.
    /// @return amountOut The amount of `tokenOut` received from the swap.
    function swap(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint256 amountOutMin,
        address receiver
    ) private returns (uint256 amountOut) {
        return router.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: fee,
                recipient: receiver,
                amountIn: amountIn,
                amountOutMinimum: amountOutMin,
                sqrtPriceLimitX96: 0
            })
        );
    }

    /// @notice Swaps WETH to rETH using Uniswap V3.
    /// @param wethAmountIn The amount of WETH to be swapped.
    /// @param rEthAmountOutMin The minimum amount of rETH to receive.
    /// @dev The caller must approve the contract to transfer WETH on their behalf.
    function swapWethToReth(uint256 wethAmountIn, uint256 rEthAmountOutMin)
        external
    {
        // Pull in the WETH tokens into the contract
        weth.transferFrom(msg.sender, address(this), wethAmountIn);
        // Approve the router to transfer WETH on behalf of the contract
        weth.approve(address(router), wethAmountIn);

        // This can be achieved by calling the swap function with the correct parameters
        // However, inorder to make that call, we would need all the different swap function parameters
        // Those are alreay defined in constants.sol, so pick from there and call the swap function
        swap(
            WETH,
            RETH,
            UNISWAP_V3_POOL_FEE_RETH_WETH,
            wethAmountIn,
            rEthAmountOutMin,
            address(this)
        );
    }

    /// @notice Swaps rETH to WETH using Uniswap V3.
    /// @param rEthAmountIn The amount of rETH to be swapped.
    /// @param wethAmountOutMin The minimum amount of WETH to receive.
    /// @dev The caller must approve the contract to transfer rETH on their behalf.
    function swapRethToWeth(uint256 rEthAmountIn, uint256 wethAmountOutMin)
        external
    {
        // Pull in the rETH tokens into the contract
        reth.transferFrom(msg.sender, address(this), rEthAmountIn);
        // Approve the router to transfer rETH on behalf of the contract
        reth.approve(address(router), rEthAmountIn);

        // Same as above, however, the tokenIn and tokenOut are reversed
        swap(
            RETH,
            WETH,
            UNISWAP_V3_POOL_FEE_RETH_WETH,
            rEthAmountIn,
            wethAmountOutMin,
            address(this)
        );
    }
}
