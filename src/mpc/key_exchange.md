# Key Exchange

In TLS, the first step towards obtaining TLS session keys is to compute a shared secret between the client and the server by running the [ECDH protocol](https://en.wikipedia.org/wiki/Elliptic-curve_Diffie–Hellman). The resulting shared secret in TLS terms is **called the pre-master secret `PMS`**.

With TLSNotary, at the end of the key exchange, the `Server` gets the `PMS` as usual. The `Prover` and the `Verifier`, jointly operating as the TLS client, compute additive shares of the `PMS`. This prevents either party from unilaterally sending or receiving messages with the `Server`. Subsequently, the authenticity and integrity of the messages are guaranteed to both the `Prover` and `Verifier`, while also keeping the plaintext hidden from the `Verifier`.

<img src="../../diagrams/key_exchange.svg" width="800">

The 3-party ECDH protocol between the `Server` the `Prover` and the `Verifier` works as follows:


1. `Server` sends its public key $Q_b$ to `Prover`, and `Prover` forwards it to `Verifier`
2. `Prover` picks a random private key share $d_c$ and computes a public key share $Q_c = d_c * G$
3. `Verifier` picks a random private key share $d_n$ and computes a public key share $Q_n = d_n * G$
4. `Verifier` sends $Q_n$ to `Prover` who computes $Q_a = Q_c + Q_n $ and sends $Q_a$ to `Server`
5. `Prover` computes an EC point $(x_p, y_p) = d_c * Q_b$
6. `Verifier` computes an EC point $(x_q, y_q) = d_n * Q_b$
7. Addition of points $(x_p, y_p)$ and $(x_q, y_q)$ results in the coordinate $x_r$, which is `PMS`. (The coordinate $y_r$ is not used in TLS)


Using the notation from [here](https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication#Point_addition), our goal is to compute
$$ x_r = (\frac{y_q-y_p}{x_q-x_p})^2 - x_p - x_q $$
in such a way that
1. Neither party learns the other party's $x$ value
2. Neither party learns $x_r$, only their respective shares of $x_r$.

We will use two maliciously secure protocols described on p.25 in the paper [Eﬃcient Secure Two-Party Exponentiation](https://www.cs.umd.edu/~fenghao/paper/modexp.pdf):

- `A2M` protocol, which converts additive shares into multiplicative shares, i.e. given shares `a` and `b` such that `a + b = c`, it converts them into shares `d` and `e` such that `d * e = c`    
- `M2A` protocol, which converts multiplicative shares into additive shares

We apply `A2M` to $y_q + (-y_p)$ to get $A_q * A_p$ and also we apply `A2M` to $x_q + (-x_p)$ to get $B_q * B_p$. Then the above can be rewritten as:

$$x_r = (\frac{A_q}{B_q})^2 * (\frac{A_p}{B_p})^2 - x_p - x_q $$

Then the first party locally computes the first factor and gets $C_q$, the second party locally computes the second factor and gets $C_p$. Then we can again rewrite as:

$$x_r = C_q * C_p - x_p - x_q $$

Now we apply `M2A` to $C_q * C_p$ to get $D_q + D_p$, which leads us to two final terms each of which is the share of $x_r$ of the respective party: 

$$x_r = (D_q - x_q) + (D_p - x_p)$$