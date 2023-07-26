# TLS Handshake

During the TLS handshake, the TLS Client and the TLS Server compute the session keys needed for the encryption and decryption of data.

In the TLSNotary protocol, the `User` and `Notary` jointly play the role of the TLS Client. They cooperate to compute the session keys in such a way that neither party can discern the complete keys. They both only have their key share.

Initially, they compute their shares of the TLS Client's ECDH secret using [this protocol](/protocol/notarization/key_exchange.md). Given that an ECDH secret is an EC point, the parties hold shares of that point.

Next, they compute their shares of the pre-master secret (PMS) using an MPC protocol described [here](/building_blocks/ectf.md).

Subsequently, the parties feed their PMS shares as private inputs to the [DEAP](/building_blocks/deap_deferred.md) protocol, along with some other public data. They perform the following actions within MPC: 

- They derive their shares of the TLS session keys.
- They encrypt the Client Finished message, and the `User` sends the CF to the server.
- After receiving the Server Finished message from the server, the `User` collaborates with the `Notary` to decrypt the SF message and verify its authenticity.

To a third party observing the `User`'s connection to the server, the connection appears like a regular TLS connection. The `User` maintains all the security guarantees of a standard TLS connection against a third-party bad actor.

However, the `User`'s TLS connection does not maintain the typical TLS security against the `Notary`. Instead, the `User` relies on the security provided by the MPC protocols: 127-bit computational security and 40-bit statistical security.

With the shares of the session keys computed, the parties now proceed to the next MPC protocol. Here, they use their session key shares to jointly encrypt requests to and decrypt responses from the server, while keeping the plaintext of the request/response private from the Notary.
