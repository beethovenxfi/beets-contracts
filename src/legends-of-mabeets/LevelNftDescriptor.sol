// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import "./INFTDescriptor.sol";
import "./LegendsOfMaBeets.sol";

contract LevelNftDescriptor is INFTDescriptor {
    using Strings for uint256;

    string private constant S3 = "https://beethoven-assets.s3.eu-central-1.amazonaws.com/mabeets-legends/";

    LegendsOfMaBeets public immutable legendsContract;

    constructor(LegendsOfMaBeets lom) {
        legendsContract = lom;
    }

    /// @notice Returns a link to the stored image
    function constructTokenURI(uint256 tokenId) external view override returns (string memory uri) {
        LegendsOfMaBeets.PositionInfo memory position = legendsContract.getPositionForId(tokenId);
        uri = string.concat(S3, position.level.toString(), ".png");
    }
}
