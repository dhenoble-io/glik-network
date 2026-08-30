# Deployment Notes – GLIK NFT

## Constructor Arguments
1. `initialOwner` = 0xDf051B410773d7510B58031dEf47fbc2922858C3
2. `baseURI_` = "ipfs://YOUR_CID/"   (or temporary "https://...")
3. `initialEthFee` = 410000000000000   (0.00041 ether in wei)

## After Deployment
1. Verify contract on Etherscan
2. Call `setBaseURI` once metadata is ready
3. Test with a small amount on a fork or mainnet carefully

## Frontend Integration Flow
1. User connects wallet
2. Check `hasMinted(user)` and `remainingPublic()`
3. If not minted:
   - Call USDT.approve(nftContract, 4e6)
   - Wait for confirmation
   - Call nft.mint{value: ethFee}()
4. Show success + tokenId

## Whitelist Checker
Simply call `balanceOf(wallet) > 0` or the helper `isWhitelisted(wallet)`
