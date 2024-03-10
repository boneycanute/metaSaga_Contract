// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MetaSaga is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    // Base URL for card images
    string private constant baseImageUrl =
        "https://charactergenlitev2.onrender.com/v1/card/seed/";

    // Mapping from user address to their owned card IDs
    mapping(address => uint256[]) private userCards;

    // Price to draw a card
    uint256 public constant drawPrice = 0.0001 ether;

    constructor() {
        _tokenIdCounter = 1; // Start token ID count from 1
    }

    function drawCard() public payable returns (uint256) {
        require(msg.value >= drawPrice, "Insufficient funds to draw a card");

        uint256 newCardId = _tokenIdCounter++;
        bytes32 cardHex = keccak256(
            abi.encodePacked(
                newCardId,
                block.timestamp,
                block.difficulty,
                msg.sender
            )
        );
        string memory cardUri = string(
            abi.encodePacked(
                baseImageUrl,
                bytes32ToHexString(cardHex),
                "/1x.png"
            )
        );

        _mint(msg.sender, newCardId);
        _setTokenURI(newCardId, cardUri);
        userCards[msg.sender].push(newCardId);

        return newCardId;
    }

    function bytes32ToHexString(
        bytes32 _bytes
    ) private pure returns (string memory) {
        bytes memory hexString = new bytes(64);
        for (uint i = 0; i < 32; i++) {
            byte b = _bytes[i];
            byte high = byte(uint8(b) / 16);
            byte low = byte(uint8(b) - 16 * uint8(high));
            hexString[2 * i] = convertDigitToHex(high);
            hexString[2 * i + 1] = convertDigitToHex(low);
        }
        return string(hexString);
    }

    function convertDigitToHex(byte _digit) private pure returns (byte) {
        if (uint8(_digit) < 10) {
            return byte(uint8(_digit) + 48);
        } else {
            return byte(uint8(_digit) + 87);
        }
    }

    function getUserCards(address user) public view returns (string[] memory) {
        if (userCards[user].length == 0) {
            userCards[user] = new uint256[](0); // Initialize for new user
        }

        uint256[] memory ownedTokenIds = userCards[user];
        string[] memory cardURIs = new string[](ownedTokenIds.length);
        for (uint i = 0; i < ownedTokenIds.length; i++) {
            cardURIs[i] = tokenURI(ownedTokenIds[i]);
        }

        return cardURIs;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        (bool sent, ) = owner().call{value: balance}("");
        require(sent, "Failed to send Ether");
    }
}
