pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

}


contract TokenERC20 {
    // Public variables of the token
    string public name;
    string public symbol;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint8 public decimals = 18;
    
    uint256 public totalSupply;
    address holderAddr;    
    address checkerAddr;


    // This creates an array with all balances
    mapping (address => uint256) internal balanceOf;
    mapping (address => uint256) internal allocationOf;
    mapping (address => uint256) internal frozenGapTime;
    mapping (address => uint256) internal frozenTimes;
    mapping (address => uint256) internal unfrozenPerTime;


    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);


    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        // Update total supply with the decimal amount
        totalSupply = initialSupply * 10 ** uint256(decimals);  
        // Set the name for display purposes
        name = tokenName;     
        // Set the symbol for display purposes
        symbol = tokenSymbol;
        // Init allocation plan
        _initBalanceAllocation();
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * allocation plan, called when publish contract
     */
    function _initBalanceAllocation () internal{
        uint256 totalAllocation = 0;

        //for A
        totalAllocation += _set376Allocation(0x9b891a9818b12Bc1b36D907e51eee50BF68eFA7d, 300000000);

        //for B
        totalAllocation += _set463Allocation(0x0Ace3D71dA498a4dA3f10483f3dCA8882E528d80, 300000000);

        //for C
        totalAllocation += _set100Allocation(0x5E15494ddf4977C428E382a3324BB0515eb3E90b, 0x7eF8197589EBFcCEF2f5c33B550Ad6aC2bbf0628, 600000000); 
        
        //for D
        totalAllocation += _set133Allocation(0x71651448a1A9aB8329cDF5EC9eD0B3Ed680e6421, 300000000);

        //make sure 100%
        require(totalAllocation == totalSupply);   

    }
    

    /**
     * set frozen tokens
     */
    function _set376Allocation(address _addr, uint256 _value) internal returns(uint256 ret){
        _value = _value * 10 ** uint256(decimals);
        allocationOf[_addr] = 376;
        balanceOf[_addr] = _value;
        //frozenGapTime[_addr] = 30 days;
        frozenGapTime[_addr] = 10 minutes;

        frozenTimes[_addr] = 6;
        unfrozenPerTime[_addr] = ((_value / 10) * 7) / 6;
        
        Transfer(msg.sender, _addr, _value);
        return _value;
    }
    
    /**
     * set frozen tokens
     */
    function _set463Allocation(address _addr, uint256 _value) internal returns(uint256 ret){
        _value = _value * 10 ** uint256(decimals);
        allocationOf[_addr] = 643;
        balanceOf[_addr] = _value;
        //frozenGapTime[_addr] = 30 days;
        frozenGapTime[_addr] = 10 minutes;

        frozenTimes[_addr] = 3;
        unfrozenPerTime[_addr] = ((_value / 10) * 6) / 3;

        Transfer(msg.sender, _addr, _value);
        return _value;
    }

    /**
     * set frozen tokens
     */
    function _set133Allocation(address _addr, uint256 _value) internal returns(uint256 ret){
        _value = _value * 10 ** uint256(decimals);
        allocationOf[_addr] = 133;
        balanceOf[_addr] = _value;
        //frozenGapTime[_addr] = 1 years;
        frozenGapTime[_addr] = 10 minutes;

        frozenTimes[_addr] = 3;
        unfrozenPerTime[_addr] = ((_value / 4) * 3 ) / 3;
        
        Transfer(msg.sender, _addr, _value);
        return _value;
    }

    /**
     * set no need frozen tokens
     */
    function _set100Allocation(address _holder, address _checker, uint256 _value) internal returns(uint256 ret){
        require(_holder != _checker);
        _value = _value * 10 ** uint256(decimals);
        balanceOf[_holder] = _value;
        
        holderAddr = _holder;
        checkerAddr = _checker;
        //add transfe recode
        Transfer(msg.sender, _holder, _value);
        return _value;
    }
    
}

/******************************************/
/*       Zhaoxiwu Test COIN (SOC)       */
/******************************************/

contract TestCoin is owned, TokenERC20 {
    uint256 public startAt;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function TestCoin(
    ) TokenERC20(1500000000, "XWC", "xiwu test Coin") public {
        startAt = now;
    }

   
    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require (_to != 0x0);  
        // Check value negative
        require (_value > 0);
        // Check if the sender has enough
        require (balanceOf[_from] >= _value);
        // Check for overflows
        require (balanceOf[_to] + _value > balanceOf[_to]); 
        
        if(_from == holderAddr){
            // Check own have enough token
            require(_to == checkerAddr);
        }
        
        if(_to == checkerAddr){
            // Check own have enough token
            require(_from == holderAddr);
        }
        
        if(allocationOf[_from] > 0) {
            uint256 _splitTime = frozenGapTime[_from];
            uint256 _frozenTimes = frozenTimes[_from];
            uint256 _unfrozen = unfrozenPerTime[_from];
        
            if(_splitTime != 0){
                uint256 mustHave = 0;
                if(_frozenTimes > (now - startAt) / _splitTime){
                    mustHave = (_frozenTimes - (now - startAt) / _splitTime) * _unfrozen;
                }
                require(balanceOf[_from] >= _value + mustHave);
            }
        }
        
        // Subtract from the sender
        balanceOf[_from] -= _value;  
        // Add the same to the recipient
        balanceOf[_to] += _value;                          
        Transfer(_from, _to, _value);
    }
    
    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    
    function set376Allocation(address _addr, uint256 _value) public onlyOwner {
        _set376Allocation( _addr,  _value);
    }
    
    function set463Allocation(address _addr, uint256 _value) public onlyOwner {
        _set463Allocation(_addr,  _value);
    }
}
