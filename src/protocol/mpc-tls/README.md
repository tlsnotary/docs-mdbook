# MPC-TLS

During the MPC-TLS phase the `Prover` and the `Verifier` work together to generate an authenticated `Transcript`[^transcript] of a TLS session with a `Server`.

Listed below are some key points regarding this process:

- The `Verifier` only ever sees the *encrypted* application data of the TLS session.
- The protocol guarantees that the `Prover` is not solely capable of constructing requests, nor can they forge responses from the `Server`.
- When the `Verifier` is a `Notary` (see section on [Notarization](../notarization.md)), the identity of the `Server` is hidden and can be proven to another application-specific verifier later.


<!-- The MPC-TLS protocol consists of the following steps:

1. **Handshake**  
A TLS handshake is the first step in establishing a TLS connection between the `Prover`/`Verifier` and the `Server`. The result of this handshake is a *Pre Master Secret (PMS)*, a symmetrical key that will be used for further encrypted communication. The server has the full key; the `Prover` and the `Verifier` only have their share of this key.
2. **Encryption, Decryption, and MAC Computation**  
Next, the `Prover` and `Verifier` use MPC to encrypt, and decrypt, data sent to, and received from, the `Server`. They also compute a *Message Authentication Code (MAC)* 
for the data that ensures untampered communication. -->


[^transcript]: A transcript is the application level data that is send to and received from the `Server`
