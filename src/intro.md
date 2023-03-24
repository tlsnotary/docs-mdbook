# Introduction

TLSNotary is a protocol which allows users to export data from any website in a
credible way. This way they can verify the authenticity of parts of a
TLS-encrypted web session without compromising on privacy.

It works by adding a third party, the Notary, to the usual TLS connection
between the User and a web server. The User forwards the encrypted TLS traffic
to the Notary which checks that it has not been tampered with and notarizes the
whole TLS session by signing a transcript of it.

The User can now use this transcript and disclose parts of it to another
party, which we call Verifier. The Verifier only needs to trust the Notary
in order to accept proofs from many different users. This way, TLSNotary
can be used for a variety of purposes. For example you can use TLSNotary to
prove that

- you have received a money transfer using your online banking account, without
  revealing your login credentials or sensitive financial information.
- you have access to an account on a web platform.
- a website showed some specific content on a certain date.

Overall, the TLSNotary protocol can be used in any scenario where you need to
prove to a third party facts about the content of a TLS connection.

Some interesting aspects of TLSNotary are:
- The protocol is transparent to the web server, because it is not aware of the
  notarization process. For the server it just looks like normal browsing.
- Data is kept private from the Notary. The Notary only sees the ciphertext and
  never has access to the plaintext.
- No modifications to the TLS protocol are needed. You can use it without any
  changes to web servers.
- The Notary and the Verifier can be the same entity. That means if you as a
  Verifier do not want to trust some Notary server, you can run one yourself.

