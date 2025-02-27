// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC721Enumerable} from "openzeppelin-contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract OgMaBeets is ERC721Enumerable, Ownable {
    /// @dev Nonce to use for new relicId.
    uint256 private idNonce;
    string private baseTokenURI;

    struct OgPositionInfo {
        uint256 amount;
        uint256 level;
    }

    // /// @notice Info of each og position.
    mapping(uint256 => OgPositionInfo) public positionForId;

    /**
     * @dev Constructs and initializes the contract..
     */
    constructor() ERC721("OG maBeets position", "OGmaBEETS") Ownable(msg.sender) {}

    function mint(address _to, uint256 _level, uint256 _amount) public onlyOwner returns (uint256 id) {
        id = _mint(_to);
        OgPositionInfo storage position = positionForId[id];
        position.amount = _amount;
        position.level = _level;
        baseTokenURI = "https://beethoven-assets.s3.eu-central-1.amazonaws.com/og-relic-nft.png";
    }

    /// @notice Returns a OgPositionInfo object for the given id.
    function getPositionForId(uint256 id) external view returns (OgPositionInfo memory position) {
        position = positionForId[id];
    }

    function setTokenURI(string memory _tokenURI) public onlyOwner {
        baseTokenURI = _tokenURI;
    }

    /**
     * @notice Returns the ERC721 tokenURI.
     * @param tokenId The NFT ID to get the tokenURI for.
     */
    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        return baseTokenURI;
    }

    /// @dev Increments the ID nonce and mints a new Relic to `to`.
    function _mint(address to) private returns (uint256 id) {
        id = ++idNonce;
        _safeMint(to, id);
    }
}
