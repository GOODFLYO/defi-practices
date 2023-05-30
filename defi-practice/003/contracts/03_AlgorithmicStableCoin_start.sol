// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./03_PriceFeed.sol";

contract AlgorithmicStablecoin is ERC20, Ownable {
    PriceFeed internal priceFeed;

    uint256 public targetPrice = 1 * 10 ** 8; // Target price of 1 USD with 8 decimals
    uint256 public expansionPercentage = 5; // 5% expansion or contraction

    constructor(
        uint256 initialSupply,
        address _priceFeed
    ) ERC20("Algo ZYN", "ALZYN") {
        super._mint(msg.sender, initialSupply);
        priceFeed = PriceFeed(_priceFeed);
    }

    function getLatestPrice() public view returns (uint256) {
        return priceFeed.getLatestPrice();
    }

    function adjustSupply() public onlyOwner {
        uint256 newTotalSupply = (expansionPercentage * balanceOf(msg.sender)) / 100;
        if (getLatestPrice() > targetPrice) {
            _mint(msg.sender, newTotalSupply);
        } else {
            _burn(msg.sender, newTotalSupply);
        }
    }
}
