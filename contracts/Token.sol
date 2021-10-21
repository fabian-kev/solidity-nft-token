// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor ()  {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }
  function owner() public view returns (address) {
    return _owner;
  }
  modifier onlyOwner() {
    require(_owner == msg.sender, "This is strictly for owner only");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }
  
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


contract Token is Ownable, IBEP20 {
    
  string private _name;
  string private _symbol;
  uint8 private _decimals;
  uint256 private _totalSupply;

  uint256 private _maxSupply;

  mapping(address => uint256) private _balanceOf;
  mapping(address => mapping(address => uint256)) private _allowances;

  constructor(string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals, uint256 tokenTotalSupply, uint256 tokenMaxSupply){
    _name = tokenName;
    _symbol = tokenSymbol;
    _decimals = tokenDecimals;
    _totalSupply = tokenTotalSupply * 10 ** uint256(tokenDecimals);
    _maxSupply = tokenMaxSupply * 10 ** uint256(tokenDecimals);

    _balanceOf[owner()] = tokenTotalSupply;
  }

  modifier notEmptyAddress(address account) {
        require(
            account != address(0),
            "Empty address is not allowed"
        );
        _;
  }
    function balanceOf(address account) override external view returns (uint256) {
        return _balanceOf[account];
    }
  
    function name() external override view returns (string memory) {
        return _name;
    }
    
  function totalSupply() override external view returns (uint256) {
    return _totalSupply;
  }
  
  function maxSupply() external view returns (uint256) {
          return _maxSupply;
  }
  function decimals() override external view returns (uint8) {
      return _decimals;
  }
  function symbol() override external view returns (string memory) {
      return _symbol;
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
    require(_maxSupply >= (_totalSupply+amount), "You've reached the max supply");
    // Increase total supply
    _totalSupply += amount;
    // Add amount to the account balance using the balance mapping
    _balanceOf[account] += amount;
    // Emit our event to log the action
    emit Transfer(address(0), account, amount);
  }


   function _burn(address account, uint256 amount) notEmptyAddress(account) internal {
      require(_balanceOf[account] >= amount, "Cannot burn more than the account owns");

      // Remove the amount from the account balance
      _balanceOf[account] -= amount;
      // Decrease totalSupply
      _totalSupply -= amount;
      // Emit event, use zero address as reciever
      // emit Transfer(account, address(0), amount);
    }


  function _transfer(address sender, address recipient, uint256 amount) notEmptyAddress(sender) internal {
    require(recipient != address(0), "Transfer to zero address");
    require(_balanceOf[sender] >= amount, "Cant transfer more than your account holds");

   _balanceOf[sender] -= amount;
    _balanceOf[recipient] += amount;

    emit Transfer(sender, recipient, amount);
  }

 
   function transfer(address recipient, uint256 amount) external virtual override returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function getOwner() external view override  returns (address) {
    return owner();
  }

  function allowance(address owner, address spender) override external view returns(uint256){
     return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) override external returns (bool) {
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

    function transferFrom(address spender, address recipient, uint256 amount) override  external returns(bool){
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
