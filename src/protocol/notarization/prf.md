### Overview

The pre-master secret (`PMS`) must be put through a `PRF` (pseudo-random function) defined by the TLS spec in order to compute the symmetric TLS keys and also to compute the `verify_data` for the `Client_Finished` and the `Server_Finished` messages.

Below we describe how the parties (`N` stands for `Notary` and `U` stands for `User`) who have their shares of `PMS` can use 2PC to compute the `PRF`. 

>Since the TLSNotary protocol already uses Garbled Circuits and Oblivious Transfer which give 128-bit computational security for the parties against each other, we argue that it is acceptable to perform some PRF computations outside of 2PC as long as it is done with at least 128-bit security.
Performing some PRF computations outside of 2PC allows to save on computation and bandwidth.

> Note that the User's TLS connection retains the standard TLS security guarantees against any third-party adversary. 

To elaborate, recall how [HMAC](https://en.wikipedia.org/wiki/HMAC) is computed (assuming |k| <= block size):

```
HMAC(k, m) = H((k ⊕ opad) | H((k ⊕ ipad) | m))
```

Notice that both H(k ⊕ opad) and H(k ⊕ ipad) can be computed separately prior to finalization. In this
document we name these units as such:
- `outer hash state`: H(k ⊕ opad)
- `inner hash state`: H(k ⊕ ipad)
- `inner hash`: H((k ⊕ ipad) | m)

In TLS, the master secret is computed like so:

```python
seed = "master secret" | client_random | server_random
a0 = seed
a1 = HMAC(pms, a0)
a2 = HMAC(pms, a1)
p1 = HMAC(pms, a1 | seed)
p2 = HMAC(pms, a2 | seed)
ms = (p1 | p2)[:48]
```

Notice that in each step the key, in this case `PMS`, is constant. Thus both the `outer` and `inner hash state` can be reused for each step.

Below is the description of the all the steps to compute the `PRF` both inside and outside the 2PC circuit.


## ---- Computing the master secret

### -- Inside the circuit

1. To evaluate the circuit, the parties input their `PMS` shares. The circuit outputs:
 - H(PMS ⊕ opad) called `PMS` `outer hash state` to `N` and
 - H(PMS ⊕ ipad) called `PMS` `inner hash state` to `U`

### -- Outside the circuit

2. `U` computes H((PMS ⊕ ipad) || a0) called `inner hash` of `a1` and passes it to `N`.

3. `N` computes `a1` and passes it to `U`.

4. `U` computes the `inner hash` of `a2` and passes it to `N`.

5. `N` computes `a2` and passes it to `U`.

6. `U` computes the `inner hash` of p2 and passes it to `N`.

7. `N` computes `p2` and passes it to `U`.
>Note that now both parties know `p2` which is the last 16 bytes of the master secret. They still don't know the other 32 bytes of the master secret, which ensures adequate security.

8. `U` computes the `inner hash` of `p1`.

### -- Inside the circuit

9. To evaluate the circuit, `N` inputs the `PMS outer hash state` and `U` inputs `p2` and the `inner hash` of `p1`. The circuit computes the master secret (`MS`).


## ---- Computing the expanded keys

The parties proceed to compute the `expanded keys`. The corresponding python code is:

```python
seed = str.encode("key expansion") + server_random + client_random
a0 = seed
a1 = hmac.new(ms , a0, hashlib.sha256).digest()
a2 = hmac.new(ms , a1, hashlib.sha256).digest()
p1 = hmac.new(ms, a1+seed, hashlib.sha256).digest()
p2 = hmac.new(ms, a2+seed, hashlib.sha256).digest()
ek = (p1 + p2)[:40]
client_write_key = ek[:16]
server_write_key = ek[16:32]
client_write_IV = ek[32:36]
server_write_IV = ek[36:40]
```

### -- Inside the circuit

10. Having computed `MS`, the circuit outputs:
 - H(MS ⊕ opad) called the `MS outer hash state` to `N` and
 - H(MS ⊕ ipad) called the `MS inner hash state` to `U`

### -- Outside the circuit

11. `U` computes the `inner hash` of `a1` and sends it to `N`.

12. `N` computes `a1` and sends it to `U`.

13. `U` computes the `inner hash` of `a2` and sends it to `N`.

14. `N` computes `a2` and sends it to `U`.

15. `U` computes the `inner hash state` of `p1` and the `inner hash state` of `p2`.

### -- Inside the circuit

16. To evaluate the circuit, `N` inputs `MS outer hash state` (from Step 10) and `U` inputs `inner hash state` of `p1` and `inner hash state` of `p2`. The circuit computes `p1` and `p2`. The circuit outputs xor shares of the `expanded keys` to each party.


## ---- Computing the encrypted Client_Finished

### -- Inside the circuit

17. To evaluate the circuit, the parties input their shares of the `expanded keys`. The circuit outputs data needed to encrypt and authenticate the `Client_Finished` (`CF`) message.

### -- Outside the circuit

The parties proceed to compute `verify_data` for the `CF` message. The corresponding python code is:

```python
# (handshake_hash) is a sha256 hash of all TLS handshake message up to this point
seed = str.encode('client finished') + handshake_hash
a0 = seed
a1 = hmac.new(ms, a0, hashlib.sha256).digest()
p1 = hmac.new(ms, a1+seed, hashlib.sha256).digest()
verify_data = p1[:12]
```

18. `U` computes `inner hash` of `a1` and sends it to `N`.

19. `N` (who has `MS` `outer hash state` from Step 10) computes `a1` and sends it to `U`.

20. `U` computes `inner hash` of `p1` and sends it to `N`.

21. `N` computes `p1` and gets `verify_data` and sends it to `U`.

> Note that it is safe for `N` to know `verify_data` for `CF`. 

Using the data from Step 17, `U` proceeds to encrypt and authenticate `CF` and sends it to the webserver.

## ---- Verifying the Server_Finished

Upon `U`'s receiving the encrypted `Server_Finished` (`SF`) from the webserver, the parties proceed to compute `verify_data` for `SF`, to enable `U` to check that the received `SF` is correct. The corresponding python code is:

```python
# (handshake_hash) is a sha256 hash of all TLS handshake message up to this point
seed = str.encode('server finished') + handshake_hash
a0 = seed
a1 = hmac.new(ms, a0, hashlib.sha256).digest()
p1 = hmac.new(ms, a1+seed, hashlib.sha256).digest()
verify_data = p1[:12]
```

### -- Outside the circuit

22. `U` computes `inner hash` of `a1` and sends it to `N`.

23. `N` (who has `MS` `outer hash state` from Step 10) computes `a1` and sends it to `U`.

24. `U` computes `inner hash` of `p1`.

### -- Inside the circuit

25. To evaluate the circuit, `N` inputs `MS` `outer hash state` (from Step 10) and `U` inputs `inner hash` of `p1`. The circuit outputs `verify_data` for `SF` to `U`.

The parties proceed to decrypt and authenticate the `SF` in 2PC. `U` checks that `verify_data` from `SF` matches `verify_data` from Step 25.