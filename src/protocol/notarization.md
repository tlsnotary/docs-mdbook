# Notarization

As part of the TLSNotary protocol, the `Prover` can create authenticated commitments to the plaintext and have the `Notary` sign them without ever seeing the plaintext. This offers a way for the `Prover` to selectively prove the authenticity of arbitrary portions of the plaintext to a different `Verifier`. 

A naive approach of creating such authenticated commitments is to extend the `Encryption and Decryption` steps to also compute a commitment (e.g. BLAKE3 hash) to the plaintext using MPC and have the `Notary` sign that commitment. Unfortunately, such an approach is too resource-intensive, prompting us to provide a more lightweight commitment scheme.

The high-level idea is that the `Prover` creates a commitment to the encodings from the MPC protocol used for `Encryption and Decryption`. Since those encodings are chosen by the `Notary` and are not known to the `Prover` at the time when she makes a commitment, they can be thought of as "authenticated plaintext".

## Signing the Session Header

The `Notary` signs an artifact known as a `Session Header`, thereby attesting to the authenticity of the plaintext from a TLS session. A `Session Header` contains a `Prover`'s commitment to the plaintext and a `Prover`'s commitment to TLS-specific data which uniquely identifies the server.

The `Prover` can later use the signed `Session Header` to prove data provenance to a third-party `Verifier`.

It's important to highlight that throughout the entire TLSNotary protocol, including this signing stage, the `Notary` does not gain knowledge of either the plaintext or the identity of the server with which the `Prover` communicated.
