# DEAP with a deferred equality check


TLSNotary uses the [DEAP](/protocol/2pc/deap.md) protocol to ensure malicious security during the Encryption and Decryption steps.

When using DEAP in TLSNotary, the `User` plays the role of Alice and has full privacy and the `Notary` plays the role of Bob and reveals all of his private inputs after the TLS session with the server is over. (The Notary's private inputs are his TLS session key shares).

The parties run the `Setup` and `Execution` steps of `DEAP` but for performance reasons they defer the `Equality Check` until after the TLS session with the server is over. The rationale for deferring the `Equality Check` is as follows:

Note that Step 12 of `DEAP` allows the `User` to obtain an authentic output even before the `Equality Check` step is performed. This enables the `User` to immediately use this authentic output in her TLS session while deferring the `Equality Check` step until after the TLS session with the server is over.
