# Roadmap for the Bora Student Protocal

This document outlines several major versions for the specifications and implementation of the Bora Student Protocal. The versions are aligned with the major strategic priorities of the project over time and expected hard-fork combinator events in Cardano that will make certain new approaches possible.

## 0.1 Minimal product (end to end onchain) And Staking functionality

**Estimated delivery: End of Q3 2022**

### Staking (vBORA)

This version is intended as a starting point for the incremental evolution of the product. The goal is to create a minimal implementation that can be tested end-to-end. This version will not include front-end or centralized back-end components, but it will include smart contracts for a staking system where holders of BORA can earn vBORA. As well as test suites that cover the essential properties of the staking system.

Smart Contracts will be written and tested in [Plutarch](https://github.com/Plutonomicon/plutarch)

## 0.2 Minimal viable product 

**Estimated delivery: End of Q4 2022**
**Subject to Cardano Transaction Library delays.**

### Loan Application (sBORA)

This version is intended to be a MVP where a small test batch of students can apply for loans, advise on proposals and earn sBORA. It will include 
smart contracts for recieving sBORA proportional to the individuals engagement level of the protocal as well as for locking sBORA uppon the application of a loan. It will also include test suites that cover the essential properties of the loan application system.

All offchain contracts will be written in purescript utilising the [Cardano Transaction Library](https://github.com/Plutonomicon/cardano-transaction-lib)

### Identity (sBORA)

KYCs will have to be completed but DIDs will not be onchain and all information will be held by the BORA team. sBORA will be air dropped manually  upon KYC completion

### Staking Upgrades (vBORA)

New features: The creation of a Stable Coin staking pool dependent on the ecosystem and wether or not a Cardano native stable coin is available.

### Funding

The Loans will be manually issued by the BORA team and decisions on who the loans will go to will be made in a Centralised manner.

## 1.0 Launch product 

**Estimated delivery: Q1/Q2 2023**

This Version Is intended to be a full end to end product that consists of a smart contract suite covering staking, voting and funding onchain. With test suites that cover all of the above. 
Audit process and auditor will be decided closer to the time.

### Staking Upgrades

### Voting (vBORA)

### Funding Uprades

## 2.0+ Post-launch upgrades / ideas

#### DISCLAIMER: This section is speculative. We haven't committed to any of these features, or even to having a v2.

**Estimated delivery: TBC**

