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
- $m$ - bitsize of elements in $\mathcal{F}$
- $n$ - bit-length of rng seed

#### OT Sender
with input $a \in \mathcal{F}, \, r \leftarrow \{0, 1\}^n$

1. Sample some random masks: $s_i = rng(r, i), \, 0 \le i < m, \, s_i \in
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

### Adding covert security
Our goal is to add covert security to our share conversion protocols. This
means that we want an honest receiver to be able to detect a malicious sender,
who is then able to abort the protocol.

#### Malicious receiver
Note that in our protocol it is not possible to have a malicious receiver, since
he does not contribute any input. Even when this protocol is embedded into an
outer protocol, where at some point the receiver opens a forged output $y'$ or some
computation involving it, this would be equivalent to changing his input from $b
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
is that at some point after the conversion protocol, the sender has to reveal the rng
seed $r$ and his input $a$ to the receiver. In order to do this, he will send
$R$ and $A$ to the receiver after the conversion protocol has been executed. If
the sender is honest then of course $r == R$ and $a == A$. The receiver can then
check if the value he picked during protocol execution does match what he can
now reconstruct from $R$ and $A$, i.e. that $T_i^{b_i} == t_i^{b_i}$.

**Using this replay protocol the sender at some point leaks all his secrets
because he sends his rng seed and protocol input to the receiver. This means
that we can only use covertly secure share conversion with replay as a
sub-protocol if it is acceptable for the outer protocol, that the input to
share-conversion becomes public at some later point.**

Now in practice we often want to execute several rounds of share-conversion, as we
need to convert several field elements. Because of this we let the sender use
the same rng seed $r$ to seed his rng once and then he uses this rng instance
for all protocol rounds. This means we have $l$ protocol executions $a_l \cdot
b_l = x_l + y_l$, and all masks $s_{l, i}$ produced from this rng seed $r$.
So the sender will write his seed $R$ and all the $A_l$ to some tape, which in
the end is sent to the receiver. As a security precaution we also let the sender
commit to his rng seed before the first protocol execution. In detail:

##### Sender
1. Sender has some inputs $a_l$ and picks some rng seed $r$.
2. Sender commits to his rng seed and sends the commitment to the receiver.
3. Sender sends all his OTs for $l$ protocol executions.
4. Sender sends tape which contains the rng seed $R$ and all the $A_l$.

##### Receiver
1. Receiver checks that $R$ is indeed the committed rng seed.
2. For every protocol execution $l$ the receiver checks that $T_{l, i}^{b_{l,
   i}} == t_{l, i}^{b_{l, i}}$.

Having a look at the ways a malicious sender could cheat from earlier, we
notice:
1. The sender can no longer impose an arbitrary field element $b'$ onto the
   receiver, because he would notice that $t \neq T$ during the replay.
2. The sender can still do this, but this is equivalent to guessing $k$ bits of
   $b$ at random with a probability of $2^{-k}$.
3. The sender is now forced to use an rng seed to produce the masks, because
   during the replay, these masks are reproduced from $R$ and indirectly checked
   via $t == T$.

