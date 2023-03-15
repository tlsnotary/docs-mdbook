# Introduction

TLSNotary is a protocol which allows users to export data from any website in a
credible way. This way they can verify the authenticity of parts of a
TLS-encrypted web session without compromising on privacy.

It works by adding a third party, the notary server, to the usual client/server
communication. The client forwards the encrypted TLS traffic to this notary
server which checks that it has not been tampered with and notarizes the whole
client/server session by signing a transcript of it.

The client can now use this transcript and disclose parts of it to another
party, which we call verifier. The verifier only needs to trust the notary
server in order to accept proofs from many different users. This way, TLSNotary
can be used for a variety of purposes. For example you can use TLSNotary to
prove that

- you have received a money transfer using your online banking account, without
  revealing your login credentials or sensitive financial information.
- you have access to an account in some online community.
- a website showed some specific content on a certain date.

Overall, the TLSNotary protocol can be used in any scenario where a client needs
to prove to a third party facts about the content of a TLS connection.

Some interesting aspects of TLSNotary are:
- The protocol is transparent to the web server, because it is not aware of the
  notarization process. For the server it just looks like normal browsing.
- Data is kept private from the notary. The notary only sees the ciphertext and
  never has access to the plaintext.
- No modifications to the TLS protocol are needed. You can use it without any
  changes to web servers.
- The notary and the verifier can be the same entity. That means if you as a
  verifier do not want to trust some notary server, you can run one yourself.

