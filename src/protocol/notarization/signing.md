# Signing the Session Header

At the end of the TLSNotary protocol, the `Notary` signs an artifact known as a `Session Header`, thereby attesting to the authenticity of the plaintext from a TLS session. A `Session Header` contains a `User`'s commitment to the plaintext and a `User`'s commitment to TLS-specific data which uniquely identifies the server.

The `User` can later use the signed `Session Header` to prove data provenance to a third-party `Verifier`.

It's important to highlight that throughout the entire TLSNotary protocol, including this signing stage, the `Notary` does not gain knowledge of either the plaintext or the identity of the server with which the `User` communicated.




