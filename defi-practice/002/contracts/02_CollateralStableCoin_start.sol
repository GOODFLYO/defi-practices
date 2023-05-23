// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./defi-practices/PriceFeed.sol";
import "./defi-practices/ZYN.sol";

// 此处补全

contract CollateralStableCoin is ERC20 {
    using SafeMath for uint256;

    IERC20 public collateralToken; // 要抵押的币 ZYN
    PriceFeed public priceFeed; // 价格预言机 返回当前token的价格
    uint256 public amountOfCollateralToken; // 抵押币的总量
    uint256 public constant COLLATERAL_RATIO_PRECISION = 1e18;

    constructor(
        address _collateralToken,
        address _priceFeed
    ) ERC20("DAI", "DAI") {
        collateralToken = IERC20(_collateralToken);
        priceFeed = PriceFeed(_priceFeed);
    }

    function getCollateralPrice() public view returns (uint256) {
        return uint256(priceFeed.getLatestPrice());
    }

    function calculateCollateralAmount(
        uint256 _stablecoinAmount
    ) public view returns (uint256) {
        // 150% 超额抵押 得到换_stablecoinAmount个稳定币需要抵押的币

        // uint256*getCollateralPrice().mul(100).div(150)==_stablecoinAmount;
        return
            _stablecoinAmount
                .mul(COLLATERAL_RATIO_PRECISION)
                .mul(150)
                .div(100)
                .div(getCollateralPrice());
    }

    function getzyn() public view returns (uint256) {
        return collateralToken.balanceOf(msg.sender);
    }

    function mint(uint256 _stablecoinAmount) external {
        require(_stablecoinAmount > 0);
        uint256 collateralToStablecoin = calculateCollateralAmount(
            _stablecoinAmount
        );
        require(
            collateralToken.balanceOf(msg.sender) >= collateralToStablecoin
        );
        collateralToken.transferFrom(
            msg.sender,
            address(this),
            collateralToStablecoin
        );

        amountOfCollateralToken = amountOfCollateralToken.add(
            collateralToStablecoin
        );

        _mint(msg.sender, _stablecoinAmount);
    }

    function burn(uint256 _stablecoinAmount) external {
        uint256 collateralToStablecoin = calculateCollateralAmount(
            _stablecoinAmount
        );
        require(_stablecoinAmount > 0);
        require(amountOfCollateralToken >= collateralToStablecoin);
        require(balanceOf(msg.sender) >= _stablecoinAmount);
        collateralToken.transfer(msg.sender, collateralToStablecoin);
        amountOfCollateralToken = amountOfCollateralToken.sub(
            collateralToStablecoin
        );
        _burn(msg.sender, _stablecoinAmount);
    }
}
