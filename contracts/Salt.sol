// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./ERC721ATradable.sol";

/**
 * @title ERC721AR
 * @author 
 * @notice ERC721A + royalties + proxies.
 */

contract Salt is ERC721ATradable {
    using ECDSA for bytes32;
    using Strings for uint256;

    uint256 public saltValue = 0 ether;
    uint256 public maxSupply = 333;

    address private signerAddress = 0x1e72D4438c49f0f523E9Cbc85c33ca33Ad24B870;

    string public script;
    string public scriptType = "p5js";

    event Mint(address indexed to, uint256 indexed salt);

    mapping(bytes32 => bool) private usedHashes;
    mapping(uint256 => bytes32) public saltHashes;

    constructor(
      string memory baseTokenURI_
    ) ERC721ATradable("Salt token", "SALT", baseTokenURI_) {
        receiverAddress = 0x1e72D4438c49f0f523E9Cbc85c33ca33Ad24B870;
    }


    function generateSalt(bytes32 messageHash, bytes memory signature) external payable {
        uint256 salt = totalSupply();
        require(tx.origin == msg.sender, "The caller is another contract");
        require(salt < maxSupply, "Max Supply Reached");
        require(msg.value == (saltValue),"Wrong price");
        require(verifyAddressSigner(messageHash, signature), "Signature validation has failed");
        require(!usedHashes[messageHash], "Hash has already been used");
        usedHashes[messageHash] = true;

        _safeMint(msg.sender, 1);
        generateSaltHash(salt);
        emit Mint(msg.sender, salt);
    }
    

    function generateSaltHash(uint256 salt) internal {
        bytes32 tokenHash = keccak256(abi.encodePacked(block.number, block.timestamp, msg.sender));
        saltHashes[salt]=tokenHash;
    }

    function setScript(string memory _script) public onlyOwner {
        script = _script;
    }

    function setScriptType(string memory _scriptType) public onlyOwner {
        script = _scriptType;
    }

    function setSaltValue(uint256 _newPrice) external onlyOwner() {
      saltValue = _newPrice;
    }

    function verifyAddressSigner(bytes32 messageHash, bytes memory signature) private view returns (bool) {
        return signerAddress == messageHash.toEthSignedMessageHash().recover(signature);
    }

    function setSignerAddress(address _signerAddress) external onlyOwner {
        require(_signerAddress != address(0));
        signerAddress = _signerAddress;
    }
}