// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ERC20 to ERC721 converter
 * @author Ilya Dudnikov
 */
contract Converter is ERC721 {
    /// @dev Maps tokenID to the amount of ERC20 tokens deposited
    mapping (uint256 => uint256) private tokensDeposited;

    /// @dev Maps tokenID to the ERC20 interface that was used to deposit
    mapping (uint256 => IERC20) private depositToken;

    uint256 private lastTokenId;

    /// @dev Array of supported ERC20 tokens
    // IERC20[] supportedTokens;

    /// @dev Marks the supported tokens with non-zero values. 
    /// It is only needed to quickly check if the token is supported.
    // mapping (IERC20 => uint256) isSupportedToken;

    // event TokenAdd(IERC20 token);
    event Convertation(uint amount);
    event Redemption(uint tokenId);

    constructor() ERC721("ERC20 to ERC721 converter", "token2nft") {
        // supportedTokens = tokenList;
        lastTokenId = 1;
    }

    /**
     * @notice Adds given ERC20 token to the list of supported tokens
     * @param token ERC20 token that is going to be added
     */
    // function addToken(IERC20 token) {
    //     require(!isSupportedToken[token]);
    //     supportedTokens.push(token);
    //     isSupportedToken[token] = supportedTokens.length;

    //     emit TokenAdd(token);
    // }

    /** 
     * @notice Converts `amount` of ERC20 tokens into a redeemable ERC721
     * @param amount number of ERC20 tokens to be converted
     * @param token ERC20 token that is used to deposit
     */
    function convert(uint amount, IERC20 token) public {
        tokensDeposited[lastTokenId + 1] = amount;
        _mint(msg.sender, lastTokenId + 1);
        lastTokenId++;
        token.approve(address(this), amount);
        token.transferFrom(msg.sender, address(this), amount);

        emit Convertation(amount);
    }

    /**
     * @notice Converts ERC721 token back to ERC20
     * @param tokenId ERC721 token that is being redeemed
     */
    function redeem(uint256 tokenId) public {
        require(tokensDeposited[tokenId] > 0);

        this.approve(address(this), tokenId);
        this.transferFrom(msg.sender, address(this), tokenId);
        tokensDeposited[tokenId] = 0;
        depositToken[tokenId].transferFrom(address(this), msg.sender, tokensDeposited[tokenId]);
        
        emit Redemption(tokenId);
    }
}