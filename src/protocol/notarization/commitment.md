# Commitment

The TLSNotary protocol entirely conceals the plaintext transcript from the `Notary`. Simultaneously, the TLSNotary protocol offers a way to the `User` to selectively prove the authenticity of arbitrary portions of the plaintext to the `Verifier`.

A naive approach could extend the `Encryption and Decryption` steps to also compute a commitment (e.g. a blake3 hash) to the plaintext in MPC, with the `Notary` signing that commitment. The `User` could then open the commitment to the `Verifier`. Unfortunately, this approach would be resource-intensive, prompting us to provide a more lightweight commitment scheme.

The high-level idea is that the `User` will reuse the encodings from the MPC protocol used for `Encryption and Decryption` to create commitments[^commitment_scheme]. Since those encodings are chosen by the `Notary` and are not known to the `User` at the time when she makes a commitment, they can be thought of as "authenticated plaintext".

[^commitment_scheme] For technical details on the commitment scheme, see [Commitment scheme](/mpc/commitment_scheme.md)