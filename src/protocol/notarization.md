# Notarization

Even though the `Prover` can prove data provenance directly to the `Verifier`, in some scenarios it may be beneficial for the `Verifier` to outsource the verification of the TLS session to a trusted `Notary` as explained [here](/intro.html#tls-verification-with-a-general-purpose-notary).

As part of the TLSNotary protocol, the `Prover` creates authenticated commitments to the plaintext and has the `Notary` sign them without the `Notary` ever seeing the plaintext. This offers a way for the `Prover` to selectively prove the authenticity of arbitrary portions of the plaintext to an application-specific `Verifier` later.

Please refer to the [Commitments](/mpc/commitments.md) section for low-level details on the commitment scheme.  

## Signing the Session Header

The `Notary` signs an artifact known as a `Session Header`, thereby attesting to the authenticity of the plaintext from a TLS session. A `Session Header` contains a `Prover`'s commitment to the plaintext and a `Prover`'s commitment to TLS-specific data which uniquely identifies the server.

The `Prover` can later use the signed `Session Header` to prove data provenance to an application-specific `Verifier`.

It's important to highlight that throughout the entire TLSNotary protocol, including this signing stage, the `Notary` does not gain knowledge of either the plaintext or the identity of the server with which the `Prover` communicated.
