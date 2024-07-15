# Verification

To prove data provenance to a third-party `Verifier`, the `Prover` provides the following information:
- [`Session Header`](/protocol/notarization.md#signing-the-session-header) signed by the `Notary`
- `opening` to the plaintext commitment
- `TLS-specific data` which uniquely identifies the server
- `identity` of the server

The `Verifier` performs the following verification steps:
- verifies that the `opening` corresponds to the commitment in the `Session Header`
- verifies that the `TLS-specific data` corresponds to the commitment in the `Session Header`
- verifies the `identity` of the server against `TLS-specific data`

Next, the `Verifier` parses the `opening` with an application-specific parser (e.g. HTTP or JSON) to get the final output. Since the `Prover` is allowed to selectively disclose the data, that data which was not disclosed by the `Prover` will appear to the `Verifier` as redacted. 

Below is an example of a verification output for an HTTP 1.1 request and response. Note that since the `Prover` chose not to disclose some sensitive information like their HTTP session token and address, that information will be withheld from the `Verifier` and will appear to him as redacted (in red).

![Verification example](/diagrams/verification_example.svg)
