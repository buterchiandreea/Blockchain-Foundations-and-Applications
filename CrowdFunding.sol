pragma solidity ^0.5.12;

contract CrowdFunding {
    
    address owner;
    modifier onlyOwner() {
        require(msg.sender == owner);
    _;
    }
    
    address payable distributeFundingContractAddress;
    uint public fundingGoal;
    uint public collectedFunds;
    bool isFundingFinished;
    
    /*
        A mapping that stores the addresses of the contributors, along with the contribution's value.
    */
    mapping(address => uint) public contributorsInformation;
    
    /*
        A mapping that stores the addresses of the contributers, along with a boolean value that indicates the status of the contributers.
    */
    mapping(address => bool) contributers;
    
    constructor () public {
        owner = msg.sender;
        collectedFunds = 0;
    }
    
    /*
        Use this method to set the address of the smart contrat that will be responsible with funds distribution, along with the minimum amount to be collected.
    */
    function setDistributeFundingContract(address payable _distributeFundingContractAddress, uint _fundingGoal) 
        external
    {   
        require(isFundingFinished == true || collectedFunds == 0);
        distributeFundingContractAddress = _distributeFundingContractAddress;
        fundingGoal = _fundingGoal;
        isFundingFinished = false;
    }
    
    /*
        Use this method to check if the sender is indeed a contributer.
    */
    function isContributer(address payable _addr)
        internal
        view
        returns(bool)
    {
        if (contributers[_addr] == true) {
            return true;
        }
        return false;
    }
    
    /* 
        Use this method in order to contribute. This method can be called iff the funding goal was not yet achieved.
    */
    function contribute()
        external
        payable
    {   
        require(collectedFunds < fundingGoal, 'The funding goal was achieved. You can not contribute anymore.');
    
        if (isContributer(msg.sender)) {
            contributorsInformation[msg.sender] += msg.value;
        } else {
            contributorsInformation[msg.sender] = msg.value;
            contributers[msg.sender] = true;
        }
        collectedFunds += msg.value;
    }
    
    /*
        Use this method to retrieve the contribution. This method can be called iff the funding goal was not yet achieved.
    */
    
    function retrieveContribution(uint _amount)
        external
    {   
        uint contribution = contributorsInformation[msg.sender];
        require(collectedFunds < fundingGoal, 'The funding goal was already achieved. The contribution can not be canceled anymore.');
        require(isContributer(msg.sender), 'You can not retrieve your contribution. You are not a registered contributer.');
        require(contribution >= _amount, 'The amount you want to retrieve is greater than your contribution.');
        
        (msg.sender).transfer(contribution);
        collectedFunds -= _amount;
        contributorsInformation[msg.sender] -= _amount;
        
        if (contributorsInformation[msg.sender] == 0) {
            delete contributorsInformation[msg.sender];
            delete contributers[msg.sender];
        }
    }
    
    /*
        Use this method to send the funds to the smart contract that will distribute the collected funds.
    */
    function transferCollectedFunds()
        external
        payable
        onlyOwner
    {
        require(collectedFunds >= fundingGoal, 'The funding goal was not achieved yet.');
        distributeFundingContractAddress.transfer(collectedFunds);
        collectedFunds = 0;
        fundingGoal = 0;
        isFundingFinished = true;
    }
    

    /*
        Helper method which is used to convert an integer to a string.
    */
    function uint2str(uint _number_to_convert) internal pure returns (string memory _uintAsString) {
        if (_number_to_convert == 0) {
            return "0";
        }
        uint number = _number_to_convert;
        uint length;
        while (number != 0) {
            length++;
            number /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint index = length - 1;
        while (_number_to_convert != 0) {
            bstr[index--] = byte(uint8(48 + _number_to_convert % 10));
            _number_to_convert /= 10;
        }
        return string(bstr);
    }
    
    /*
        Use this method in order to see the status of the funds collection.
    */
    
    function getFundsCollectionStatus() 
        public
        view
        returns(string memory)
    {
        return string(abi.encodePacked("Collected funds: ", uint2str(collectedFunds), ". ", "Funding goal: ", uint2str(fundingGoal), "."));
    }
}