// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import './Ownable.sol';
import './IBEP20.sol';
contract Token is Ownable, IBEP20 {

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  uint256 public maxSupply;

  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) private _allowances;

  constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply, uint256 _maxSupply){
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    totalSupply = _totalSupply;
    maxSupply = _maxSupply;

    balanceOf[owner()] = totalSupply;
  }

  modifier notEmptyAddress(address account) {
        require(
            account != address(0),
            "Empty address is not allowed"
        );
        _;
  }


 function mint(address account, uint256 amount) onlyOwner external returns (bool) {
  _mint(account, amount);
  return true;
 }
 function burn(address account, uint256 amount) external  returns (bool) {
   _burn(account, amount);
   return true;
 }

 function _mint(address account, uint256 amount) notEmptyAddress(account) internal {
    require(maxSupply >= (totalSupply+amount), "You've reached the max supply");
    // Increase total supply
    totalSupply = totalSupply + amount;
    // Add amount to the account balance using the balance mapping
    balanceOf[account] += amount;
    // Emit our event to log the action
    emit Transfer(address(0), account, amount);
  }


   function _burn(address account, uint256 amount) notEmptyAddress(account) internal {
      require(balanceOf[account] >= amount, "Cannot burn more than the account owns");

      // Remove the amount from the account balance
      balanceOf[account] -= amount;
      // Decrease totalSupply
      totalSupply -= amount;
      // Emit event, use zero address as reciever
      // emit Transfer(account, address(0), amount);
    }


  function _transfer(address sender, address recipient, uint256 amount) notEmptyAddress(sender) internal {
    require(recipient != address(0), "Transfer to zero address");
    require(balanceOf[sender] >= amount, "Cant transfer more than your account holds");

    balanceOf[sender] = balanceOf[sender] - amount;
    balanceOf[recipient] = balanceOf[recipient] + amount;

    emit Transfer(sender, recipient, amount);
  }


  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function getOwner() external view returns (address) {
    return owner();
  }

  function allowance(address owner, address spender) external view returns(uint256){
     return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
     _approve(msg.sender, spender, amount);
     return true;
   }

   function _approve(address owner, address spender, uint256 amount) internal {
      require(owner != address(0), "DevToken: approve cannot be done from zero address");
      require(spender != address(0), "DevToken: approve cannot be to zero address");
      // Set the allowance of the spender address at the Owner mapping over accounts to the amount
      _allowances[owner][spender] = amount;

      emit Approval(owner,spender,amount);
    }

    function transferFrom(address spender, address recipient, uint256 amount) external returns(bool){
      // Make sure spender is allowed the amount 
      require(_allowances[spender][msg.sender] >= amount, "You cannot spend that much on this account");
      // Transfer first
      _transfer(spender, recipient, amount);
      // Reduce current allowance so a user cannot respend
      _approve(spender, msg.sender, _allowances[spender][msg.sender] - amount);
      return true;
    }

    function increaseAllowance(address spender, uint256 amount) public returns (bool) {
      _approve(msg.sender, spender, _allowances[msg.sender][spender]+amount);
      return true;
    }

    function decreaseAllowance(address spender, uint256 amount) public returns (bool) {
      _approve(msg.sender, spender, _allowances[msg.sender][spender]-amount);
      return true;
    }


}
