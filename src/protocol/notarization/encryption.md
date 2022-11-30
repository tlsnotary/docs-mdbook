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

There is one exception to the above, and that is during the transmission of the first encrypted handshake messages in which The Notary has the opportunity to pick a different value for their keyshare. The result of this would simply be a corrupt payload. Either the User or Server would detect this immediately and subsequently abort the connection prior to the transmission of any application data. Past this stage the Notary is committed to using the same keyshare for the rest of the session and thus has no opportunity to introduce a malicious input.

### Notation

* $p$ is one block of plaintext
* $c$ is the corresponding block of ciphertext, ie $c = \mathsf{Enc}(k, ctr) \oplus p$
* $k$ is the cipher key
* $k_1$ and $k_2$ are the User's and Notary's keyshares, respectively. That is, $k = k_1 \oplus k_2$
* $z$ is a mask randomly selected by the User
* $ectr$ is the encrypted counter-block, ie $ectr = \mathsf{Enc}(k, ctr)$
* $G$ denotes a garbled circuit
* $d$ denotes output decoding information where $\mathsf{De}(d, [v]) = v$
* $\mathsf{Enc}$ denotes the block cipher used by the TLS session
* $\mathsf{PRG}$ denotes a secure pseudorandom generator
* $\mathsf{com}_x$ denotes a binding commitment to the value $x$
* $[x]_A$ denotes a garbled encoding of $x$ chosen by party $A$

## Encryption Protocol

### Phase 1: 2PC

1. The User creates a garbled circuit $G_U$ which computes $c = ectr \oplus p$ and generates output label commitments $\mathsf{com}_{[c]_U}$. She sends $G_U$, $[k_1]_U$, $[p]_U$, $d_U$ and $\mathsf{com}_{[c]_U}$ to the Notary.
2. The Notary creates a garbled circuit $G_N$ computing the same function, using privacy-free garbling. He sends $G_N$ and $d_N$ to the User.
3. The User retrieves $[k_1]_N$ and $[p]_N$ from the Notary using OT.
4. The Notary retrieves $[k_2]_U$ from the User using OT.
5. The Notary evaluates $G_U$ using $[k_2]_U$ and the rest of the input labels received from the User. Doing so, the Notary acquires $[c]_U$ which he checks against the commitment $\mathsf{com}_{[c]_U}$, aborting if invalid.
6. The Notary sends $[c]_U$ to the User.
7. The Notary decodes $[c]_U$ to $c^U$ using $d_U$ which he received earlier. He computes $\mathsf{H}([c]_U, [c^U]_N)$ which we'll call $\mathsf{check}_N$, and stores it for the equality check later.
8. The User checks that $[c]_U$ received from the Notary is authentic, aborting if not, then decodes it to acquire $c$.

The Notary, even if malicious, has learned nothing except the purported ciphertext $c^U$ and is not convinced it is correct.

The User, if honest, has learned the correct ciphertext $c$ thanks to the authenticity property of garbled circuits. She, if malicious, has potentially learned the Notary's entire keyshare $k_2$.

### Phase 2: ZK

This phase is deferred until _after_ the TLS session is closed.

9. The Notary reveals his keyshare by sending both $k_2$ and $[k_2]_N$ to the User.
10. The User evaluates $G_N$ using $[k_1]_N$ and $[k_2]_N$ to acquire $[c]_N$ and decodes them to $c^N$ using $d_N$. She computes $\mathsf{H}([c^N]_U, [c]_N)$ which we will call $\mathsf{check}_U$.
11. The User computes a commitment $\mathsf{Com}(\mathsf{check}_U, r) = \mathsf{com}_{\mathsf{check}_U}$ where $r$ is random. She sends this commitment to the Notary.
12. The Notary receives $\mathsf{com}_{\mathsf{check}_U}$ and stores it for the equality check later.
13. The Notary opens his garbled circuit and OT by sending $\Delta_N$ and $\rho$ to the User.
14. The User, now knowing all inputs and $\Delta_N$, derives the full input labels of $G_N$.
15. The User opens all of the Notary's OTs for $[k_1]_N$ and verifies that they were performed honestly. Otherwise she aborts.
16. The User verifies that $G_N$ was garbled honestly and that the $d_N$ Bob sent earlier was correct. Otherwise she aborts.
17. The User now opens $\mathsf{com}_{\mathsf{check}_U}$ by sending $\mathsf{check}_U$ and $r$ to the Notary.
18. The Notary verifies $\mathsf{com}_{\mathsf{check}_U}$ then asserts $\mathsf{check}_U == \mathsf{check}_N$, aborting otherwise.

