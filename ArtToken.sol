// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol';

contract ArtToken  is ERC20{
    address public admin;
    // uint256 public fee = 50;
    // uint256 public minerReward = 50;
    constructor() ERC20('ArtToken', 'ART'){
        _mint(msg.sender ,1000000000);
        admin = msg.sender;
    }

    // function  _transfer(address from, address to, uint256 value) internal override {
    //     uint256 minerRewardValue = (value * minerReward) / 10000;
    //     uint256 feeValue = (value * fee) / 10000;
    //     value -= minerRewardValue ;
    //     value -= feeValue;

    //     super._transfer(from, block.coinbase, minerRewardValue);
    //     super._transfer(from, admin, feeValue);
    //     super._transfer(from, to, value);
    // }

    // function setFeeTo(uint256 feeValue) external {
    //     require(admin == msg.sender, "only admin");
    //     fee = feeValue;
    // }

    function mint(address to, uint amount) external {
        require(admin == msg.sender, "only admin");
        _mint(to, amount);
    }

    function burn_my_tokens(uint amount) external {
        _burn(msg.sender, amount);
    }
}