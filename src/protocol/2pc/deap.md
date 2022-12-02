# Dual Execution with Asymmetric Privacy

## Introduction

Malicious secure 2-party computation with garbled circuits typically comes at the expense of dramatically lower efficiency compared to execution in the semi-honest model. One technique, called [Dual Execution [MF06]](https://www.iacr.org/archive/pkc2006/39580468/39580468.pdf), achieves malicious security with a minimal 2x overhead. However, it comes with the concession that a malicious adversary may learn $k$ bits of the other's input with probability $2^{-k}$.

We present a variant of Dual Execution which provides different trade-offs. Our variant ensures no leakage _for one party_, by sacrificing privacy entirely for the other. Hence the name, Dual Execution with Asymmetric Privacy (DEAP). This variant has similarities to zero-knowledge protocols, but nevertheless is distinct. In the semi-honest phase of the protocol both parties have private inputs. It is not until the last phase where one party reveals their private input that the protocol resembles the zero-knowledge setting.

Similarly to standard DualEx, our variant ensures output correctness and detects leakage (of the revealing parties input) with probability $1 - 2^{-k}$ where $k$ is the number of bits leaked.

## Preliminary

The protocol takes place between Alice and Bob who want to compute $f(x, y)$ where $x$ and $y$ are Alice and Bob's inputs respectively. The privacy of Alice's input is ensured, while Bob's input will be revealed in the final steps of the protocol.

### Premature Leakage

Firstly, our protocol assumes a small amount of premature leakage of Bob's input is tolerable. By premature, we mean prior to the phase where Bob is expected to reveal his input.

If Alice is malicious, she has the opportunity to prematurely leak $k$ bits of Bob's input with $2^{-k}$ probability of it going undetected.

### Aborts

We assume that it is acceptable for either party to cause the protocol to abort at any time, with the condition that no information of Alice's inputs are leaked from doing so.

### Committed Oblivious Transfer

In the last phase of our protocol Bob must open all oblivious transfers he sent to Alice. To achieve this, we require a very relaxed flavor of committed oblivious transfer. For more detail on these relaxations see section 2 of [Zero-Knowledge Using Garbled Circuits [JKO13]](https://eprint.iacr.org/2013/073.pdf).

### Privacy-free Garbling

Bob's inputs will be revealed in their entirety at the end of the protocol, and because of this Bob can garble his circuit using a privacy-free garbling scheme. This is quite convenient as this substantially reduces the cost of the second execution.

Our implementation uses the [Half-gate garbling scheme [ZRE15]](https://eprint.iacr.org/2014/756.pdf) which enjoys a 50% reduction in cost for both garbling and evaluating a circuit in privacy-free mode.

### Notation

* $x$ and $y$ are Alice and Bob's inputs, respectively.
* $[x]$ and $[y]$ are Alice and Bob's encoded active inputs, respectively.
* $[x]_A$ denotes an encoding of $x$ chosen by Alice
* $\mathsf{com}_x$ denotes a binding commitment to the value $x$
* $G$ denotes a garbled circuit for computing $f(x, y) = v$
* $d$ denotes output decoding information where $\mathsf{De}(d, [v]) = v$
* $\Delta$ denotes the global offset of a garbled circuit where $\forall i: [x]^{1}_i = [x]^{0}_i \oplus \Delta$
* $\mathsf{PRG}$ denotes a secure pseudo-random generator
* $\mathsf{H}$ denotes a secure hash function

### Ideal Functionality

todo..

## Protocol

The protocol can be thought of as three distinct phases: The setup phase, semi-honest phase, and the zero-knowledge phase.

### Setup

1. Alice creates a garbled circuit $G_A$ and output label commitments $\mathsf{com}_{[v]_A}$. She sends $G_A$, $[x]_A$, $d_A$ and $\mathsf{com}_{[v]_A}$ to Bob.
2. Bob creates a garbled circuit $G_B$ using privacy-free garbling and sends it to Alice.
3. For committed OT, Bob picks a seed $\rho$ and uses it to generate all random-tape for his OTs with $\mathsf{PRG}(\rho)$. Bob sends $\mathsf{com}_{\rho}$ to Alice.
4. Alice retrieves her active input labels $[x]_B$ from Bob using OT[^1].
5. Bob retrieves his active input labels $[y]_A$ from Alice using OT.

[^1]: It is necessary that Alice retrieves her active input labels $[x]_B$ before any evaluation takes place. This protects against adaptive attacks by Alice. See the [section below](#malicious-alice) for more detail.

### Semi-honest

6. Bob evaluates $G_A$ using $[x]_A$ and $[y]_A$ to acquire $[v]_A$. He checks $[v]_A$ against the commitment $\mathsf{com}_{[v]_A}$ which Alice sent earlier, aborting if it is invalid.
7. Bob sends $[v]_A$ to Alice.
8. Bob decodes $[v]_A$ to $v^A$ using $d_A$ which he received earlier. He computes $\mathsf{H}([v^A]_B)$ which we'll call $\mathsf{check}_B$, and stores it for the equality check later.
9. Alice checks that $[v]_A$ is authentic, aborting if not, then decodes it to acquire $v$.

Bob, even if malicious, has learned nothing except the purported output $v^A$ and is not convinced it is correct. In the next phase Alice will attempt to convince Bob that it is.

Alice, if honest, has learned the correct output $v$ thanks to the authenticity property of garbled circuits. Alice, if malicious, has potentially learned Bob's entire input $y$.

### ZK

10.  Bob reveals his input by sending both $y$ and $[y]_B$ to Alice.
11.  Alice evaluates $G_B$ using $[x]_B$ and $[y]_B$ to acquire $[v]_B$. She computes $\mathsf{H}([v]_B)$ which we will call $\mathsf{check}_A$.
12.  Alice computes a commitment $\mathsf{Com}(\mathsf{check}_A, r) = \mathsf{com}_{\mathsf{check}_A}$ where $r$ is a key only known to Alice. She sends this commitment to Bob.
13.  Bob receives $\mathsf{com}_{\mathsf{check}_A}$ and stores it for the equality check later.
14.  Bob opens his garbled circuit and OT by sending $\Delta_B$ and $\rho$ to Alice.
15.  Alice, now knowing all inputs and $\Delta_B$, derives the full input labels of $G_B$.
16.  Alice opens all of Bob's OTs for $[x]_B$ and verifies that they were performed honestly. Otherwise she aborts.
17.  Alice verifies that $G_B$ was garbled honestly. Otherwise she aborts.
18.  Alice now opens $\mathsf{com}_{\mathsf{check}_A}$ by sending $\mathsf{check}_A$ and $r$ to Bob.
19. Bob verifies $\mathsf{com}_{\mathsf{check}_A}$ then asserts $\mathsf{check}_A == \mathsf{check}_B$, aborting otherwise.

Bob is now convinced that $v^A$ is correct, ie $f(x, y) = v^A$. Bob is also assured that Alice only learned up to k bits of his input prior to revealing, with a probability of $2^{-k}$ of it being undetected.

## Analysis

### Malicious Alice

[On the Leakage of Corrupted Garbled Circuits [DPB18]](https://eprint.iacr.org/2018/743.pdf) is recommended reading on this topic.

During the semi-honest phase, Alice has some degrees of freedom in how she garbles $G_A$. According to [DPB18], when using a modern garbling scheme such as [ZRE15], these corruptions boil down to two classes: detectable and undetectable.

Recall that our scheme assumes Bob's input is an ephemeral secret which can be revealed in the final stage. For this reason, we are entirely unconcerned about the detectable variety. Simply providing Bob with the output label commitments $\mathsf{com}_{[v]_A}$ is sufficient to detect many different types of corruptions. In this context, our primary concern is regarding the _correctness_ of the output of $G_A$.

[DPB18] shows that any undetectable corruption made to $G_A$ is constrained to the arbitrary insertion of NOT gates into the circuit, such that $G_A$ computes $f_A$ instead of $f$. Note that any corruption of $d_A$ has an equivalent effect. [DPB18] also shows that Alice's ability to exploit this is constrained by the topology of the circuit.

Recall that in the final stage of our protocol Bob checks that the output of $G_A$ matches the output of $G_B$, or more specifically:

$$f_A(x_1, y_1) == f_B(x_2, y_2)$$

For the moment we'll assume Bob garbles honestly and provides the same inputs for both evaluations.

$$f_A(x_1, y) == f(x_2, y)$$

In the scenario where Bob reveals the output of $f_A(x_1, y)$ prior to Alice committing to $x_2$ there is a trivial _adaptive attack_ available to Alice. As an extreme example, assume Alice could choose $f_A$ such that $f_A(x_1, y) = y$. For most practical functions this is not possible to garble without detection, but for the sake of illustration we humor the possibility. In this case she could simply compute $x_2$ where $f(x_2, y) = y$ in order to pass the equality check.

To address this, Alice is forced to choose $f_A$, $x_1$ and $x_2$ prior to Bob revealing the output. In this case it is obvious that any _valid_ combination of $(f_A, x_1, x_2)$ must satisfy all constraints on $y$. Thus, for any non-trivial $f$, choosing a valid combination would be equivalent to guessing $y$ correctly. In which case, any attack would be detected by the equality check with probability $1 - 2^{-k}$ where k is the number of guessed bits of $y$. This result is acceptable within our model as [explained earlier](#premature-leakage).

### Malicious Bob

[Zero-Knowledge Using Garbled Circuits [JKO13]](https://eprint.iacr.org/2013/073.pdf) is recommended reading on this topic.

The last stage of our variant is functionally equivalent to the protocol described in [JKO13]. After Alice evaluates $G_B$ and commits to $[v]_B$, Bob opens his garbled circuit and all OTs entirely. Following this, Alice performs a series of consistency checks to detect any malicious behavior. These consistency checks do _not_ depend on any of Alice's inputs, so any attempted selective failure attack by Bob would be futile.

Bob's only options are to behave honestly, or cause Alice to abort without leaking any information.

### Malicious Alice & Bob

They deserve whatever they get.