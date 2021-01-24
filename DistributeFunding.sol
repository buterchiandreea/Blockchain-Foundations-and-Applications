pragma solidity ^0.5.12;

contract DistributeFunding {
    
    address owner;
    uint totalPercentCoverage;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    struct Beneficiary {
        address payable beneficiaryAddress;
        uint percent;
    }
    
    /* 
        An array that contains beneficiaries information.
    */
    Beneficiary [] beneficiariesInformation;
    
    constructor () 
        public 
    {
        owner = msg.sender;
        totalPercentCoverage = 0;
    }
    
    function () external payable {}
    
    /*
        Use this method to add a beneficiary 
    */
    function addBeneficiary(address payable _addr, uint _percent) 
        external
        onlyOwner
    {
        require(totalPercentCoverage + _percent <= 100, 'Incorrect percent... ');
        beneficiariesInformation.push(Beneficiary(_addr, _percent));
        totalPercentCoverage += _percent;
    }
    
    /*
        Use this method to remove a beneficiary 
    */
    function removeBeneficiary(address payable _addr) 
        external
        onlyOwner
    {
        for (uint i = 0; i < beneficiariesInformation.length; i++) {
            if (beneficiariesInformation[i].beneficiaryAddress == _addr) {
                totalPercentCoverage -= beneficiariesInformation[i].percent;
                delete beneficiariesInformation[i];
            }
        }
    }
    
    /*
        Use this method to send the collected funds to beneficiaries.
    */
    function transferFundsToBeneficiaries() 
        external
        onlyOwner
    {
        require (address(this).balance > 0, 'Insufficient funds... ');
        uint sumToTransfer;
        address payable beneficiaryAddress;
        for (uint i = 0; i < beneficiariesInformation.length; i++) {
            sumToTransfer = address(this).balance * beneficiariesInformation[i].percent / 100;
            beneficiaryAddress = beneficiariesInformation[i].beneficiaryAddress;
            beneficiaryAddress.transfer(sumToTransfer);   
        }
    }
    
    function getContractBalance() 
        public
        view
        returns(uint)
    {
        return address(this).balance;
    }
}