// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    //errors
    error MoodNft_CantFlipMoodIfNotOwnerOrAuthorized();

    uint private s_tokenCounter;
    string private s_happySvgImgUri;
    string private s_sadSvgImgUri;

    enum Mood { HAPPY, SAD }

    mapping (uint256 => Mood) private s_tokenIdToMood;
    constructor(
        string memory _happySvgImgUri,
        string memory _sadSvgImgUri
    ) ERC721("MoodNft", "MOOD") {
        s_tokenCounter = 0;
        s_happySvgImgUri = _happySvgImgUri;
        s_sadSvgImgUri = _sadSvgImgUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }

    function flipMood(uint256 _tokenId) public {
        if (_ownerOf(_tokenId) != msg.sender || !_isAuthorized(_ownerOf(_tokenId), msg.sender, _tokenId)) {
            revert MoodNft_CantFlipMoodIfNotOwnerOrAuthorized();
        }
        s_tokenIdToMood[_tokenId] = s_tokenIdToMood[_tokenId] == Mood.HAPPY
            ? Mood.SAD
            : Mood.HAPPY;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI (
        uint256 _tokenId
        ) public view virtual override returns (string memory) {
        string memory imageUri;
        if (s_tokenIdToMood[_tokenId] == Mood.HAPPY) {
            imageUri = s_happySvgImgUri;
        } else {
            imageUri = s_sadSvgImgUri;
        }

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name": "',
                            name(),
                            '", "description": an NFT that reflects the owner''s mood",',
                            '"attributes": [{"trait_type": "moodiness", "value": 100}],',
                            '"image": "',
                            imageUri,
                            '"}'
                        )
                    )
                )
            )
        );
    }
}