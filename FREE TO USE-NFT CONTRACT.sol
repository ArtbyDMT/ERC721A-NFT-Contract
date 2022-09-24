// SPDX-License-Identifier: GPL-3.0


pragma solidity >=0.7.0 <0.9.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//add your contract name in the space below with no quotation marks
contract "NFT Contract Name Here" is ERC721A, Ownable, ReentrancyGuard {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  string public notRevealedUri;
  uint256 public cost = 0 ether;
  uint256 public maxSupply = 1000; //total nft supply
  uint256 public freesupply = 10; //amount of supply you want to be made free (0-all)
  uint256 public MaxperWallet = 5; //max amount a wallet can mint, reentrancy wont let sending to other wallet and mint again
  uint256 public maxpertx = 5 ; // max mint per tx
  bool public paused = true; //if true, no one can mint
  bool public revealed = false; //if false, collection hidden, delete if no hidden prereveal

  constructor(
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721A("","") {//enter ("name","token name") ex. ("degen", "DGN")
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }
      function _startTokenId() internal view virtual returns (uint256) {
        return 1;
    }

  // public
    function freemint(uint256 tokens) public payable nonReentrant {
    require(!paused, "message here"); //message to show when trying to mint early
    uint256 supply = totalSupply();
    require(tokens > 0, "message here"); //message to show that you need at least one nft to mint
    require(tokens <= maxpertx, "message here"); //message to show when someone tries to mint more than max
    require(supply + tokens <= freesupply, "message here"); //message to show to head to secondary
    require(_numberMinted(_msgSender()) + tokens <= MaxperWallet, "message here"); //message to show more than max trying to get minted
    require(msg.value >= cost * tokens, "message here"); //message showing someone doesn't have enough crypto to purchase

      _safeMint(_msgSender(), tokens);
    
  }



  /// @dev use it for giveaway and mint for yourself
     function gift(uint256 _mintAmount, address destination) public onlyOwner nonReentrant {
    require(_mintAmount > 0, "need to mint at least 1 NFT");
    uint256 supply = totalSupply();
    require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

      _safeMint(destination, _mintAmount);
    
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721AMetadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

    function numberMinted(address owner) public view returns (uint256) {
    return _numberMinted(owner);
  }


  //only owner
  function reveal(bool _state) public onlyOwner {
      revealed = _state;
  }
  
  function setMaxPerWallet(uint256 _limit) public onlyOwner {
    MaxperWallet = _limit;
  }

  function setmaxpertx(uint256 _maxpertx) public onlyOwner {
    maxpertx = _maxpertx;
  }

  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

    function setMaxsupply(uint256 _newsupply) public onlyOwner {
    maxSupply = _newsupply;
  }

    function setfreesupply(uint256 _newsupply) public onlyOwner {
    freesupply = _newsupply;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
  
 
  function withdraw() public payable onlyOwner nonReentrant {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }
}


//special thanks to Daniel @Hashlips and FazelPejmanfar @Pejmanfarfazel


