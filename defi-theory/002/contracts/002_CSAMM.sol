// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CSAMM {
    IERC20 immutable token0;
    IERC20 immutable token1;

    uint public reserve0;
    uint public reserve1;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint _amount) private {
        require(_amount > 0);
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
        require(_amount > 0);
        require(balanceOf[_from] >= _amount);
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function swap(
        address _tokenIn,
        uint _amountIn
    ) external returns (uint amountOut) {
        require(_amountIn > 0);
        amountOut = _amountIn;

        if (_tokenIn == address(token0)) {
            token0.transferFrom(msg.sender, address(this), _amountIn);
            token1.transfer(msg.sender, amountOut);
            reserve0 += _amountIn;
            reserve1 += _amountIn;
        } else {
            token1.transferFrom(msg.sender, address(this), _amountIn);
            token0.transfer(msg.sender, _amountIn);
            reserve1 += _amountIn;
            reserve0 -= _amountIn;
        }
    }

    function addLiquidity(
        uint _amount0,
        uint _amount1
    ) external returns (uint shares) {
        require(_amount0 > 0 && _amount1 > 0);

        if (totalSupply == 0) {
            shares = _amount0 + _amount1;
        } else {
            shares =
                ((_amount0 + _amount1) * totalSupply) /
                (reserve0 + reserve1);
        }
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);
        reserve0 += _amount0;
        reserve1 += _amount1;
        _mint(msg.sender, shares);
    }

    function removeLiquidity(uint _shares) external returns (uint d0, uint d1) {
        require(_shares > 0);
        require((balanceOf[msg.sender] >= _shares));
        d0 = (reserve0 * _shares) / totalSupply;
        d1 = (reserve1 * _shares) / totalSupply;
        require(
            token0.balanceOf(address(this)) >= d0 &&
                token1.balanceOf(address(this)) >= d1
        );
        token0.transfer(msg.sender, d0);
        token1.transfer(msg.sender, d1);
        reserve0 -= d0;
        reserve1 -= d1;
        _burn(msg.sender, _shares);
    }

    function _update(uint _res0, uint _res1) private {
        reserve0 = _res0;
        reserve1 = _res1;
    }
}
