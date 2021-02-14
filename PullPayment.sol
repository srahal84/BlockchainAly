// SPDX-License-Identifier: MIT
pragma solidity 0.6.11;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";
contract PullPayment {
  using SafeMath for uint256;
  mapping (address => uint256) public credits;
  uint256 public total;
  
  function asyncSend(address dest, uint256 amount) internal {
      credits[dest] = credits[dest].add(amount);
      total = total.add(amount);
  }
  
  function withdrawPayments() public {
      require(credits[msg.sender] != 0);
      total = total.sub(credits[msg.sender]);
      credits[msg.sender] = 0;
      msg.sender.transfer(credits[msg.sender]);
  }
}
