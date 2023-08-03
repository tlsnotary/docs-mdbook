# TLS Handshake

During the TLS handshake, the TLS Client and the TLS Server compute the session keys needed for the encryption and decryption of data.

In TLSNotary protocol `User` and `Notary` jointly play the role of the TLS Client. The User is the one who physically communicates with the server but all cryptographic TLS operations are performed in MPC.
The parties use MPC to compute the session keys in such a way that neither party ever learns the full keys but each has their share of the keys.
They then use their shares of the keys to finish the TLS handshake.

To a third party observing the `User`'s connection to the server, the connection appears like a regular TLS connection. The `User` maintains all the security guarantees of a standard TLS connection against a third-party bad actor.

However, the `User`'s TLS connection does not maintain the normal TLS security against the `Notary`. Instead, the `User` relies on the security which the underlying MPC protocols provide.

With the shares of the session keys computed, the parties now proceed to the next MPC protocol where they use their session key shares to jointly encrypt requests to and decrypt responses from the server while keeping the plaintext of the request/response private from the Notary.
