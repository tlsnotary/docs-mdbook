# TLS handshake

During the TLS handshake the TLS Client and the TLS Server compute the session keys needed to perform the encryption and decryption of data.

In TLSNotary protocol `User` and `Notary` jointly play the role of the TLS Client. They work together to compute the session keys in such a way that neither party ever learns the full keys but each has their share of the keys.

First they compute their shares of the TLS Client's ECDH secret using [this protocol](/protocol/notarization/key_exchange.md). Since an ECDH secret is an EC point, the parties have their shares of that point.

Then they compute their shares of the pre-master secret (PMS) using an MPC protocol described [here](/building_blocks/ectf.md).

Then the parties input their PMS shares as private inputs to the [DEAP](./building_blocks/deap_deferred.md) protocol (along with some other public data). They performs the following in MPC: 

- they derive their shares of the TLS session keys
- they encrypt the Client Finished message (and the `User` sends the CF to the server)
- (the `User` receives the Server Finished message from the server and) they decrypt the SF message and check its authenticity.

To a third party who observes the `User`'s connection to the server, the connection looks like a regular TLS connection. The `User` maintains all the security guarantees of a regular TLS connection against a third-party bad actor.

However, the `User`'s TLS connection does not maintain the normal TLS security against the `Notary`. Instead, the `User` relies on security which the MPC protocols provide: i.e. 127-bit computational security and 40-bit statistical security. 


With the shares of the session keys computed, the parties now proceed to the next MPC protocol where they use their session key shares to jointly encrypt requests to and decrypt responses from the server while keeping the plaintext of the request/response private from the Notary.