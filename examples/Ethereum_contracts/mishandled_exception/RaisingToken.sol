/**
 * EIP-20 token whose price (in ether terms) is always raising.
 * Hurry to invest early!
 */
contract RaisingToken {
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) allowance;

    /**
     * Deploy RaisingToken smart contract, issue one token and sell it to
     * message sender for ether provided.
     */
    constructor () payable {
        // Make sure some ether was provided
        require (msg.value > 0);

        // Issue one token...
        totalSupply = 1;

        // ... and give it to message sender
        balanceOf [msg.sender] = 1;

        // Log token creation
        emit Transfer (address (0), msg.sender, 1);
    }

    /**
     * Issue and buy more tokens.
     */
    function buy() public payable {
        // Calculate number of token that could be bought for ether provided
        uint256 count = msg.value * totalSupply / address(this).balance;

        // Proceed only if some tokens could actually be bought.
        require (count > 0);

        // Issue tokens ...        
        totalSupply += count;

        // ... and give them to message sender
        balanceOf [msg.sender] += count;

        // Log token creation
        emit Transfer (address (0), msg.sender, count);
    }

    /**
     * Sell and burn given number of tokens.
     *
     * @param _value number of tokens to sell
     * @return true if tokens were sold successfully, false otherwise
     */
    function sell(uint256 _value) public returns (bool) {
        // Proceed only if
        // 1. Number of tokens to be sold is non-zero
        // 2. Some tokens will still exist after burning tokens to be sold
        // 3. Message sender has enough tokens to sell
        if (_value > 0 ) {
            // Calculate amount of ether to be sent to seller
            uint256 toSend = _value * address(this).balance;

            // If we failed to send ether to seller ...
            msg.sender.send (toSend);
            
            // Take tokens from seller ...
            balanceOf [msg.sender] -= _value;

            // ... and burn them
            totalSupply -= _value;

            // Log token burning
            emit Transfer (msg.sender, address (0), _value);

            // Report success
            return true;
        } else return false; // Report failure
    }

    /**
     * Get token name.
     * 
     * @return token name
     */
    function name() public pure returns (string memory) {
        return "RaisingToken";
    }

    /**
     * Get token symbol.
     * 
     * @return token symbol
     */
    function symbol() public pure returns (string memory) {
        return "RAT";
    }

    /**
     * Get token decimals.
     * 
     * @return token decimals
     */
    function decimals() public pure returns (uint8) {
        return 0;
    }

    /**
     * emit Transfer given number of tokens from message sender to the owner of given
     * address.  Charge commission of 1 token and burn it.
     *
     * @param _to address to send tokens to the owner of
     * @param _value number of token to send (recepient will get one less)
     * @return true if tokens were sent successfully, false otherwise
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        // Proceed only if
        // 1. There are more than 1 tokens being transferred
        // 2. Message sender has enough tokens
        if (_value > 1 && _value >= balanceOf [msg.sender]) {
            // Take tokens from message sender
            balanceOf [msg.sender] -= _value;

            // Decrement transfer value by one
            _value -= 1;

            // Give tokens to recipient
            balanceOf [_to] += _value;

            // Burn commission
            totalSupply -= 1;

            // Log token transfer
            emit Transfer (msg.sender, _to, _value);

            // Log token burning
            emit Transfer (msg.sender, address (0), 1);

            // Report success
            return true;
        } else return false; // Report failure
    }

    /**
     * Allow owher of given spender address to transfer at most given number of
     * tokens from message sender.
     *
     * @param _spender address to allow transfer for the owner of
     * @param _value number of tokens to allow transfer of
     * @return true if transfer was approved successfully, false otherwise
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        // Approve token transfer
        allowance [msg.sender][_spender] = _value;

        // Log transfer approval
        Approval (msg.sender, _spender, _value);
    }

    /**
     * Logged when tokens were transferred, created, or burned.
     *
     * @param _from address tokens were transferred from or zero if tokens were
     *        created
     * @param _to address tokens were transferred to or zero if tokens were
     *        burned
     * @param _value number of tokens transferred, created, or burned
     */
    event Transfer(
        address indexed _from, address indexed _to, uint256 _value);

    /**
     * Logged when token transfer was approved.
     *
     * @param _owner address of the owner of tokens approved to be transferred
     * @param _spender spender approved to transfer tokens
     * @param _value number of tokens approved to be trasferred
     */
    event Approval(
        address indexed _owner, address indexed _spender, uint256 _value);
}