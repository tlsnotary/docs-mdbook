# TLS Handshake

A TLS handshake is the first step in establishing a TLS connection between a `User` and a `Server`. In TLSNotary the `User` is the one who starts the TLS handshake and physically communicates with the `Server`, but all cryptographic TLS operations are performed together with the `Notary` using MPC.

The `User` and `Notary` use a series of MPC protocols to compute the TLS session key in such a way that both only have their share of the key and never learn the full key. Both parties then proceed to complete the TLS handshake using their shares of the key.

With the shares of the session key computed and the TLS handshake completed, the parties now proceed to the next MPC protocol where they use their session key shares to jointly generate encrypted requests and decrypt server responses while keeping the plaintext of both the requests and responses private from the `Notary`.


> Note: to a third party observer, the `User`'s connection to the server appears like a regular TLS connection and the security guaranteed by TLS remains intact for the `User`.
>
> The only exception is that since the `Notary` is a party to the MPC TLS, the security for the `User` against a malicious `Notary` is guaranteed by the underlying MPC protocols and not by the TLS.