# Encryption

Here we will explain our protocol for 2PC encryption using a block cipher in counter-mode.

Our documentation on [Dual Execution with Asymmetric Privacy](../2pc/deap.md) is recommended prior reading for this section.

## Preliminary

### Ephemeral Keyshare

It is important to recognise that the Notary's keyshare is an _ephemeral secret_. It is only private for the duration of the User's TLS session, after which the User is free to learn it without affecting the security of the protocol.

It is this fact which allows us to achieve malicious security for relatively low cost. More details on this [here](../2pc/deap.md).

### Premature Leakage

A small amount of undetected premature keyshare leakage is quite tolerable. For example, if the Notary leaks 3 bits of their keyshare, it gives the User no meaningful advantage in any attack, as she could have simply guessed the bits correctly with $2^{-3} = 12.5\%$ probability and mounted the same attack. Assuming a sufficiently long cipher key is used, eg. 128 bits, this is not a concern.

The equality check at the end of our protocol ensures that premature leakage is detected with a probability of $1 - 2^{-k}$ where k is the number of leaked bits. The Notary is virtually guaranteed to detect significant leakage and can abort prior to notarization.

### Plaintext Leakage

Our protocol assures _no leakage_ of the plaintext to the Notary during both encryption and decryption. The Notary reveals their keyshare at the end of the protocol, which allows the Notary to open their garbled circuits and oblivious transfers completely to the User. The User can then perform a series of consistency checks to ensure that the Notary behaved honestly. Because these consistency checks do not depend on any inputs of the User, aborting does not reveal any sensitive information (in contrast to standard DualEx which does).

### Integrity

During the entirety of the TLS session the User performs the role of the garbled circuit generator, thus ensuring that a malicious Notary can not corrupt or otherwise compromise the integrity of messages sent to/from the Server.

### Notation

* $p$ is one block of plaintext
* $c$ is the corresponding block of ciphertext, ie $c = \mathsf{Enc}(k, ctr) \oplus p$
* $k$ is the cipher key
* $ctr$ is the counter block
* $k_U$ and $k_N$ denote the User and Notary cipher keyshares, respectively, where $k = k_U \oplus k_N$
* $z$ is a mask randomly selected by the User
* $ectr$ is the encrypted counter-block, ie $ectr = \mathsf{Enc}(k, ctr)$
* $\mathsf{Enc}$ denotes the block cipher used by the TLS session
* $\mathsf{com}_x$ denotes a binding commitment to the value $x$
* $[x]_A$ denotes a garbled encoding of $x$ chosen by party $A$

## Encryption Protocol

The encryption protocol uses [DEAP](../2pc/deap.md) without any special variations. The User and Notary directly compute the ciphertext for each block of a message the User wishes to send to the Server:

$$f(k_U, k_N, ctr, p) = \mathsf{Enc}(k_U \oplus k_N, ctr) \oplus p = c$$

The User creates a commitment to the plaintext active labels for the Notary's circuit $\mathsf{Com}([p]_N, r) = \mathsf{com}_{[p]_N}$ where $r$ is a random key known only to the User. The User sends this commitment to the Notary to be used in the authdecode protocol later. It's critical that the User commits to $[p]_N$ prior to the Notary revealing $\Delta$ in the final phase of DEAP. This ensures that if $\mathsf{com}_{[p]_N}$ is a commitment to valid labels, then it must be a valid commitment to the plaintext $p$. This is because learning the complementary wire label for any bit of $p$ prior to learning $\Delta$ is virtually impossible.

## Decryption Protocol

The protocol for decryption is very similar but has some key differences to encryption.

For decryption, [DEAP](../2pc/deap.md) is used for every block of the ciphertext to compute the _masked encrypted counter-block_:

$$f(k_U, k_N, ctr, z) = \mathsf{Enc}(k_U \oplus k_N, ctr) \oplus z = ectr_z$$

This mask $z$, chosen by the User, hides $ectr$ from the Notary and thus the plaintext too. Conversely, the User can simply remove this mask in order to compute the plaintext $p = c \oplus ectr_z \oplus z$.

Following this, the User can retrieve the wire labels $[p]_N$ from the Notary using OT.

Similarly to the procedure for encryption, the User creates a commitment $\mathsf{Com}([p]_N, r) = \mathsf{com}_{[p]_N}$ where $r$ is a random key known only to the User. The User sends this commitment to the Notary to be used in the authdecode protocol later.

### Proving the validity of $[p]_N$

In addition to computing the masked encrypted counter-block, the User must also prove that the labels $[p]_N$ they chose afterwards actually correspond to the ciphertext $c$ sent by the Server.

This is can be done efficiently in one execution using the zero-knowledge protocol described in [[JKO13]](https://eprint.iacr.org/2013/073.pdf) the same as we do in the final phase of DEAP.

The Notary garbles a circuit $G_N$ which computes:

$$p \oplus ectr = c$$

Notice that the User and Notary will already have computed $ectr$ when they computed $ectr_z$ earlier. Conveniently, the Notary can re-use the garbled labels $[ectr]_N$ as input labels for this circuit. For more details on the reuse of garbled labels see [[AMR17]](https://eprint.iacr.org/2017/062.pdf).