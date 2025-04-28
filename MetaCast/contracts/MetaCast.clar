;; MetaCast: AI-Based Decentralized Prediction Market System
;; A sophisticated smart contract system that enables decentralized prediction markets 
;; enhanced by AI-powered oracles, automated market making, and meta-prediction capabilities.

;; Constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_MARKET (err u101))
(define-constant ERR_MARKET_CLOSED (err u102))
(define-constant ERR_INSUFFICIENT_FUNDS (err u103))
(define-constant ERR_INVALID_BET (err u104))
(define-constant ERR_MARKET_ALREADY_SETTLED (err u105))
(define-constant ERR_MARKET_NOT_SETTLED (err u106))
(define-constant ERR_ALREADY_CLAIMED (err u107))
(define-constant ERR_NOTHING_TO_CLAIM (err u108))

;; Data Maps
(define-map markets
  { market-id: uint }
  {
    creator: principal,
    description: (string-utf8 256),
    resolution-source: (string-utf8 128),
    expiration: uint,
    resolution-time: uint,
    outcome: (optional bool),
    total-yes-amount: uint,
    total-no-amount: uint,
    fee-percentage: uint,
    ai-confidence-metric: uint, ;; 0-100 confidence from AI oracle
    is-closed: bool
  }
)

(define-map bets
  { market-id: uint, better: principal }
  {
    yes-amount: uint,
    no-amount: uint,
    claimed: bool
  }
)

;; FTs for liquidity pool
(define-fungible-token prediction-token)

;; Variables
(define-data-var market-nonce uint u0)
(define-data-var contract-owner principal tx-sender)
(define-data-var ai-oracle principal tx-sender)

;; Read-only functions
(define-read-only (get-market (market-id uint))
  (map-get? markets { market-id: market-id })
)

(define-read-only (get-bet (market-id uint) (better principal))
  (map-get? bets { market-id: market-id, better: better })
)

(define-read-only (get-market-count)
  (var-get market-nonce)
)

;; Authorization functions
(define-private (is-owner)
  (is-eq tx-sender (var-get contract-owner))
)

(define-private (is-ai-oracle)
  (is-eq tx-sender (var-get ai-oracle))
)

;; Public functions
(define-public (create-market (description (string-utf8 256)) (resolution-source (string-utf8 128)) (expiration uint) (fee-percentage uint))
  (let
    (
      (market-id (var-get market-nonce))
      (new-market {
        creator: tx-sender,
        description: description,
        resolution-source: resolution-source,
        expiration: expiration,
        resolution-time: u0,
        outcome: none,
        total-yes-amount: u0,
        total-no-amount: u0,
        fee-percentage: fee-percentage,
        ai-confidence-metric: u0,
        is-closed: false
      })
    )
    (map-set markets { market-id: market-id } new-market)
    (var-set market-nonce (+ market-id u1))
    (ok market-id)
  )
)