The Notary is now convinced that $c^U$ is correct, ie equal to $c$. The Notary is also assured that the User only learned up to k bits of his input prior to revealing, with a probability of $\frac{1}{2^k}$ of it being undetected.

## Decryption Protocol

The protocol for decryption is very similar but has some key differences to encryption.

### 2PC

In the first step of the protocol, the User has to get the encrypted counter-block from the Notary. The User does not trust the Notary (for privacy or integrity), and the encrypted counter-block is far more sensitive to leakage than the Notary's key. So the parties do an ordinary DualEx:

0. The User and Notary both garble a copy of the encryption circuit which computes the masked encrypted counter-block $ectr_z = ectr \oplus z$. The Notary can garble their circuit using privacy-free garbling as per observation 1. For committed OT the Notary constructs the input wire labels and OT encryption keys as $\mathsf{PRG}(\rho)$ where $\rho$ is a randomly sampled PRG seed, and sends $\mathsf{com}_\rho$ to the User after the OT is done.
1. The User retrieves $[k_1]_N$ and $[z]_N$ from the Notary using oblivious transfer, as well as $\mathsf{com}_\rho$.
2. The Notary retrieves $[k_2]_U$ from the User using oblivious transfer.
3. The User sends her garbled encryption circuit and garbled wires $[k_1]_U$ and $[z]_U$. She also sends the output decoding information.
4. The Notary uses his OT values to evaluate the circuit on $[k_2]_U$. He derives the masked encrypted counter-block $[ectr_z]_U$ and decodes it using output decoding information to get $ectr^U_{z}$.[^1]
5. The Notary sends the output wire labels $[ectr_z]_U$ to the User.[2]

    Step 5 is a relaxation of DualEx. In DualEx, the User would not learn the Notary's evaluation output at this point. As mentioned earlier, in TLSNotary protocol's setting, we are not worried that $[ectr_z]$ may leak the Notary's input, as long as this behaviour will be detected later. Also we are not worried about DualEx's inherent 1-bit leakage since it gives no meaningful advantage to the User as explained earlier. 
    
    There is no wiggle room for the User to exploit this relaxation because she is locked into using the inputs she received via OT in Step 1 and she has to pass the DualEx equality check which will follow later in Step 18.

6. As per DualEx, now the Notary knows what the User's encoded output should be, so the Notary computes $Check_N = H([ectr_z]_U, [ectr^{U}_z]_N)$ and keeps it.
7. The User decodes $[ectr_z]_U$ to $ectr_z$ and removes the mask to compute the plaintext server response $p = ectr_z \oplus z \oplus c$. Thanks to the authenticity property, the User knows $p$ is the authentic plaintext sent by the Server.
8. The User retrieves the wire labels $[p]_N$ for the plaintext $p$ via oblivious transfer from the Notary, commits to them $\mathsf{com}_{[p]_N}$, and sends this commitment to the Notary.


[1]: Note that it is in keeping with the DualEx paper to allow a party to send the wrong output decoding information, or to provide different inputs to the two circuit evaluations. This does not affect the security of DualEx.

