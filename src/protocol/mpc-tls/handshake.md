# Handshake

A TLS handshake is the first step in establishing a TLS connection between a `Prover` and a `Server`. In TLSNotary the `Prover` is the one who starts the TLS handshake and physically communicates with the `Server`, but all cryptographic TLS operations are performed together with the `Verifier` using MPC.

The `Prover` and `Verifier` use a series of MPC protocols to compute the TLS session key in such a way that both only have their share of the key and never learn the full key. Both parties then proceed to complete the TLS handshake using their shares of the key.

With the shares of the session key computed and the TLS handshake completed, the parties now proceed to the next MPC protocol where they use their session key shares to jointly generate encrypted requests and decrypt server responses while keeping the plaintext of both the requests and responses private from the `Verifier`.


> Note: to a third party observer, the `Prover`'s connection to the server appears like a regular TLS connection and the security guaranteed by TLS remains intact for the `Prover`.
>
> The only exception is that since the `Verifier` is a party to the MPC TLS, the security for the `Prover` against a malicious `Verifier` is guaranteed by the underlying MPC protocols and not by TLS.