# Quick Start

This quick start will help you get started with TLSNotary, both in native Rust and in the Browser.

## Objectives

- Gain a better understanding of what you can do with TLSNotary
- Learn the basics of how to notarize and verify data using TLSNotary

## Rust

1. [Interactive Verification Example](rust.md#interactive): This example demonstrates how to use TLSNotary in a simple interactive session between a Prover and a Verifier. It involves the Verifier first verifying the MPC-TLS session and then confirming the correctness of the data.
2. [Simple Attestation Example](rust.md#attestation): Use TLSNotary with a Notary attesting to the data.

## Browser

### Hosted demo

To get started with TLSNotary in the browser, it is recommended to try the online TLSNotary demo first. This demo shows how TLSNotary can be used to verify private user data in a web app. The demo guides you through the following steps:

1. Installing the browser extension
2. Installing the website plugin into the browser extension
3. Running the plugin to get a TLSNotary attestation
4. Verifying the attestation on the server

Visit [demo.tlsnotary.org](https://demo.tlsnotary.org) to try the different steps.

### Proving and Verifying Data in a React/Typescript App (`tlsn-js`)

Learn how to use TLSNotary in a React/Typescript app with the `tlsn-js` NPM module.

[Proving and Verifying Data in a React/Typescript App](tlsn-js.md#browser)

### Browser Extension

Learn how to prove and verify ownership of a Twitter account using the TLSNotary browser extension.

[Proving and Verifying Ownership of a Twitter Account (Browser)](browser_extension.md#browser)

