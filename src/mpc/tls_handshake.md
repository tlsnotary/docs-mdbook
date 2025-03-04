# TLS handshake

During the TLS handshake the TLS Client and the TLS Server compute the session keys needed to perform the encryption and decryption of data.

In TLSNotary protocol `User` and `Notary` jointly play the role of the TLS Client. They use MPC to compute the session keys in such a way that neither party ever learns the full keys but each has their share of the keys.


First they compute their shares of the TLS Client's ECDH secret using [this protocol](key_exchange.md). Since an ECDH secret is an EC point, the parties have their shares of that point.

Then they compute their shares of the pre-master secret (PMS) using an MPC protocol described [here](./ectf.md).

Then the parties input their PMS shares as private inputs to the [DEAP](deap.md) protocol (along with some other public data). They perform the following in MPC: 

- they derive their shares of the TLS session keys
- they encrypt the Client Finished message (and the `User` sends the CF to the server)
- (the `User` receives the Server Finished message from the server and) they decrypt the SF message and check its authenticity.