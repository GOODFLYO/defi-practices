// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract TokenB is ERC20, Ownable, ERC20Burnable {
    constructor() ERC20("TokenB", "TokenB") {}

    function mint(address reciever, uint256 amount) public onlyOwner {
        _mint(reciever, amount);
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(amount);
    }
}
