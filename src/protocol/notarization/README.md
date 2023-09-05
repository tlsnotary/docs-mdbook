# Notarization Phase

During the Notarization Phase the `Prover`, otherwise referred to as the `User`, and the `Notary` work together to generate an authenticated `Transcript` of a TLS session with a `Server`.

Listed below are some key points regarding this process:

 - The identity of the `Server` is not revealed to the `Notary`, but the `Prover` is capable of proving the `Server` identity to a `Verifier` later.
 - The `Notary` only ever sees the *encrypted* application data of the TLS session.
 - The protocol guarantees that the `Prover` is not solely capable of constructing requests, nor can they forge responses from the `Server`.