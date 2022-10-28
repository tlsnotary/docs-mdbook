# Key Exchange

In TLS, the first step towards obtaining TLS session keys is to compute a shared secret between the client and the server by running the [ECDH protocol](https://en.wikipedia.org/wiki/Elliptic-curve_Diffie–Hellman). The resulting shared secret in TLS terms is called the pre-master secret `PMS`.

<img src="https://raw.githubusercontent.com/tlsnotary/docs-assets/main/diagrams/key_exchange.png" width="800">

Using the notation from Wikipedia, below is the 3-party ECDH protocol between the `Server` the `Requester` and the `Notary`, enabling the `Requester` and the `Notary` to arrive at shares of `PMS`.


1. `Server` sends its public key \\(\small{Q_b}\\) to `Requester`, and `Requester` forwards it to `Notary`
2. `Requester` picks a random private key share \\( \small{d_c} \\) and computes a public key share \\( \small{Q_c = d_c * G} \\)
3. `Notary` picks a random private key share \\( \small{d_n} \\) and computes a public key share \\( \small{Q_n = d_n * G} \\)
4. `Notary` sends \\( \small{Q_n} \\) to `Requester` who computes \\( \small{Q_a = Q_c + Q_n} \\) and sends \\( \small{Q_a} \\) to `Server`
5. `Requester` computes an EC point \\( \small{(x_p, y_p) = d_c * Q_b} \\)
6. `Notary` computes an EC point \\( \small{(x_q, y_q) = d_n * Q_b} \\)
7. Addition of points \\( \small{(x_p, y_p)} \\) and \\( \small{(x_q, y_q)} \\) results in the coordinate \\( \small{x_r} \\), which is `PMS`. (The coordinate \\( \small{y_r} \\) is not used in TLS)


Using the notation from [here](https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication#Point_addition), our goal is to compute
\\[ x_r = (\frac{y_q-y_p}{x_q-x_p})^2 - x_p - x_q \\]
in such a way that
1. Neither party learns the other party's \\( \small{x} \\) value
2. Neither party learns \\( \small{x_r} \\), only their respective shares of \\( \small{x_r} \\).

We will use two maliciously secure protocols described on p.25 in the paper [Eﬃcient Secure Two-Party Exponentiation](https://www.cs.umd.edu/~fenghao/paper/modexp.pdf):

- `A2M` protocol, which converts additive shares into multiplicative shares, i.e. given shares `a` and `b` such that `a + b = c`, it converts them into shares `d` and `e` such that `d * e = c`    
- `M2A` protocol, which converts multiplicative shares into additive shares

We apply `A2M` to \\(y_q + (-y_p)\\) to get \\(A_q * A_p\\) and also we apply `A2M` to \\(x_q + (-x_p)\\) to get \\(B_q * B_p\\). Then the above can be rewritten as:

\\[x_r = (\frac{A_q}{B_q})^2 * (\frac{A_p}{B_p})^2 - x_p - x_q \\]

Then the first party locally computes the first factor and gets \\(C_q\\), the second party locally computes the second factor and gets \\(C_p\\). Then we can again rewrite as:

\\[x_r = C_q * C_p - x_p - x_q \\]

Now we apply `M2A` to \\(C_q * C_p\\) to get \\(D_q + D_p\\), which leads us to two final terms each of which is the share of \\(x_r\\) of the respective party: 

\\[x_r = (D_q - x_q) + (D_p - x_p)\\]