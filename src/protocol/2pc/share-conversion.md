# Share Conversion Analysis

Some protocols used in TLSNotary need to convert two-party sharings of products
or sums of some field elements into each other. For this purpose we use share
conversion protocols which use oblivious transfer (OT) as a sub-protocol. Here
we want to have a closer look at the security guarantees these protocols offer.

Without loss of generality from now on we have a closer look at the
Multiplication-To-Addition (M2A) protocol, but our observations also apply to
the Addition-To-Multiplication (A2M) protocol, which is very similar. We start
with a short review of the M2A protocol.


### M2A Protocol Review
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

1. Set $v_i = t_i^{b_i}$ (from OT)
2. Compute new share: $y = \sum v_i$


### Adding malicious security

Our goal is to add malicious security to our share conversion protocols. This
means that we want an honest receiver to be able to detect a malicious sender.

Note that in our protocol it is not possible to have a malicious receiver, since
he does not contribute any input. Even when this protocol is embedded into an
outer protocol, where at some point the receiver opens his output $y$ or some
computation involving it, this is equivalent to changing his input $b$.

In the case of a malicious sender the following two things can happen:

1. The sender can impose an arbitrary field element $b'$ as input onto the
   receiver without him noticing. To do this he simply sends $(t_i^k, t_i^k)$ in
   every OT, where $k$ is k-th bit of $b'$.
2. If combined with an outer protocol, where the receiver reveals some
   computation involving his output, it is possible for the sender to make the
   receiver leak some additional information depending on the outer protocol,
   just exploiting that he can impose arbitrary input onto the receiver.

   As a simple example, imagine the case, where after carrying out the M2A
   protocol both parties want to use their shares in some protocol which for
   some reason makes both parties reveal if their output shares are even or odd.
   In this case the OT sender could have forged $l - 1$ OTs, only using a single
   honest OT, which would allow him to leak that bit of the receiver's input share
   $b$. It depends entirely on the outer protocol what can be leaked and if the
   malicious behavior will be detected.


### Questions

1. Do we need a cointoss to construct an unbiased RNG?
    - I do not think so. What advantage would he get from this? Even in the most
      extreme case, where he can arbitrarily choose all $s_i$, it is not clear
      to me how this can be used against the receiver. Furthermore, we assume
      the OT sender to be computationally bounded. It would take him exponential
      time to forge an rng seed. 
2. During replay, do we need to check the OT envelopes, i.e. does the receiver
   need to record what the sender sent, and check it in the replay?
3. Is it sufficient for the sender to just commit to the rng seed and input?
4. Is there a good solution to prevent malicious behavior if we cannot reveal?
    - Some MPC protocols use ZK-proofs to ensure malicious security. I think
      this is probably too complicated for our use case.

### Current solution

In our current implementation, to detect a malicious sender we leverage that at
some later point the sender is allowed to reveal all his secrets. This allows us
to use a replay protocol to detect a malicious sender:

1. Sender records $r$ and all $a_k$ on some tape.
2. Receiver records $b_k$ and $y_k$.
3. Sender sends the tape to receiver.
4. Receiver locally reconstructs the OT and checks he gets the same outputs: $y_k
   == y'_k$

### Improved solution
