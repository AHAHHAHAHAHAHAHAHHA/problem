// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {IComet} from "./interfaces/IComet.sol";
import {SafeERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";


contract MarketInteractions {
    using SafeERC20 for IERC20;
    address payable owner;

   address public immutable POOL;

    address private immutable usdcAddress =
        0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
    IERC20 private usdc;

    event SEE(bytes data);

    constructor(address _addressProvider) {
        POOL = _addressProvider;
        owner = payable(msg.sender);
        usdc = IERC20(usdcAddress);
        usdc.safeApprove(_addressProvider, type(uint256).max);
    }

    function supplyLiquidity(address _tokenAddress, uint256 _amount) external {
        address asset = _tokenAddress;
        uint256 amount = _amount;


        bytes memory message = abi.encodeCall(
            IComet.supply,
            (
                asset,
                amount
            )
        );

        //IComet comet = IComet(POOL);
        //comet.supply(asset, amount);

        (bool success, bytes memory data) = POOL.call(message);

        if (success) {
            emit SEE(data);
        }
    }

    function supplyLiquidity1(address _tokenAddress, uint256 _amount) external {
        address asset = _tokenAddress;
        uint256 amount = _amount;


        bytes memory message = abi.encodeCall(
            IComet.supply,
            (
                asset,
                amount
            )
        );

        IComet comet = IComet(POOL);
        comet.supply(asset, amount);
    }


    function approveusdc(uint256 _amount, address _poolContractAddress)
        external
        returns (bool)
    {
        return usdc.approve(_poolContractAddress, _amount);
    }

    function allowanceusdc(address _poolContractAddress)
        external
        view
        returns (uint256)
    {
        return usdc.allowance(address(this), _poolContractAddress);
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    receive() external payable {}
}
