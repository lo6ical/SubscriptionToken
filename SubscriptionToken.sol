// SPDX-License-Identifier: MIT

//Solidity version
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


contract SubscriptionToken is ERC721, Pausable, Ownable {
    using Strings for uint256;
    string baseURI;

    struct TokenConfig {
        uint256 tokenId;
    }
    TokenConfig public tokenConfig;

    struct SubscriptionDetails {
        uint256 duration;
        uint256 tier;
        uint256 subDate;
        uint256 subEnds;
    }
    //Mapping for storing token data
    mapping(uint256 => SubscriptionDetails) public subscriptions;

    
    constructor() ERC721("Subscription Token", "SUB") {
        tokenConfig.tokenId = 0;
    }

    //subscription durations and tiers for this example are 15/30 and 1/2
    function mint(uint256 _duration, uint256 _tier) external whenNotPaused {
        require(_duration == 15 || _duration == 30, "incorrect duration input");
        require(_tier == 1 || _tier == 2, "incorrect duration input");

        uint256 tokenId = tokenConfig.tokenId;
        uint256 duration = _duration;
        uint256 tier = _tier;

        unchecked {
            tokenConfig.tokenId++;
        }   
        updateSubDetails(tokenId, duration, tier);
        
        _safeMint(msg.sender, tokenId);
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(
        _exists(tokenId),
        "ERC721Metadata: URI query for nonexistant token"
    );
    string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString()))
        : "";
    }

    function updateSubDetails(uint256 tokenId, uint256 duration, uint256 tier) internal {
        subscriptions[tokenId].duration = duration;
        subscriptions[tokenId].tier = tier;
        subscriptions[tokenId].subDate = block.timestamp;
        if (duration == 15) {
            subscriptions[tokenId].subEnds = block.timestamp + 15 days;
        } 
        if (duration == 30) {
            subscriptions[tokenId].subEnds = block.timestamp + 30 days;
        }
    }


    function hasValidSubscription(uint256 tokenId) external view returns (string memory){
        string memory response;
        if (subscriptions[tokenId].tier == 0) {
            response = "Token does not exist";
        }
        else if (subscriptions[tokenId].subEnds < block.timestamp) {
            response = "Not valid";
        }
        else if (subscriptions[tokenId].subEnds > block.timestamp) {
            response = "Valid";
        }
        return response;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner { 
        baseURI = _newBaseURI;
    }

    function pauseContract() public onlyOwner{
        _pause();
    }

    function unpauseContract() public onlyOwner{
        _unpause();
    }
}
