// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TokenA.sol";
import "./TokenB.sol";

contract CSAMM {
    IERC20 immutable token0;
    IERC20 immutable token1;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;

    //用来记录用户的share
    // mapping(address => uint) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint256 _amount) private {
        // 此处补全
        require(_to == address(token0) || _to == address(token1));
        require(_amount > 0);
        //mint并不是private 为什么不能调用
        // IERC20(_to).mint(msg.sender, address(this), _amount);
        if (_to == address(token0)) {
            reserve0 += _amount;
            token0.transferFrom(msg.sender, address(this), _amount);
        } else {
            reserve1 += _amount;
            token1.transferFrom(msg.sender, address(this), _amount);
        }
        _update(reserve0, reserve1);
        totalSupply += _amount;
    }

    function _burn(address _from, uint256 _amount) private {
        require(_from == address(token0) || _from == address(token1));
        require(
            _amount > 0 && IERC20(_from).balanceOf(address(this)) >= _amount
        );

        if (_from == address(token0)) {
            reserve0 -= _amount;
            token0.transfer(msg.sender, _amount);
        } else {
            reserve1 -= _amount;
            token1.transfer(msg.sender, _amount);
        }
        _update(reserve0, reserve1);
        totalSupply -= _amount;
    }

    function swap(
        address _tokenIn,
        uint256 _amountIn
    ) external returns (uint256 amountOut) {
        amountOut = _amountIn;

        if (_tokenIn == address(token0)) {
            _mint(address(token0), _amountIn);
            _burn(address(token1), amountOut);
        } else {
            _mint(address(token1), _amountIn);
            _burn(address(token0), amountOut);
        }
        return amountOut;
    }

    function addLiquidity(
        uint256 _amount0,
        uint256 _amount1
    ) external returns (uint256 shares) {
        _mint(address(token0), _amount0);
        _mint(address(token1), _amount1);
        return (_amount0 + _amount1);
    }

    function removeLiquidity(
        uint256 _shares
    ) external returns (uint256 d0, uint256 d1) {
        require(_shares > 0 && totalSupply >= _shares);
        d0 = (_shares * reserve0) / totalSupply;
        d1 = _shares - d0;
        _burn(address(token0), d0);
        _burn(address(token1), d1);
        return (d0, d1);
    }

    function _update(uint256 _res0, uint256 _res1) private {
        reserve0 = _res0;
        reserve1 = _res1;
    }
}