[2]: A question may arise at this point re Step 5: why doesn't the Notary simply send $ectr_z$ to the User. The reason is that the Notary could send a maliciously crafted $ectr_z$: the Notary could flip a bit in $ectr_z$ (which translates into flipping a bit in the plaintext). This may cause the User's next request to do something unexpected.

At this point, the Notary (even if malicious) has learned nothing about the key or the plaintext.

Also at this point, the User has learned the plaintext, and, if malicious, has potentially learned the entire key $k$. As mentioned in the second observation above, it is okay if the User was malicious and learned $k$, but the Notary has to detect it and then abort the rest of the TLSNotary protocol. Before this step, the Notary waits for the User to complete their TLS session.

### ZK

Now that the session is over and $k_2$ is no longer a secret, the Notary can send their privacy-free garbled circuit for the second part of DualEx.

10. The Notary sends his garbled circuit to the User, as well as the garbled wires $[k_2]_N$. He also sends the output decoding information.
11. The User evaluates the circuit on $[k_1]_N$ and $[z]_N$, using the OT values from step 1, to acquire the labels for the masked encrypted counter-block $[ectr_z]_N$. She then decodes it to $ectr^{N}_z$ using the output decoding information.
12. As per DualEx, she computes $Check_U = H([ectr^{N}_z]_U, [ectr_z]_N)$ and sends a commitment $\mathsf{com}_{Check_U}$ to the Notary.

    Note that at this stage the Notary could reveal $Check_N$ and the User would make sure that $Check_N == Check_U$. Then likewise the User would reveal $Check_U$ and the Notary would make sure that $Check_N == Check_U$.
    As per the DualEx's inherent 1-bit leakage, the very act of performing the equality check would leak 1 bit of the plaintext to a malicious Notary. To avoid the leakage, the User must first check the consistency of the Notary's OT and garbled circuits:

13. The User also uses her wire labels $[p]_N$ she received in step 8, to compute $[c]_N = [ectr]_N \oplus [p]_N$. She generates a commitment $\mathsf{com}_{[c]_N}$ and sends it to the Notary.
14. The Notary reveals all the wire labels and OT encryption keys by opening $\mathsf{com}_{\rho}$.
15. The User checks that the opening is correct, and that $\mathsf{PRG}(\rho)$ is consistent with the OT ciphertexts sent earlier by the Notary. On success, she opens her commitment, sending $Check_U$ and the commitment's randomness to the notary.

With the consistency check passed, the parties resume the DualEx's equality check which asserts:

$H([ectr^{N}_z]_U, [ectr_z]_N) == H([ectr_z]_U, [ectr^{U}_z]_N)$

16.  The Notary sends $Check_N$ to the User.
17.  The User asserts that $Check_N == Check_U$. The User decommits $\mathsf{com}_{Check_U}$ by sending $Check_U$ and the commitment's randomness to the Notary.
18.  The Notary checks the decommitment and asserts that $Check_N == Check_U$.

Now the Notary is convinced that the User did not cheat to learn $k_2$ before the TLS session ended. However,
    the User must now prove that $p \oplus ectr == c$

19.   The User decommits $\mathsf{com}_{[c]_N}$ by sending $[c]_N$ and the commitment's randomness to the Notary.
20.   The Notary checks the decommitment, decodes $[c]_N$ to $c$ and asserts that it is equal to the expected ciphertext.

Now the Notary is convinced that the User knew $[p]_N$ prior to opening his circuit, and the User _allegedly_ committed to these labels in $\mathsf{com}_{[p]_N}$ during step 8. The thing to notice here is: If the user was able to compute $[c]_N$ prior to the circuit being opened, then that guarantees the labels in $\mathsf{com}_p$ correspond to $p$ _if they are valid labels_. For this to be false, the User would have to guess valid wire labels for $[p]_N$ prior to the Notary's circuit being opened.

Now they can proceed to the authdecode protocol, which checks that $\mathsf{com}_{[p]_N}$ commits to _valid labels_.