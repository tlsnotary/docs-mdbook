# Computing MAC in 2PC

1. [What is a MAC](#section1)
2. [How a MAC is computed in AES-GCM](#section2)
3. [Computing MAC using secure two-party computation (2PC)](#section3) 


## 1. What is a MAC <a name="section1"></a>

When sending an encrypted ciphertext to the Webserver, the User attaches a
checksum to it. The Webserver uses this checksum to check whether the ciphertext
has been tampered with while in transit. This checksum is known as the
"authentication tag" and also as the "Message Authentication Code" (MAC).

In order to create a MAC for some ciphertext not only the ciphertext but also
some secret key is used as an input. This makes it impossible to forge some
ciphertext without knowing the secret key.

The first few paragraphs of [this article](https://zsecurity.org/bit-flipping-attacks-against-cipher-block-chaining-algorithms/)
explain what would happen if there was no MAC: it would be possible for a
malicious actor to modify the **plaintext** by flipping certain bits of the
**ciphertext**.


## 2. How a MAC is computed in AES-GCM <a name="section2"></a>

In TLS the plaintext is split up into chunks called "TLS records". Each TLS
record is encrypted and a MAC is computed for the ciphertext. The MAC (in
AES-GCM) is obtained by XORing together the `GHASH output` and the `GCTR
output`. Let's see how each of those outputs is computed:

#### 2.1 GCTR output 

The `GCTR output` is computed by simply AES-ECB encrypting a counter block with
the counter set to 1 (the iv, nonce and AES key are the same as for the rest of
the TLS record).  

#### 2.2 GHASH output

The `GHASH output` is the output of the GHASH function described in the
[NIST publication](https://nvlpubs.nist.gov/nistpubs/legacy/sp/nistspecialpublication800-38d.pdf)
in section 6.4 in this way: "In effect, the GHASH function calculates \\(
\small{ X_1•H^{m} ⊕ X_2•H^{m−1} ⊕ ... ⊕ X_{m−1}•H^{2} ⊕ X_m•H } \\)". \\(H\\)
and \\(X\\) are elements of the extension field \\(\mathrm{GF}(2^{128})\\).

* "•" is a special type of multiplication called `multiplication in a finite
field` described in section 6.3 of the NIST publication.
* ⊕ is `addition in a finite field` and it is defined as XOR.

In other words, GHASH splits up the ciphertext into 16-byte blocks, each block
is numbered \\( \small{ X_1, X_2, ... }\\) etc. There's also \\( \small{H} \\)
which is called the `GHASH key`, which just is the AES-encrypted zero-block. We
need to raise \\( \small{H} \\) to as many powers as there are blocks, i.e. if
we have 5 blocks then we need 5 powers: \\( \small{ H, H^2, H^3, H^4, H^5 } \\).
Each block is multiplied by the corresponding power and all products are summed
together.

Below is the pseudocode for multiplying two 128-bit field elements `x` and `y`
in \\(\mathrm{GF}(2^{128})\\):

```
1. result = 0
2. R = 0xE1000000000000000000000000000000
3. bit_length = 128
4. for i=0 upto bit_length-1
5.    if y[i] == 1
6.       result ^= x
7. x = (x >> 1) ^ ((x & 1) * R)
8. return result
```

Standard math properties hold in finite field math, viz. commutative: \\(
\small{ a+b=b+a } \\) and distributive: \\( \small{ a(b+c)=ab+ac } \\).


## 3. Computing MAC using secure two-party computation (2PC) <a name="section3"></a>

The goal of the protocol is to compute the MAC in such a way that neither party
would learn the other party's share of \\( \small{ H } \\) i.e. the `GHASH key`
share. At the start of the protocol each party has:
1. ciphertext blocks \\( \small{ X_1, X_2, ..., X_m } \\).
2. his XOR share of \\( \small{ H } \\): the `User` has \\( \small{ H_u } \\)
   and the `Notary` has \\( \small{ H_n } \\).
3. his XOR share of the `GCTR output`: the `User` has \\( \small{ GCTR_u } \\)
   and the `Notary` has \\( \small{ GCTR_n } \\).

Note that **2.** and **3.** were obtained at an earlier stage of the TLSNotary protocol.

### 3.1 Example with a single ciphertext block

To illustrate what we want to achieve, we consider the case of just having
a single ciphertext block \\( \small{ X_1 } \\). The `GHASH_output` will be:

\\( \small{ X_1•H = X_1•(H_u ⊕ H_n) = X_1•H_u ⊕ X_1•H_n } \\)

The `User` and the `Notary` will compute locally the left and the right terms
respectively. Then each party will XOR their result to the `GCTR output` share
and will get their XOR share of the MAC:

`User`  : \\( \small{X_1 • H_u \\quad ⊕ \\quad CGTR_u = MAC_u} \\)

`Notary`: \\( \small{X_1 • H_n \\quad ⊕ \\quad CGTR_n = MAC_n} \\)

Finally, the `Notary` sends \\( \small{MAC_n}\\) to the `User` who obtains: 

\\( \small{ MAC = MAC_n \\quad ⊕ \\quad MAC_u} \\)

**For longer ciphertexts, the problem is that higher powers of the hashkey
\\(H^k\\) cannot be computed locally, because we deal with additive sharings,
i.e.\\( (H_u)^k ⊕ (H_n)^k \neq H^k\\).** 

### 3.2 Computing ciphertexts with an arbitrary number of blocks
We now introduce our 2PC MAC protocol for computing ciphertexts with an
arbitrary number of blocks. Our protocol can be divided into the following
steps.

1. First, both parties convert their **additive** shares \\(H_u\\) and \\(H_n\\) into
   **multiplicative** shares \\(\overline{H}_u\\) and \\(\overline{H}_n\\).
2. This allows each party to **locally** compute the needed higher powers of these multiplicative
   shares, i.e for \\(m\\) blocks of ciphertext:
   - the user computes \\(\overline{H_u}^2, \overline{H_u}^3, ... \overline{H_u}^m\\) 
   - the notary computes \\(\overline{H_n}^2, \overline{H_n}^3, ... \overline{H_n}^m\\) 
3. Then both parties convert each of these multiplicative shares back to additive shares
   - the user ends up with \\(H_u, H_u^2, ... H_u^m\\) 
   - the notary ends up with \\(H_n, H_n^2, ... H_n^m\\) 
4. Each party can now **locally** compute their additive MAC share \\(MAC_{n/u}\\).

The conversion steps (**1.** and **3.**) require communication between the user
and the notary. They will use **A2M** (Addition-to-Multiplication) and **M2A**
(Multiplication-to-Addition) protocols, which make use of **oblivious
transfer**, to convert shares.


#### 3.2.1 (A2M) Convert additive shares of H into multiplicative shares

#### 3.2.2 (M2A) Convert multiplicative shares \\(\overline{H^k}\\) into additive shares

We use the oblivious transfer method described in chapter 4.1 of [Two Party RSA Key
Generation](https://link.springer.com/content/pdf/10.1007/3-540-48405-1_8.pdf)
to convert the multiplicative shares \\(\overline{H_{n/u}}\\) into additive
shares \\(H_{n/u}\\).

The user will decompose his shares into several <span
style="color:red">packages</span>, each masked with some random value
\\(s_i\\). He will then obliviously send these packages to the notary.
Depending on the binary representation of his multiplicative share, the notary
will choose one of the choices and do this for all 128 oblivious transfers.

After that the user will locally XOR all his \\(s_i\\) and end up with his additive
share \\(H_u\\), and the notary will do the same for all the results of the
oblivious transfer get \\(H_n\\).

\begin{aligned}
\overline{H} &= \overline{H_u} \cdot \overline{H_n} \\\\
&= \overline{H_u} \cdot \sum_i \overline{H_{n, i}} \cdot 2^i \\\\
&= \sum_i (\overline{H_{n, i}} \cdot \color{red}{\overline{H_u} \cdot 2^i + s_i}) ⊕ \sum_i s_i \\\\
&= \sum_i \color{red}{t_{u, i}}^{\overline{H_{n, i}}} ⊕ \sum_i s_i \\\\
&\equiv H_n ⊕ H_u
\end{aligned}


