# Commitment

As part of the TLSNotary protocol, the `User` creates authenticated commitments to the plaintext and the `Notary` signs those commitments without ever seeing the plaintext. This offers a way for the `User` to selectively prove the authenticity of arbitrary portions of the plaintext to the `Verifier`. 

A naive approach of creating such authenticated commitments is to extend the `Encryption and Decryption` steps to also compute a commitment (e.g. a blake3 hash) to the plaintext using MPC and have the `Notary` sign that commitment. Unfortunately, such MPC approach is too resource-intensive, prompting us to provide a more lightweight commitment scheme.

The high-level idea is that the `User` creates a commitment to the encodings from the MPC protocol used for `Encryption and Decryption`. Since those encodings are chosen by the `Notary` and are not known to the `User` at the time when she makes a commitment, they can be thought of as "authenticated plaintext".