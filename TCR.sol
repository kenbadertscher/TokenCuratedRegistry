pragma solidity ^0.5.1;

contract TokenCuratedRegistry {
    
    address public owner;
    struct CandidateInfo {
        address owner;
        string businessName;
        string businessAddress;
        uint40 phoneNumber;
        bool isListed;
    }

    mapping(address => bool) beenListed;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public depositedBalance;
    mapping(address => uint8) public indexOfListing;

    CandidateInfo[10] public allCandidates;
    uint256 public listingCost;
    uint256 public tokenPrice;

    constructor (uint256 _listingCost, uint256 _tokenPrice) public {
        owner = msg.sender;
        balanceOf[address(0)] = 1000000;
        listingCost = _listingCost;
        tokenPrice = _tokenPrice;
    }

    function _transfer(address to, address sender, uint256 amt) internal {
        require(balanceOf[to] >= amt, "Error, you don't have enough tokens for that");
        balanceOf[to] += amt;
        balanceOf[sender] -= amt;
    }

    function buyTokens() public payable {
        require(msg.value > tokenPrice, "Error, you must send enough ether to buy a single token");
        require(balanceOf[address(0)] >= msg.value / tokenPrice, "Error not enough tokens for sale");
        _transfer(msg.sender, address(0), msg.value / tokenPrice);
    }

    function transferTokens(address to, uint256 amt) public {
        require(balanceOf[msg.sender] >= amt, "Error, not enough tokens to do that");
        _transfer(to, msg.sender, amt);
    }

    function getFreeListingIndex() public view returns (uint8) {
        for (uint8 i = 0; i < 10; i++) {
            if (allCandidates[i].isListed == false)
                return i;
        }
        revert("Error, no free listing");
    }

    function getListed(  
        string memory businessName,
        string memory businessAddress,
        uint40 phoneNumber
        ) public 
    {
        require(balanceOf[msg.sender] >= listingCost, "Error, not enough tokens to get listed");
        require (depositedBalance[msg.sender] != listingCost, "Error, a single address cannot list more than one candidate");
        uint256 freeIndex = getFreeListingIndex();
        
        indexOfListing[msg.sender] = uint8(freeIndex);
        balanceOf[msg.sender] -= listingCost;
        depositedBalance[msg.sender] += listingCost;
        
        allCandidates[freeIndex].owner = msg.sender;
        allCandidates[freeIndex].businessName = businessName;
        allCandidates[freeIndex].businessAddress = businessAddress;
        allCandidates[freeIndex].phoneNumber = phoneNumber;
        allCandidates[freeIndex].isListed = true;
    }

    function removeListing() public {
        require(depositedBalance[msg.sender] == listingCost, "Error, you must have a listing to remove one");
        uint8 index = indexOfListing[msg.sender];
        delete allCandidates[index];
        balanceOf[msg.sender] += listingCost;
        depositedBalance[msg.sender] -= listingCost;
    }

    function getListing(uint8 listIndex) public view returns (
        address owner,
        string memory businessName,
        string memory businessAddress,
        uint40 phoneNumber
        ) {
            require(allCandidates[listIndex].isListed == true, "Error, nothing listed at this index");
            return (
                allCandidates[listIndex].owner,
                allCandidates[listIndex].businessName,
                allCandidates[listIndex].businessAddress,
                allCandidates[listIndex].phoneNumber
            );
        }

}

