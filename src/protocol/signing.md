# Signing the session header.

The `Notary` signs the following artifacts called the `Session Header` which are required for the `User` to prove to a third-party `Verifier` the authenticity of the plaintext from the TLS session.
We emphasize that throughout the whole TLSNotary protocol, the `Notary` never learns the plaintext neither learns what domain the `User` communicates with.

// taken from tlsn/tlsn-core/src/session/header.rs

// TODO: will explain the meaning of each

- encoder_seed:  
- merkle_root
- sent_len
- recv_len
- time
- server_public_key
- handshake_commitment