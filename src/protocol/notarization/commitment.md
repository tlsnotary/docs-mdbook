# Commitment

The TLSNotary protocol completely hides the plaintext transcript from the `Notary`. At the same time we want to have a way for the `User` to selectively prove the authenticity of arbitrary portions of the plaintext to the `Verifier`.

Naively, we could extend the above `Encryption and Decryption` steps to also compute a commitment (e.g. a blake3 hash) to the plaintext in MPC and have the `Notary` sign that commitment. Then the `User` could open the commitment to the `Verifier`. Unfortunately such approach would be resource-heavy, and so we provide a more lightweight commitment scheme.

The high-level idea is that the `User` will reuse the encodings from the MPC protocol used for `Encryption and Decryption` to create commitments (see here for low-level details). Since those encodings are chosen by the `Notary` and are not known to the `User` at the time when she makes a commitment, they can be thought of as "authenticated plaintext".
For technical details on the commitment scheme, see [Commitment scheme](/mpc/commitment_scheme.md)