(define-public (place-bet (market-id uint) (is-yes bool) (amount uint))
  (let
    (
      (market (unwrap! (get-market market-id) ERR_INVALID_MARKET))
      (current-time (unwrap-panic (get-block-info? time u0)))
      (bet-map (default-to 
                { yes-amount: u0, no-amount: u0, claimed: false }
                (get-bet market-id tx-sender)))
    )
    (asserts! (not (get is-closed market)) ERR_MARKET_CLOSED)
    (asserts! (< current-time (get expiration market)) ERR_MARKET_CLOSED)
    (asserts! (>= (stx-get-balance tx-sender) amount) ERR_INSUFFICIENT_FUNDS)
    
    (if is-yes
      (map-set bets 
        { market-id: market-id, better: tx-sender }
        {
          yes-amount: (+ (get yes-amount bet-map) amount),
          no-amount: (get no-amount bet-map),
          claimed: false
        }
      )
      (map-set bets 
        { market-id: market-id, better: tx-sender }
        {
          yes-amount: (get yes-amount bet-map),
          no-amount: (+ (get no-amount bet-map) amount),
          claimed: false
        }
      )
    )
    
    (map-set markets { market-id: market-id }
      (merge market 
        {
          total-yes-amount: (if is-yes (+ (get total-yes-amount market) amount) (get total-yes-amount market)),
          total-no-amount: (if is-yes (get total-no-amount market) (+ (get total-no-amount market) amount))
        }
      )
    )
    
    (unwrap-panic (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (ok true)
  )
)

(define-public (set-ai-confidence-metric (market-id uint) (confidence-metric uint))
  (let
    (
      (market (unwrap! (get-market market-id) ERR_INVALID_MARKET))
    )
    (asserts! (is-ai-oracle) ERR_UNAUTHORIZED)
    (asserts! (<= confidence-metric u100) ERR_INVALID_BET)
    
    (map-set markets { market-id: market-id }
      (merge market { ai-confidence-metric: confidence-metric })
    )
    (ok true)
  )
)

(define-public (resolve-market (market-id uint) (outcome bool))
  (let
    (
      (market (unwrap! (get-market market-id) ERR_INVALID_MARKET))
      (current-time (unwrap-panic (get-block-info? time u0)))
    )
    (asserts! (or (is-owner) (is-eq tx-sender (get creator market))) ERR_UNAUTHORIZED)
    (asserts! (>= current-time (get expiration market)) ERR_MARKET_CLOSED)
    (asserts! (is-none (get outcome market)) ERR_MARKET_ALREADY_SETTLED)
    
    (map-set markets { market-id: market-id }
      (merge market {
        outcome: (some outcome),
        resolution-time: current-time,
        is-closed: true
      })
    )
    (ok true)
  )
)

(define-public (claim-winnings (market-id uint))
  (let
    (
      (market (unwrap! (get-market market-id) ERR_INVALID_MARKET))
      (bet (unwrap! (get-bet market-id tx-sender) ERR_NOTHING_TO_CLAIM))
      (outcome (unwrap! (get outcome market) ERR_MARKET_NOT_SETTLED))
      (yes-total (get total-yes-amount market))
      (no-total (get total-no-amount market))
      (total-pool (+ yes-total no-total))
      (fee-amount (/ (* total-pool (get fee-percentage market)) u10000))
      (reward-pool (- total-pool fee-amount))
      (winning-amount (if outcome (get yes-amount bet) (get no-amount bet)))
      (total-winning-amount (if outcome yes-total no-total))
      (winnings (if (is-eq total-winning-amount u0) 
                   u0 
                   (/ (* winning-amount reward-pool) total-winning-amount)))
    )
    (asserts! (not (get claimed bet)) ERR_ALREADY_CLAIMED)
    (asserts! (> winnings u0) ERR_NOTHING_TO_CLAIM)
    
    (map-set bets 
      { market-id: market-id, better: tx-sender }
      (merge bet { claimed: true })
    )
    
    (unwrap-panic (as-contract (stx-transfer? winnings tx-sender tx-sender)))
    (ok winnings)
  )
)

;; Advanced AI-Powered Automated Market Making function
(define-public (ai-powered-automated-market-making (market-id uint) (liquidity-amount uint))
  (let
    (
      (market (unwrap! (get-market market-id) ERR_INVALID_MARKET))
      (current-time (unwrap-panic (get-block-info? time u0)))
      (ai-confidence (get ai-confidence-metric market))
      (yes-allocation (* liquidity-amount (/ ai-confidence u100)))
      (no-allocation (- liquidity-amount yes-allocation))
      (contract-principal (as-contract tx-sender))
    )
    ;; Verify authorization and conditions
    (asserts! (is-ai-oracle) ERR_UNAUTHORIZED)
    (asserts! (not (get is-closed market)) ERR_MARKET_CLOSED)
    (asserts! (< current-time (get expiration market)) ERR_MARKET_CLOSED)
    (asserts! (>= (stx-get-balance tx-sender) liquidity-amount) ERR_INSUFFICIENT_FUNDS)
    
    ;; Transfer funds to contract
    (unwrap-panic (stx-transfer? liquidity-amount tx-sender contract-principal))
    
    ;; Update market stats based on AI confidence
    (map-set markets { market-id: market-id }
      (merge market {
        total-yes-amount: (+ (get total-yes-amount market) yes-allocation),
        total-no-amount: (+ (get total-no-amount market) no-allocation)
      })
    )
    
    ;; Mint prediction tokens to represent the liquidity provision
    (unwrap-panic (ft-mint? prediction-token liquidity-amount tx-sender))
    
    ;; Record the automated market making action
    (let 
      ((bet-map (default-to 
                { yes-amount: u0, no-amount: u0, claimed: false }
                (get-bet market-id contract-principal))))
      (map-set bets 
        { market-id: market-id, better: contract-principal }
        {
          yes-amount: (+ (get yes-amount bet-map) yes-allocation),
          no-amount: (+ (get no-amount bet-map) no-allocation),
          claimed: false
        }
      )
    )
    
    ;; Return the allocation details
    (ok {
      market-id: market-id,
      ai-confidence: ai-confidence,
      yes-allocation: yes-allocation,
      no-allocation: no-allocation,
      tokens-minted: liquidity-amount
    })
  )
)

;; Define new data maps and variables for meta-prediction feature
(define-map meta-predictions
  { parent-market-id: uint, meta-market-id: uint }
  {
    creator: principal,
    description: (string-utf8 256),
    expiration: uint,
    confidence-threshold: uint,
    trigger-executed: bool
  }
)

(define-data-var meta-prediction-nonce uint u0)

