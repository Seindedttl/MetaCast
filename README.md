MetaCast: AI-Based Decentralized Prediction Market System
=========================================================

A sophisticated smart contract system that enables decentralized prediction markets enhanced by AI-powered oracles, automated market making, and meta-prediction capabilities.

Overview
--------

This prediction market protocol leverages blockchain technology and artificial intelligence to create a transparent, trustless environment for users to create markets, place bets on future outcomes, and earn rewards based on accurate predictions. The system incorporates AI confidence metrics to improve market efficiency and includes advanced features like automated market making and nested meta-predictions.

Features
--------

-   **Decentralized Market Creation**: Anyone can create a prediction market on any verifiable future event
-   **AI-Enhanced Predictions**: Proprietary AI oracle integration provides confidence metrics on market outcomes
-   **Automated Market Making**: AI-powered liquidity provision based on confidence metrics
-   **Meta-Prediction Markets**: Nested markets that trigger automatically based on AI confidence thresholds
-   **Transparent Fee Structure**: Customizable fee percentage for each market
-   **Fungible Token Integration**: Liquidity providers receive prediction tokens to represent their stake
-   **Secure Fund Management**: All funds are held in the contract until market resolution
-   **Fair Rewards Distribution**: Winnings calculated proportionally to stake in the winning outcome

Technical Architecture
----------------------

### Core Components

1.  **Market System**: Enables creation and management of prediction markets
2.  **Betting Mechanism**: Allows users to place bets on binary outcomes (Yes/No)
3.  **AI Oracle Integration**: Provides confidence metrics on market outcomes
4.  **Automated Market Maker**: Distributes liquidity based on AI confidence
5.  **Meta-Prediction Framework**: Creates linked prediction markets with conditional triggers
6.  **Claims Processing**: Handles winner determination and reward distribution

### Smart Contract Functions

#### Market Management

-   `create-market`: Create a new prediction market
-   `get-market`: Retrieve market details
-   `get-market-count`: Get total number of markets created
-   `resolve-market`: Finalize a market with the actual outcome

#### Betting System

-   `place-bet`: Place a bet on a specific outcome (Yes/No)
-   `get-bet`: Retrieve bet details for a specific user
-   `claim-winnings`: Claim rewards after market resolution

#### AI Integration

-   `set-ai-confidence-metric`: Set AI confidence level for a market outcome
-   `ai-powered-automated-market-making`: Provide liquidity based on AI confidence

#### Meta-Prediction System

-   `create-meta-prediction-market`: Create a market that triggers based on AI confidence in another market

Usage Guide
-----------

### Creating a Prediction Market

```
(contract-call? .prediction-market create-market
  "Will ETH price exceed $10,000 by Dec 31, 2025?"
  "CoinMarketCap API"
  u1735689600
  u300)

```

This creates a market with a 3% fee that resolves after December 31, 2025.

### Placing a Bet

```
;; Betting 500 STX on "Yes"
(contract-call? .prediction-market place-bet u1 true u500000000)

;; Betting 300 STX on "No"
(contract-call? .prediction-market place-bet u1 false u300000000)

```

### Using AI-Powered Market Making

```
;; Adding 1000 STX liquidity with AI allocation
(contract-call? .prediction-market ai-powered-automated-market-making u1 u1000000000)

```

### Creating Meta-Prediction Markets

```
(contract-call? .prediction-market create-meta-prediction-market
  u1
  "Will BTC price exceed $100,000 if ETH reaches $10,000?"
  "CoinMarketCap API"
  u1735689600
  u300
  u75
  "Meta-prediction on correlated crypto assets"
  u1751328000)

```

This creates a nested market that is conditionally triggered when the AI confidence for the parent market reaches 75%.

### Claiming Winnings

```
(contract-call? .prediction-market claim-winnings u1)

```

Installation and Deployment
---------------------------

### Prerequisites

-   [Clarinet](https://github.com/hirosystems/clarinet) for local development and testing
-   [Stacks Wallet](https://www.hiro.so/wallet) for deployment and interaction
-   Basic knowledge of Clarity programming language

### Deployment Steps

1.  Clone this repository
2.  Install dependencies:

    ```
    npm install

    ```

3.  Run local tests:

    ```
    clarinet test

    ```

4.  Deploy to testnet:

    ```
    clarinet deploy --testnet

    ```

5.  Deploy to mainnet (when ready):

    ```
    clarinet deploy --mainnet

    ```

Design Decisions
----------------

### Binary Outcomes

The current implementation focuses on binary (Yes/No) outcomes for simplicity and reliability. This design choice allows for straightforward market resolution and reward distribution.

### Time-Based Resolution

Markets have explicit expiration timestamps after which they can be resolved. This prevents premature resolution and ensures all participants have equal opportunity to place bets.

### Fee Structure

Each market has a configurable fee percentage (in basis points) that is deducted from the total pool before distributing rewards. This creates a sustainable economic model for the platform.

### AI Confidence Metrics

The AI oracle provides confidence metrics on a scale of 0-100, which are used for:

1.  Informing users about likely outcomes
2.  Guiding automated market making
3.  Triggering meta-prediction markets

Security Considerations
-----------------------

-   **Access Controls**: Critical functions are protected by owner/oracle verification
-   **Validation Checks**: All inputs are validated before execution
-   **Fund Security**: STX tokens remain locked in the contract until legitimate claims
-   **Error Handling**: Comprehensive error codes for failure states
-   **Temporal Safety**: Time-based checks prevent premature market resolution

Future Enhancements
-------------------

-   **Multi-outcome Markets**: Support for markets with more than two possible outcomes
-   **Oracle Decentralization**: Multiple AI oracles with weighted influence
-   **Dynamic Fee Adjustment**: Algorithmic fee adjustment based on market activity
-   **Advanced Meta-Predictions**: Multiple trigger conditions and complex logic
-   **Cross-Chain Integration**: Interoperability with other blockchain prediction markets

Contributing
------------

We welcome contributions to improve the AI-Based Decentralized Prediction Market! Here's how you can help:

1.  **Fork the repository**
2.  **Create a feature branch**:

    ```
    git checkout -b feature/amazing-feature

    ```

3.  **Commit your changes**:

    ```
    git commit -m 'Add some amazing feature'

    ```

4.  **Push to the branch**:

    ```
    git push origin feature/amazing-feature

    ```

5.  **Open a Pull Request**

Please ensure your code adheres to our style guidelines and includes appropriate tests.

### Development Guidelines

-   Write clear, commented code
-   Include comprehensive tests for new features
-   Update documentation to reflect changes
-   Follow Clarity best practices for security and efficiency

License
-------

This project is licensed under the MIT License - see below for details:

```
MIT License

Copyright (c) 2025 AI-Based Decentralized Prediction Market

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```

Contact
-------

For questions, suggestions, or collaborations, please open an issue in the repository.
* * * * *

*This document describes the smart contract as of April 2025. Features and implementations may evolve as the project develops.*
