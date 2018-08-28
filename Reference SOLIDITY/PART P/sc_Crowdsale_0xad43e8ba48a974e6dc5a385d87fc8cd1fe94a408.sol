/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

interface token {
    function transfer(address receiver, uint amount);
}

contract Crowdsale {
    address public beneficiary;
    uint public amountRaised;
    token public tokenReward;
    uint256 public soldTokensCounter;
    uint public price = 0.000142857 ether;
    bool public crowdsaleClosed = false;
    bool public adminVer = false;
    mapping(address => uint256) public balanceOf;


    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, uint price, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function Crowdsale() {
        beneficiary = 0xA4047af02a2Fd8e6BB43Cfe8Ab25292aC52c73f4;
        tokenReward = token(0x12AC8d8F0F48b7954bcdA736AF0576a12Dc8C387);
    }

    modifier onlyOwner {
        require(msg.sender == beneficiary);
        _;
    }

    /**
     * Check ownership
     */
    function checkAdmin() onlyOwner {
        adminVer = true;
    }

    /**
     * Return unsold tokens to beneficiary address
     */
    function getUnsoldTokens(uint val_) onlyOwner {
        tokenReward.transfer(beneficiary, val_);
    }

    /**
     * Return unsold tokens to beneficiary address with decimals
     */
    function getUnsoldTokensWithDecimals(uint val_, uint dec_) onlyOwner {
        val_ = val_ * 10 ** dec_;
        tokenReward.transfer(beneficiary, val_);
    }

    /**
     * Close/Open crowdsale
     */
    function closeCrowdsale(bool closeType) onlyOwner {
        crowdsaleClosed = closeType;
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable {
        require(!crowdsaleClosed && msg.value <= 2 ether);                                  //1 ether is minimum to contribute                                                                
        uint amount = msg.value;                                                           //save users eth value
        balanceOf[msg.sender] += amount;                                                   //save users eth value in balance list 
        amountRaised += amount;                                                            //update total amount of crowdsale
        uint sendTokens = (amount / price) * 10 ** uint256(18);                            //calculate user's tokens
        tokenReward.transfer(msg.sender, sendTokens);                                      //send tokens to user
        soldTokensCounter += sendTokens;                                                   //update total sold tokens counter
        FundTransfer(msg.sender, amount, price, true);                                     //pin transaction data in blockchain
        if (beneficiary.send(amount)) { FundTransfer(beneficiary, amount, price, false); } //send users amount to beneficiary
    }
}