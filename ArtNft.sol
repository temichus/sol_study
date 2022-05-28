// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol';
import 'ArtToken.sol';

contract ArtNft  is ERC721, ERC721Enumerable{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    ArtToken public token;
    address public admin;

    // Mapping of tokens available on a market
    mapping(uint256 => uint256) public _LastPriceOnMarket;
    mapping(uint256 => uint256) public _TokensOnMarket;

    ///previous  3 owners mapping
    mapping(uint256 => mapping(uint256 => address)) public ownersHist;
    uint256 public first = 1;
    uint256 public last = 0;
    uint256 ownersToSafe = 3;
    uint256  fee_per_owner = 300;

    function addOwner(uint256 tokenId, address owner) private {
        if (last >= first){
            for (uint256 i=first; i<=last; i++){
                token.transferFrom(msg.sender, ownersHist[tokenId][i], (_LastPriceOnMarket[tokenId] * fee_per_owner) / 10000);
            }
        }
        if (owner != address(0)) {
            last += 1;
            ownersHist[tokenId][last] = owner;
            }
        if ((last>=first) && (last - first > (ownersToSafe-1))) {
            delete ownersHist[tokenId][first];
            first += 1;
        }
    }


    constructor() ERC721('ArtNft', 'ARTNFT'){  
        admin = msg.sender;
        token = ArtToken(0xd9145CCE52D386f254917e481eB44e9943F39138);
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        // in case of any transaction you shoul pay to prevoius owners base on _LastPriceOnMarket
        addOwner(tokenId, from);
        super._beforeTokenTransfer(from, to, tokenId);

    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
     function mint(address to, uint256 price) public virtual {
        require(admin == msg.sender, "only admin");
        uint256 tokenId = _tokenIds.current();
        _mint(to, tokenId);
        _LastPriceOnMarket[tokenId] = price;
        _tokenIds.increment();
    }


    function setPrice(uint256 tokenId, uint256 amount) public virtual {
        address owner = ERC721.ownerOf(tokenId);
        require(msg.sender == owner, "Only owner can set price");
        _TokensOnMarket[tokenId] = amount;
    }


    function BuyFromMarket(uint256 tokenId) public virtual {
        require(_TokensOnMarket[tokenId]!=uint256(0), "token is not avilable on market");
        address owner = ERC721.ownerOf(tokenId);
        //update _LastPriceOnMarket
        _LastPriceOnMarket[tokenId] = _TokensOnMarket[tokenId];
        uint256 own =0;
        if (last >= first){
            own = (last-first+1);
        }
        token.transferFrom(msg.sender, owner,  (_TokensOnMarket[tokenId] - (_TokensOnMarket[tokenId] * fee_per_owner *  own / 10000)));
        _transfer(owner, msg.sender, tokenId);
        delete _TokensOnMarket[tokenId];
    }




}