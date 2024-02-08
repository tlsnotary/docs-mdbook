#set page(paper: "a4")
#set par(justify: true)
#set text(size: 12pt)
#show link: underline 


= GHASH
We want to compute GHASH MAC in 2PC which is of the form $sum_(k=1)^l H^k dot
b_k$, where $H^k, b_k in "GF"(2^128)$. $H$ is split into additive shares for
parties $P_A$ and $P_B$, such that $P_A$ knows $H_1$ and $P_B$ knows $H_2$ and
$H = H_1 + H_2$. We now need to compute additive shares of powers of $H$.


== Functionality $cal(F)_(H^l)$
On input $(H_1)$ from $P_A$ and $H_2$ from $P_B$, the functionality returns
all the  $H_(1,k)$ to $P_A$ and $H_(2,k)$ to $P_B$ for $k = 2...l$, such that 
$H_(1,k) + H_(2,k) = (H_1 + H_2)^k$.


== Protocols
The following protocols all implement the functionality $cal(F)_(H^l)$. All
protocols guarantee privacy for $H_1$ and $H_2$, i.e. there is no leakage to the
other party. All protocols are implementations with unpredictable errors, that
means correctness is *not* guaranteed in the presence of a malicious adversary
deviating from the protocol. This is tolerable in the context of TLSNotary.

We will assume that $l$, which determines the highest power $H^l$ both parties want
to compute is a compile-time constant, so that it does not complicate protocol
and performance analysis.

The following table gives an overview about the different protocols. For
computing bandwidth costs and round counts of the protocols, we ignore setup
costs of functionality $cal(F)_"ROLE"$ because it is used in every protocol
either directly or indirectly via $cal(F)_"OLE"$.

#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    inset: 10pt,
    align: horizon + center,
    [*Protocol*], [*0 Issue*], [*Rounds*], [*Bandwidth*],

    $Pi_"A2M"$,
    "yes",
    [
      Off:  0\
      On: 3\
    ],
    [
      Off:  0\
      On: 2.1 MB\
    ],

    $Pi_"ROLE + OLE"$,
    "yes",
    [
      Off:  2\
      On: 1\
    ],
    [
      Off:  2.1 MB\
      On: 128 bit\
    ],

    $Pi_"Beaver"$,
    "no",
    [
      Off: 4\
      On: 1\
    ],
    [
      Off:  4.2 MB\
      On: 128 bit\
    ],
)
]

=== A2M Protocol
This protocol converts the additive shares $H_"1/2"$ into multiplicative shares
$H_"1/2"^*$. Then both parties can locally computer higher powers
$H_(1"/"2)^k^*$. Afterwards they convert these higher powers back into additive
shares $H_("1/2", k)$.


==== Protocol $Pi_"A2M"^l$
+ $P_A$ samples a random field element $r arrow.l "GF"(2^128)$.
+ Both parties call $cal(F)_"OLE" (r, H_2) -> (x, y)$. So $P_A$ knows $(r,
  x)$ and $P_B$ knows $(H_2, y)$ and it holds that $r dot H_2 = x + y$.
+ $P_A$ defines $m = r dot H_1 + x$  and sends $m$ to $P_B$.
+ $P_A$ defines $H_1^* = r^(-1)$ and $P_B$ defines $H_2^* = m + y$.
+ Both parties locally compute $H_"1/2"^k^*$ for $k = 2...l$.
+ Both parties call $cal(F)_"OLE" (H_1^k^*, H_2^k^*) arrow.r (H_"1,k",
H_"2,k")$ for $k = 2...l$.
+ $P_A$ outputs $H_"1,k"$ and $P_B$ outputs $H_"2,k"$.


==== Performance Analysis
The protocol has no offline communication, everything takes place online with 3
rounds (steps 2, 3, 6). The bandwidth of the protocol is
$1026 dot (128 + 128^2) + 1026 * 128 + 128 approx 2.1 "MB"$.


