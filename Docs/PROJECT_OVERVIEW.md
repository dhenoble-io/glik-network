# GLIK NETWORK – Full Project Overview

## Phase 1: NFT System (Priority – Building Now)

### Smart Contract (`contracts/GLIK.sol`)
- ERC-721 (GLIK / GLK)
- Max Supply: 7500
- Public Mint: 7000 (strictly 1 per wallet)
- Reserved: 500 (only owner wallet can mint)
- Price: 4 USDT (pulled via `transferFrom`) + fixed ETH fee (default 0.00041 ETH ≈ $1)
- Both payments go directly to: `0xDf051B410773d7510B58031dEf47fbc2922858C3`
- Pause / Unpause
- Changeable ETH fee from admin
- `isWhitelisted(address)` helper
- Emergency withdraw functions

### Frontend Pages
1. **Mint Page** – Shows only “Mint for 4 USDT”. Silently includes the ETH fee in the transaction.
2. **Whitelist Checker** – Any wallet can check if it holds a GLIK NFT.
3. **Upcoming Testnet Page** – Coming soon notice + whitelist status.
4. **Admin Panel** – Pause, change fee, mint reserved, view stats, list minters.

### NFT Artwork
Golden shiny coin with the text **“GLIK OG”**.

---

## Phase 2: Mining / Airdrop App (After NFT is live)

### Features
- Email + Password registration
- Connect EVM wallet (linked to account)
- Mining / daily activities / points
- Referral system
- Progress stored in database
- Periodic or final Merkle root published on-chain
- Claim portal later (wallet-based)

### Tech Stack
- Frontend: Next.js + wagmi + Tailwind
- Backend: Node.js / Express or FastAPI
- Database: PostgreSQL
- Auth: Email/password + JWT
- On-chain: Merkle claim contract (later)

---

## Current Status
- [x] Smart Contract written
- [ ] NFT Image generated
- [ ] Frontend scaffold
- [ ] Deployment scripts
- [ ] Mining app foundation
EOF