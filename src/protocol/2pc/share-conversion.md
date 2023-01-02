# Maliciously Secure Share Conversion

Some protocols used in TLSNotary need to convert two-party sharings of products
or sums of some field elements into each other. For this purpose we use share
conversion protocols which use oblivious transfer (OT) as a sub-protocol. Here
we want to have a closer look at the security guarantees these protocols offer.

Without loss of generality from now on we have a closer look at the
Multiplication-To-Addition (M2A) protocol, but our observations also apply to
the Addition-To-Multiplication (A2M) protocol, which is very similar.


### M2A Protocol Overview
Let there be a sender with some field element $a$ and some receiver with another
field element $b$. After protocol execution the sender ends up with $x$ and the
receiver ends up with $y$, so that $a \cdot b = x + y$.
- $a,b,x,y \in \mathcal{F}$
- $r$ - rng seed
- $b$ - bit-length of rng seed
- $l$ - bitsize of elements in $\mathcal{F}$


#### OT Sender
with input $a \in \mathcal{F}, \, r \overset{\$}{\leftarrow} \{0, 1\}^b$

1. Sample some random masks: $s_i = rng(r, i), \, 0 \le i < l, \, s_i \in
   \mathcal{F} $
2. For every $s_i$ compute:
    - $t_i^0 = s_i$
    - $t_i^1 = a \cdot 2^i + s_i$
3. Compute new share: $x = \sum s_i$
3. Send $i$ OTs to receiver: $(t_i^0, t_i^1)$


#### OT Receiver
with input $b \in \mathcal{F}$

1. Set $v_i = t_i^{b_i}$
2. Compute new share: $y = \sum v_i$


### Replay protocol

In order to detect a malicious sender we leverage that at some later point the
sender is allowed to reveal all his secrets. This allows us to use a replay protocol
to detect a malicious sender:

1. Sender records $r$ and all $a_k$ on some tape.
2. Receiver records $b_k$ and $y_k$.
2. Sender sends the tape to receiver.
3. Receiver locally reconstructs the OT and checks he gets the same output $y_k
   == y'_k$


### Questions

1. Do we need a cointoss to construct an unbiased RNG?
2. During replay, do we need to check the OT envelopes, i.e. does the receiver
   need to record what the sender sent, and check it in the replay?
3. To what extent does an OT allow a malicious sender:
    - to leak something from the receiver if it is part of a bigger protocol?
    - to influence the receiver's decision
