// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./RealEstateToken.sol";

contract RealEstateInvestment is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter internal _propertyIds;

    event DepositRent(address _sender, uint256 _amount);
    event TokenClaimLog(address _addr, string _msg);
    event DividendWithdraw(address _sender);

    struct Property {
        RealEstateToken token;
        uint256 minimumInvestmentInEther;
        uint256 maximumInvestmentInEther;
        uint256 openForInvertors;
        address propertyOwner;
        uint totalFundRaised;
        uint ICOCutOffPeriod;
    }

    struct InvestorDetail {
        address investorAddress;
        uint256 investedEther;
    }

    mapping(uint256 => Property) public properties;
    mapping(uint256 => mapping(address => uint256)) internal investorDetails;
    mapping(uint256 => mapping(address => uint256)) internal tokenOwed;

    modifier PropertyExist(uint _propertyId) {
        require(isPropertyExist(_propertyId), "Property does not Exist");
        _;
    }

    function listPropertyByOwner(
        uint256 _minimumInvestmentInEther,
        uint256 _maximumInvestmentInEther,
        uint256 _openForInvertors,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _totalTokenSupply
    ) external nonReentrant {
        require(
            _minimumInvestmentInEther > 0,
            "Minimum Investment should not be zero "
        );
        require(
            _maximumInvestmentInEther > 0,
            "Maximum Investment should not be zero "
        );
        require(
            _openForInvertors > 0 && _openForInvertors < 100,
            "Invalid invertors %"
        );
        require(_totalTokenSupply > 0, "Token supply should not be zero ");
        RealEstateToken newToken = new RealEstateToken(
            _tokenName,
            _tokenSymbol,
            _totalTokenSupply
        );
        uint256 tokenReservedforInvestor = (newToken.totalSupply() *
            _openForInvertors) / 100;
        uint256 tokenReservedforOwner = newToken.totalSupply() -
            tokenReservedforInvestor;
        //newToken.transfer(msg.sender, tokenReservedforOwner);
        tokenOwed[getCounter()][msg.sender] += tokenReservedforOwner;

        Property memory newPropertyInstance = Property({
            token: newToken,
            minimumInvestmentInEther: _minimumInvestmentInEther,
            maximumInvestmentInEther: _maximumInvestmentInEther,
            openForInvertors: _openForInvertors,
            propertyOwner: msg.sender,
            totalFundRaised: 0,
            ICOCutOffPeriod: block.timestamp + 5 seconds // 1 minutes //1 weeks
        });
        properties[getCounter()] = newPropertyInstance;
        setCounter();
    }

    function setCounter() internal {
        _propertyIds.increment();
    }

    function getCounter() internal view returns (uint256) {
        return _propertyIds.current();
    }

    function isPropertyExist(uint256 _propertyId) internal view returns (bool) {
        return (properties[_propertyId].propertyOwner != address(0));
    }

    //assuming 1 token = 1 wei
    function investInProperty(
        uint256 _propertyId,
        uint256 _amountInEther
    ) external payable PropertyExist(_propertyId) nonReentrant {
        require(
            _amountInEther == msg.value && _amountInEther > 0,
            "Invalid Invested Ether"
        );
        Property storage tempPropertyInstance = properties[_propertyId];
        require(
            block.timestamp < tempPropertyInstance.ICOCutOffPeriod,
            "Fund raising time completed"
        );
        require(
            tempPropertyInstance.totalFundRaised + _amountInEther <=
                tempPropertyInstance.maximumInvestmentInEther,
            "Mazimum Funding Reached"
        );
        uint256 grantToken = msg.value;
        investorDetails[_propertyId][msg.sender] += msg.value;
        tokenOwed[_propertyId][msg.sender] += grantToken;
        tempPropertyInstance.totalFundRaised += _amountInEther;
    }

    function claimToken(
        uint256 _propertyId
    ) external PropertyExist(_propertyId) nonReentrant {
        Property storage tempPropertyInstance = properties[_propertyId];
        require(
            block.timestamp > tempPropertyInstance.ICOCutOffPeriod,
            "Investment raising is going on"
        );
        address tokenAddr = address(tempPropertyInstance.token);
        require(
            investorDetails[_propertyId][msg.sender] != 0,
            "You are not authorized investor"
        );
        require(tokenOwed[_propertyId][msg.sender] > 0, "Token claimed");
        if (
            tempPropertyInstance.totalFundRaised >=
            tempPropertyInstance.minimumInvestmentInEther
        ) {
            uint tokenBalance = tokenOwed[_propertyId][msg.sender];
            (tempPropertyInstance.token).transfer(msg.sender, tokenBalance);
            tokenOwed[_propertyId][msg.sender] = 0;
            (bool sent, ) = tokenAddr.call{
                value: investorDetails[_propertyId][msg.sender]
            }("");
            require(sent, "Failed to send Ether");
            emit TokenClaimLog(msg.sender, "Token claimed successfully");
        } else {
            tokenOwed[_propertyId][msg.sender] = 0;
            uint returnEther = investorDetails[_propertyId][msg.sender];
            investorDetails[_propertyId][msg.sender] = 0;
            payable(msg.sender).transfer(returnEther);
            emit TokenClaimLog(
                msg.sender,
                "Ether returned due to under subscription"
            );
        }
    }

    function depositRent(
        uint256 _propertyId
    ) external payable PropertyExist(_propertyId) nonReentrant {
        Property storage tempPropertyInstance = properties[_propertyId];
        address tokenAddr = address(tempPropertyInstance.token);
        require(
            block.timestamp > tempPropertyInstance.ICOCutOffPeriod,
            "Investment raising is going on"
        );
        (bool sent, ) = tokenAddr.call{value: msg.value}(
            abi.encodeWithSignature("depositDividend()")
        );
        require(sent, "Failed to send Ether");
        emit DepositRent(msg.sender, msg.value);
    }

    function withDrawDividend(uint256 _propertyId) external nonReentrant {
        require(isPropertyExist(_propertyId), "Property does not Exist");
        Property storage tempPropertyInstance = properties[_propertyId];
        require(
            block.timestamp > tempPropertyInstance.ICOCutOffPeriod,
            "Investment raising is going on"
        );
        tempPropertyInstance.token.withdraw(msg.sender);
        emit DividendWithdraw(msg.sender);
    }
}