=== ROLE + OLE Protocol
This protocol is nearly identical to the original GHASH construction from
#link("https://eprint.iacr.org/2023/964")[XYWY23]. It only addresses the leakage
of $H_(1"/"2)$ in the presence of a malicious adversary using $0$ as an input
for $cal(F)_"OLE"$. Instead of using $cal(F)_"OLE"$ for all powers $k = 1...l$,
we replace the first invocation of $cal(F)_"OLE"$ with $cal(F)_"ROLE"$ and then
only use $cal(F)_"OLE"$ for $k = 2...l$. The 0 issue is still present for higher
powers of $H$.


==== Protocol $Pi_"ROLE + OLE"^l$
+ Both parties initialize $cal(F)_"ROLE"$ and call $"Extend"_k$, l-times, so that 
  $P_A$ gets $(a_k, x_k)$ and $P_B$ gets $(b_k, y_k)$.
+ $P_A$ defines $(r_A, r_1) := (a_0, x_0)$ and $P_B$ defines
  $(r_B, r_2) := (b_0, y_0)$.
+ $P_A$ locally computes $r_A^k$ and $P_B$ locally computes $r_B^k$, for
  $k=2...l$.
+ Both parties call $cal(F)_"OLE" (r_A^k, r_B^k) arrow.r (r_(1,k), r_(2,k))$, so
  that $P_A$ gets $r_(1,k)$ and $P_B$ gets $r_(2,k)$ for $k = 2...l$.
+ $P_A$ opens $d_1 = H_1 - r_1$ and $P_B$ opens $d_2 = H_2 - r_2$, so that both
  parties know $d = d_1 + d_2 = (H_1 + H_2) - (r_1 +r_2)$.
+ Define the polynomials $f_k$ over $"GF"(2^128)$, with
  $f_k (x) := (d + x)^k = sum_(j=0)^k f_(j,k) dot x^j$. $P_A$ locally evaluates
  and outputs $H_(1,k) = f_k (r_(1,k))$ and $P_B$ locally evaluates and outputs 
  $H_(2,k) = f_k (r_(2,k))$ for $k = 1...l$.


==== Performance Analysis

- The protocol only needs 2 offline rounds (steps 2 and 5) and 1 online round
  (step 6).
- The protocol has an upload/download size of 
  - *Offline*: $1026 dot (128 + 128^2) + 1025 dot 128 approx 2.1 "MB"$
  - *Online*: $128 "bit"$


=== Beaver Protocol

==== Protocol $Pi_"Beaver"$
This protocol is nearly identical to the original GHASH construction from
#link("https://eprint.iacr.org/2023/964")[XYWY23]. It only addresses the leakage
of $H_(1"/"2)$ in the presence of a malicious adversary using $0$ as an input
for $cal(F)_"OLE"$. Instead of using $cal(F)_"OLE"$ , we sample $r = r_1 + r_2$
randomly and compute the higher powers of additive shares with
$cal(F)_"Beaver"$. This protocol does not suffer from the 0 issue.

+ Both parties sample a random field element. $P_A$ samples $r_1 arrow.l
  "GF"(2^128)$ and $P_B$ samples $r_1 arrow.l "GF"(2^128)$.
+ Both parties repeatedly call $cal(F)_"Beaver" (r_(1,k - 1), r_1, r_(2,k - 1),
  r_2) -> (r_(1, k), r_(2, k))$ for $k = 2...l$.
+ $P_A$ opens $d_1 = H_1 - r_1$ and $P_B$ opens $d_2 = H_2 - r_2$, so that both
  parties know $d = d_1 + d_2 = (H_1 + H_2) - (r_1 +r_2)$.
+ Define the polynomials $f_k$ over $"GF"(2^128)$, with
  $f_k (x) := (d + x)^k = sum_(j=0)^k f_(j,k) dot x^j$. $P_A$ locally evaluates
  and outputs $H_(1,k) = f_k (r_(1,k))$ and $P_B$ locally evaluates and outputs 
  $H_(2,k) = f_k (r_(2,k))$ for $k = 1...l$.


==== Performance Analysis

- By using free-squaring in $"GF"(2^128)$ and batching calls to $cal(F)_"Beaver"$
  the protocol needs 4 offline rounds (repeatedly step 2) and 1 online round
  (step 3).
- The protocol has an upload/download size of 
  - *Offline*: $2050 dot (128 + 128^2) approx 4.2 "MB"$
  - *Online*: $128 "bit"$




