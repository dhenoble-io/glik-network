# GLIK NETWORK

Full stack project: NFT + Whitelist system + Mining / Airdrop app foundation.

## Project Structure

```
glik-network/
├── contracts/
│   ├── GLIK.sol              ← Main NFT contract (ready)
│   └── DeployNotes.md
├── frontend/                 ← Next.js (Mint, Checker, Testnet, Home)
│   ├── src/app/
│   │   ├── page.tsx          ← Landing
│   │   ├── mint/page.tsx
│   │   ├── checker/page.tsx
│   │   └── testnet/page.tsx
│   └── src/lib/contracts.ts
├── mining-backend/           ← Email/password + points + referrals
│   ├── index.js
│   └── prisma/schema.prisma
├── scripts/
│   └── deploy-args.js
└── docs/
    └── PROJECT_OVERVIEW.md
```

## 1. NFT System (Phase 1)

### Contract Features
- **Name**: GLIK | **Symbol**: GLK
- Max Supply: **7500**
- Public Mint: **7000** (1 per wallet)
- Reserved: **500** (only owner can mint)
- Price: **4 USDT** (pulled automatically) + fixed ETH fee (default 0.00041 ETH)
- Payments go to: `0xDf051B410773d7510B58031dEf47fbc2922858C3`
- Pause, change fee, emergency withdraw, whitelist helper

### Frontend Pages
- `/` – Landing
- `/mint` – Mint page (shows only “4 USDT”)
- `/checker` – Whitelist checker (any wallet)
- `/testnet` – Upcoming testnet notice + eligibility

## 2. Mining App Foundation (Phase 2)

### Backend Features
- Email + password registration / login
- Link EVM wallet
- Referral system (code + rewards)
- Mining (points + energy)
- Leaderboard
- Activity logs
- Ready for future Merkle root / claim contract

## Next Steps for You

1. **Deploy the NFT contract**
   - Use the constructor args in `scripts/deploy-args.js`
   - Owner: `0xDf051B410773d7510B58031dEf47fbc2922858C3`
   - initialEthFee: `410000000000000` (0.00041 ETH)

2. **Update frontend**
   - Replace `GLIK_ADDRESS` in `frontend/src/lib/contracts.ts` after deploy

3. **NFT Metadata**
   - Upload the golden “GLIK OG” image to IPFS
   - Create metadata JSON files
   - Call `setBaseURI` on the contract

4. **Mining Backend**
   - Set up PostgreSQL
   - Run `npx prisma migrate dev`
   - Add `.env` with `DATABASE_URL` and `JWT_SECRET`

5. **Admin Panel** (to be expanded)
   - Pause / change fee / mint reserved / view stats

## Important Notes

- The mint page intentionally shows only “4 USDT”. The ETH fee is included silently in the transaction (as requested).
- Users must approve USDT before minting.
- Test thoroughly on a fork or testnet before mainnet.
