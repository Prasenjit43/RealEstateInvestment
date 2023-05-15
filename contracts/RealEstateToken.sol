// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RealEstateToken is ERC20 {
    uint256 public dividendPerToken;
    mapping(address => uint256) public dividendBalanceOf;
    mapping(address => uint256) public dividendCredited;
    address baseContract;

    event DepositRent1(
        uint indexed _rentDeposited,
        uint indexed _totalSupply,
        uint indexed _dividentPerToken
    );

    receive() external payable {}

    fallback() external payable {}

    modifier onlyBaseContract() {
        require(msg.sender == baseContract, "You are not authorized");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint _totalTokenSupply
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, _totalTokenSupply * (10 ** decimals()));
    }

    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (!isContract(from) && !isContract(to)) {
            updateDividend(from);
            updateDividend(to);
        }
        super._beforeTokenTransfer(from, to, amount);
    }

    function depositDividend() external payable {
        dividendPerToken += (msg.value / this.totalSupply());
        emit DepositRent1(msg.value, this.totalSupply(), dividendPerToken);
    }

    function updateDividend(address _addr) internal {
        uint256 owed = dividendPerToken - dividendCredited[_addr];
        dividendBalanceOf[_addr] += this.balanceOf(_addr) * owed;
        dividendCredited[_addr] = dividendPerToken;
    }

    function withdraw(address _receiver) external {
        updateDividend(_receiver);
        uint256 amount = dividendBalanceOf[_receiver];
        dividendBalanceOf[_receiver] = 0;
        bool sent = payable(_receiver).send(amount);
        require(sent, "Failed to withdraw rent");
    }
}
