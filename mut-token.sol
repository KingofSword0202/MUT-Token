/**
 *Submitted for verification at BscScan.com on 2024-03-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;
    uint256 private _totalSupply = 0;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfer token to a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowed[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowed[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
}

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory getName,
        string memory getSymbol,
        uint8 getDecimals
    ) {
        _name = getName;
        _symbol = getSymbol;
        _decimals = getDecimals;
    }

    /**
     * return the name of the token.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * return the symbol of the token.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract MemeLottoToken is ERC20, Ownable, ERC20Detailed {
    using SafeMath for uint256;

    address constant LotteryMiningWallet =
        0xd36603fFE71F5e2C192BAeCabaDc86C0c73EDF06; //[1] When a user purchases a lottery ticket from MemeLotto then the user ‘mines’
    address constant MemeLottoMembersWallet =
        0x26bE86A18ef7a8aB5DEb63fecd729Ff977fD28Bb; // [2] Token distribution in person at major industry events and conferences
    address constant MemeLottoMembershipWallet =
        0x2fe43187BbbCE3Edb60624a7Ea09C129d3fa28Aa; //[3] Supporter Members/ Affiliate Members/ Community Members/ Player Members
    address constant MemeLottoPLCAllocationWallet =
        0xF510997854Ead27FF2FAaF23f188577FAe4b1f1d; // [4] Locked token account. Locked for 24 months
    address constant MemeLottoPLCAllocationUnlockedTokensWallet =
        0xDb2799E74a7981F1bC7E5704d3960670618AbFcD; // [5] 15%
    address constant AirdropWallet = 0x3B15aF967fD6e21d1468171CC41dD1Ebf84e0315; // [6] Aidrop

    struct LockItem {
        uint256 releaseDate;
        uint256 amount;
    }

    mapping(address => LockItem[]) private lockList;
    address[] private lockedAddressList;
    uint256 private totalCoins;

    constructor() ERC20Detailed("MemeLotto", "MUT", 9) {
        totalCoins = 1000000000 * 10**uint256(decimals());
        _mint(owner(), totalCoins);
        ERC20.transfer(
            LotteryMiningWallet,
            350000000 * 10**uint256(decimals())
        ); // transfer 350 million tokens
        ERC20.transfer(
            MemeLottoMembersWallet,
            30000000 * 10**uint256(decimals())
        ); // transfer 30 million tokens
        ERC20.transfer(
            MemeLottoMembershipWallet,
            250000000 * 10**uint256(decimals())
        ); // transfer 250 million tokens
        ERC20.transfer(
            MemeLottoPLCAllocationUnlockedTokensWallet,
            150000000 * 10**uint256(decimals())
        ); // transfer 150 million tokens
        ERC20.transfer(AirdropWallet, 20000000 * 10**uint256(decimals())); // transfer 20 million tokens

        ERC20.transfer(
            MemeLottoPLCAllocationWallet,
            200000000 * 10**uint256(decimals())
        ); // transfer 200 million tokens
        if (lockList[MemeLottoPLCAllocationWallet].length == 0)
            lockedAddressList.push(MemeLottoPLCAllocationWallet);
        LockItem memory item = LockItem({
            amount: 200000000 * 10**uint256(decimals()),
            releaseDate: block.timestamp + 720 days
        });
        lockList[MemeLottoPLCAllocationWallet].push(item);
    }

    /**
     * @dev transfer of token to another address.
     * always require the sender has enough balance
     * return the bool true if success.
     * @param receiver The address to transfer to.
     * @param amount The amount to be transferred.
     */
    function transfer(address receiver, uint256 amount)
        public
        override(ERC20, IERC20)
        returns (bool success)
    {
        require(receiver != address(0), "Invalid receiver address");
        require(
            amount <= getAvailableBalance(msg.sender),
            "Insufficient balance"
        );
        return ERC20.transfer(receiver, amount);
    }

    /**
     * @dev transfer of token on behalf of the owner to another address.
     * always require the owner has enough balance and the sender is allowed to transfer the given amount
     * return the bool true if success.
     * @param from The address to transfer from.
     * @param receiver The address to transfer to.
     * @param amount The amount to be transferred.
     */
    function transferFrom(
        address from,
        address receiver,
        uint256 amount
    ) public override(ERC20, IERC20) returns (bool success) {
        require(from != address(0));
        require(receiver != address(0));
        require(amount <= allowance(from, msg.sender));
        require(amount <= getAvailableBalance(from));
        return ERC20.transferFrom(from, receiver, amount);
    }

    /**
     * @dev transfer to a given address a given amount and lock this fund until a given time
     * used for sending fund to team members, partners, or for owner to lock service fund over time
     * return the bool true if success.
     * @param receiver The address to transfer to.
     * @param amount The amount to transfer.
     * @param releaseDate The date to release token.
     */
    function transferAndLock(
        address receiver,
        uint256 amount,
        uint256 releaseDate
    ) external returns (bool success) {
        ERC20._transfer(msg.sender, receiver, amount);
        if (lockList[receiver].length == 0) lockedAddressList.push(receiver);
        LockItem memory item = LockItem({
            amount: amount,
            releaseDate: releaseDate
        });
        lockList[receiver].push(item);

        return true;
    }

    /**
     * return the total amount of locked funds of a given address.
     * @param lockedAddress The address to check.
     */
    function getLockedAmount(address lockedAddress)
        public
        view
        returns (uint256 _amount)
    {
        uint256 lockedAmount = 0;
        for (uint256 j = 0; j < lockList[lockedAddress].length; j++) {
            if (block.timestamp < lockList[lockedAddress][j].releaseDate) {
                uint256 temp = lockList[lockedAddress][j].amount;
                lockedAmount += temp;
            }
        }
        return lockedAmount;
    }

    /**
     * return the total amount of locked funds of a given address.
     * @param lockedAddress The address to check.
     */
    function getAvailableBalance(address lockedAddress)
        public
        view
        returns (uint256 _amount)
    {
        uint256 bal = balanceOf(lockedAddress);
        uint256 locked = getLockedAmount(lockedAddress);
        return bal.sub(locked);
    }

    /**
     * return the list of all addresses that have at least a fund locked currently or in the past
     */
    function getLockedAddresses() external view returns (address[] memory) {
        return lockedAddressList;
    }

    /**
     * return the number of addresses that have at least a fund locked currently or in the past
     */
    function getNumberOfLockedAddresses()
        external
        view
        returns (uint256 _count)
    {
        return lockedAddressList.length;
    }

    /**
     * return the number of addresses that have at least a fund locked currently
     */
    function getNumberOfLockedAddressesCurrently()
        public
        view
        returns (uint256 _count)
    {
        uint256 count = 0;
        for (uint256 i = 0; i < lockedAddressList.length; i++) {
            if (getLockedAmount(lockedAddressList[i]) > 0) count++;
        }
        return count;
    }

    /**
     * return the list of all addresses that have at least a fund locked currently
     */
    function getLockedAddressesCurrently()
        external
        view
        returns (address[] memory)
    {
        address[] memory list = new address[](
            getNumberOfLockedAddressesCurrently()
        );
        uint256 j = 0;
        for (uint256 i = 0; i < lockedAddressList.length; i++) {
            if (getLockedAmount(lockedAddressList[i]) > 0) {
                list[j] = lockedAddressList[i];
                j++;
            }
        }

        return list;
    }

    /**
     * return the total amount of locked funds at the current time
     */
    function getLockedAmountTotal() public view returns (uint256 _amount) {
        uint256 sum = 0;
        for (uint256 i = 0; i < lockedAddressList.length; i++) {
            uint256 lockedAmount = getLockedAmount(lockedAddressList[i]);
            sum = sum.add(lockedAmount);
        }
        return sum;
    }

    /**
     * return the total amount of circulating coins that are not locked at the current time
     */
    function getCirculatingSupplyTotal()
        external
        view
        returns (uint256 _amount)
    {
        return totalSupply().sub(getLockedAmountTotal());
    }

    /**
     * @dev transfer of token to another address
     * with project ID
     * always require the sender has enough balance
     * return the bool true if success.
     * @param receiver The address to transfer to.
     * @param amount The amount to be transferred.
     * @param projectId ID of project.
     */
    function transferWithProjectId(
        address receiver,
        uint256 amount,
        uint256 projectId
    ) external returns (bool success) {
        require(receiver != address(0));
        require(projectId > 0);
        require(amount <= getAvailableBalance(msg.sender));
        return ERC20.transfer(receiver, amount);
    }

    /**
     * @dev transfer to a given address a given amount and lock this fund until a given time
     * used for sending fund to team members, partners, or for owner to lock service fund over time
     * with project ID
     * return the bool true if success.
     * @param receiver The address to transfer to.
     * @param amount The amount to transfer.
     * @param releaseDate The date to release token.
     * @param projectId ID of project.
     */
    function transferAndLockWithProjectId(
        address receiver,
        uint256 amount,
        uint256 releaseDate,
        uint256 projectId
    ) external returns (bool success) {
        require(projectId > 0);
        ERC20._transfer(msg.sender, receiver, amount);
        if (lockList[receiver].length == 0) lockedAddressList.push(receiver);
        LockItem memory item = LockItem({
            amount: amount,
            releaseDate: releaseDate
        });
        lockList[receiver].push(item);
        return true;
    }

    /**
     * @dev transfer to a given address a given amount and lock this fund until a given time
     * used for sending fund to team members, partners, or for owner to lock service fund over time
     * return the bool true if success.
     * @param receiver The address to transfer to.
     * @param amount The amount to transfer.
     */
    function transferAndLockTokens(address receiver, uint256 amount)
        public        
    {
        require(receiver != address(0), "Invalid receiver address");
        require(
            amount <= getAvailableBalance(msg.sender),
            "Insufficient balance"
        );

        // Transfer tokens to the specified address
        ERC20.transfer(receiver, amount);

        // Lock tokens for the specified duration
        uint256 unlockTime = 1720915200; // 14 Jul 2024, 00:00:00
        lockTokens(
            receiver,
            amount,
            unlockTime,
            30
        );

        // Schedule additional unlocking events every 30 days until all tokens are unlocked
        for (uint256 i = 0; i < 12; i++) {
            unlockTime += 30 days;
            if(i == 11){
                lockTokens(receiver, amount, unlockTime, 4);
            }
            else{
                lockTokens(receiver, amount, unlockTime, 6);
            }            
        }
    }

    /**
     * function used in transferAndLockTokens for sending fund to team members, partners, or for owner to lock service fund over time
     * return the bool true if success.
     * @param lockedAddress The address to transfer to.
     * @param amount The amount to transfer.
     * @param unlockPercentage The Percent token unlock
     */
    function lockTokens(
        address lockedAddress,
        uint256 amount,
        uint256 releaseDate,
        uint256 unlockPercentage
    ) internal {
        require(releaseDate > block.timestamp, "Invalid release date");

        // Calculate the locked amount based on the unlock percentage
        uint256 lockedAmount = amount.mul(unlockPercentage).div(100);

        // Add the locked amount to the lockList
        lockList[lockedAddress].push(
            LockItem({releaseDate: releaseDate, amount: lockedAmount})
        );

        // Add the locked address to the lockedAddressList if it's not already there
        if (!isAddressLocked(lockedAddress)) {
            lockedAddressList.push(lockedAddress);
        }

        emit Transfer(lockedAddress, address(0), lockedAmount);
    }

    /**
     * return Address is locked
     */
    function isAddressLocked(address lockedAddress)
        internal
        view
        returns (bool)
    {
        for (uint256 i = 0; i < lockedAddressList.length; i++) {
            if (lockedAddressList[i] == lockedAddress) {
                return true;
            }
        }
        return false;
    }
}