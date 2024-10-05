// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DonationProofSBT is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string private _baseTokenURI;

    struct DonationInfo {
        uint256 amount;
        address project;
        uint256 timestamp;
        uint256 blockNumber;
    }

    mapping(uint256 => DonationInfo) public donationInfo;

    event DonationProofMinted(address indexed donor, uint256 amount, address indexed project, uint256 tokenId);

    constructor() ERC721("DonationProof", "DPF") Ownable(msg.sender) {
        _baseTokenURI = "https://rose-written-jellyfish-653.mypinata.cloud/ipfs/QmZiZZd4F2NScgioJR2GKyvywqXQi3MGcKjbiosP7geG5g?pinataGatewayToken=s0BFC594wAJX3O6PQb7zBWU7ya34HL1dMZyATFnfWqGSfskmg-F6GmXEzAQCV4By";
    }

    function mint(address to, uint256 amount, address project, uint256 blockNumber) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        donationInfo[tokenId] = DonationInfo({
            amount: amount,
            project: project,
            timestamp: block.timestamp,
            blockNumber: blockNumber
        });

        emit DonationProofMinted(to, amount, project, tokenId);

        return tokenId;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Prevent transfers
    function _transfer(address from, address to, uint256 tokenId) internal override {
        revert("SBT: transfer not allowed");
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        revert("SBT: transfer not allowed");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        revert("SBT: transfer not allowed");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        revert("SBT: transfer not allowed");
    }
}