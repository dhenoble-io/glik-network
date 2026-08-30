// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title GLIK NFT - GLIK NETWORK
 * @notice Max supply 7500. Public mint 7000 (1 per wallet). 500 reserved for owner.
 * @dev Mint costs 4 USDT (pulled by contract) + fixed ETH fee (sent to owner).
 *      Both payments go directly to the owner wallet.
 */
contract GLIK is ERC721, ERC721Enumerable, Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ============ Constants ============
    uint256 public constant MAX_SUPPLY = 7500;
    uint256 public constant PUBLIC_SUPPLY = 7000;
    uint256 public constant RESERVED_SUPPLY = 500;
    uint256 public constant USDT_PRICE = 4 * 10**6; // 4 USDT (6 decimals)

    // USDT on Ethereum Mainnet
    IERC20 public constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    // ============ State ============
    string private _baseTokenURI;
    uint256 public ethFee;                    // Fixed ETH fee (changeable by owner)
    uint256 public publicMinted;
    uint256 public reservedMinted;

    mapping(address => bool) public hasMinted; // 1 NFT per wallet for public mint

    // ============ Events ============
    event Minted(address indexed to, uint256 indexed tokenId, uint256 usdtPaid, uint256 ethPaid);
    event EthFeeUpdated(uint256 oldFee, uint256 newFee);
    event BaseURIUpdated(string newURI);
    event ReservedMinted(address indexed to, uint256 quantity);

    // ============ Constructor ============
    constructor(
        address initialOwner,
        string memory baseURI_,
        uint256 initialEthFee
    ) ERC721("GLIK", "GLK") Ownable(initialOwner) {
        _baseTokenURI = baseURI_;
        ethFee = initialEthFee; // e.g. 0.00041 ether
    }

    // ============ Public Mint ============
    /**
     * @notice Mint 1 GLIK NFT.
     * @dev User must have approved this contract for at least 4 USDT beforehand.
     *      msg.value must be >= ethFee. Extra ETH is refunded.
     */
    function mint() external payable whenNotPaused nonReentrant {
        require(publicMinted < PUBLIC_SUPPLY, "Public supply sold out");
        require(!hasMinted[msg.sender], "Already minted");
        require(msg.value >= ethFee, "Insufficient ETH fee");

        // Pull 4 USDT from minter → owner
        USDT.safeTransferFrom(msg.sender, owner(), USDT_PRICE);

        // Send ETH fee to owner
        (bool success, ) = owner().call{value: ethFee}("");
        require(success, "ETH transfer failed");

        // Refund excess ETH if any
        if (msg.value > ethFee) {
            (bool refundSuccess, ) = msg.sender.call{value: msg.value - ethFee}("");
            require(refundSuccess, "Refund failed");
        }

        hasMinted[msg.sender] = true;
        publicMinted++;

        uint256 tokenId = totalSupply() + 1; // 1-based token IDs
        _safeMint(msg.sender, tokenId);

        emit Minted(msg.sender, tokenId, USDT_PRICE, ethFee);
    }

    // ============ Owner / Admin Functions ============

    /**
     * @notice Mint remaining reserved NFTs (up to 500) to any address.
     */
    function mintReserved(address to, uint256 quantity) external onlyOwner {
        require(to != address(0), "Invalid address");
        require(reservedMinted + quantity <= RESERVED_SUPPLY, "Exceeds reserved supply");
        require(totalSupply() + quantity <= MAX_SUPPLY, "Exceeds max supply");

        for (uint256 i = 0; i < quantity; i++) {
            reservedMinted++;
            uint256 tokenId = totalSupply() + 1;
            _safeMint(to, tokenId);
        }

        emit ReservedMinted(to, quantity);
    }

    function setEthFee(uint256 newFee) external onlyOwner {
        emit EthFeeUpdated(ethFee, newFee);
        ethFee = newFee;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
        emit BaseURIUpdated(newBaseURI);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Emergency withdraw any ETH accidentally left in the contract.
     */
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH");
        (bool success, ) = owner().call{value: balance}("");
        require(success, "Withdraw failed");
    }

    /**
     * @notice Emergency withdraw any ERC20 tokens (including USDT) stuck in the contract.
     */
    function withdrawERC20(address token) external onlyOwner {
        IERC20 t = IERC20(token);
        uint256 balance = t.balanceOf(address(this));
        require(balance > 0, "No tokens");
        t.safeTransfer(owner(), balance);
    }

    // ============ View Helpers ============

    function remainingPublic() external view returns (uint256) {
        return PUBLIC_SUPPLY - publicMinted;
    }

    function remainingReserved() external view returns (uint256) {
        return RESERVED_SUPPLY - reservedMinted;
    }

    function isWhitelisted(address wallet) external view returns (bool) {
        return balanceOf(wallet) > 0;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return string(abi.encodePacked(_baseTokenURI, _toString(tokenId), ".json"));
    }

    // ============ Required Overrides ============

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Simple internal toString (avoids extra OpenZeppelin dependency)
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
