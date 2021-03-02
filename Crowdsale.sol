// fix version
pragma solidity 0.5.12;

// import library
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
 
contract Crowdsale {
   using SafeMath for uint256;
   
    //private attribut
   address owner; // the owner of the contract
   address escrow; // wallet to collect raised ETH
   uint256 public savedBalance = 0; // Total amount raised in ETH
   mapping (address => uint256) balances; // Balances in incoming Ether
 
   // Initialization
   function Crowdsale(address _escrow) public{
       owner = tx.origin;
       // add address of the specific contract
       escrow = _escrow;
   }
  
   // function to receive ETH
   function() public {
       balances[msg.sender] = balances[msg.sender].add(msg.value);
       savedBalance = savedBalance.add(msg.value);
       escrow.send(msg.value);
   }
  
   // refund investisor
   function withdrawPayments() public{
       // Verify payment != 0 and balance >= payment
       require(payment != 0);
       require(address(this).balance >= payment);
       address payee = msg.sender;
       uint256 payment = balances[payee];
 
       payee.send(payment);
 
       savedBalance = savedBalance.sub(payment);
       balances[payee] = 0;
   }
}
