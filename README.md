# Cross-chain rebase token

1. Create a protocol that allows users to deposit into a vault and in return, receive rebase tokens that represents their underlying balance
2. Creating a rebase token -> balanceOf function is dynamic to show the changing balance with time.
   1. Balance increases linearly with time (rewards early depositers)
   2. Mint tokens to our users every time they perform an action (minting, burning, transferring, or...bridging)
      1. Does this mean users get a % of fees essentially? NO
      2. Means their "rebase" gets updated
3. Interest rate
   1. Individually set an interest rate for each user based on some global interest rate of the protocol at the time the user deposits into the vault
   2. This global interest rate can only decrease to incentivize/reward early adopters
   3. Increase token adoption# ccip-rebase-token-f25-2
