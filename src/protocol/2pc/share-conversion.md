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
with input $a \in \mathcal{F}, \, r \leftarrow \{0, 1\}^b$

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
means that we want an honest receiver to be able to detect a malicious sender,
who is then able to abort the protocol.

#### Malicious receiver
Note that in our protocol it is not possible to have a malicious receiver, since
he does not contribute any input. Even when this protocol is embedded into an
outer protocol, where at some point the receiver opens a forged output $y'$ or some
computation involving it, this would be equivalent to change his input from $b
\rightarrow b'$.

#### Malicious sender
In the case of a malicious sender the following things can happen:

1. The sender can impose an arbitrary field element $b'$ as input onto the
   receiver without him noticing. To do this he simply sends $(t_i^k, t_i^k)$ in
   every OT, where $k$ is i-th bit of $b'$.
2. For each OT round $i$, the sender can alter one of the OT values to be $T_i^k
   = t_i^k + c_i$, where $c_i \in \mathcal{F}, \, k \in \{0, 1\}$. This will cause
   that in the end the equation $a \cdot b = x + y$ no longer holds but only if
   the forged OT value has actually been picked by the receiver.
3. The sender does not use a random number generator with a seed $r$ to sample
   the masks $s_i$, instead he simply chooses them at will.

### Replay protocol
In order to mitigate these issues we will introduce a replay protocol. The idea
is that at some point after the M2A protocol, the sender has to reveal the rng seed
$r$ and his input $a$ to the receiver. The receiver can then check if the value
he picked during protocol execution does match what he can now reconstruct from
$r$ and $a$.

In practice the sender uses the same rng seed $r$ once to seed his rng and then
he uses it to produce masks for several protocol executions $l$, $a_l \cdot b_k =
x_k + y_k$. So the sender will write his seed $r$ and all the $a_l$ to some
tape, which in the end is sent to the receiver. As a security precaution we also
let the sender commit to his rng seed before protocol execution. In detail:

1. Sender has some inputs $a_l$ and picks some rng seed $r$.
2. Sender commits his rng seed to the receiver.
3. Sender sends all his OTs for $l$ protocol executions.
4. Sender sends tape which contains the rng seed $R$ and all the $A_l$.
5. Receiver checks that $r == R$.
6. For every protocol execution $l$ the receiver checks that $T_{l, k}^{b_{l,
   k}} == t_{l, k}^{b_{l, k}}$, where $t$ is what was sent in the OT and $T$ is
   reconstructed from $R$ and $A_l$.



