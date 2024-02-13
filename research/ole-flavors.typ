#set page(paper: "a4")
#set par(justify: true)
#set text(size: 12pt)

= Oblivious Linear Evaluation (OLE) flavors from random OT 
Here we sum up different OLE flavors, where some of them are needed for
subprotocols of TLSNotary. All mentioned OLE protocol flavors are
implementations with errors, i.e. in the presence of a malicious adversary, he
can introduce additive errors to the result. This means correctness is not
guaranteed, but privacy is.

== Functionality $cal(F)_"ROT"$
*Note*: In the literature there are different flavors of random OT, depending on
if the receiver can choose his input or not. Here we that assume the receiver
has a choice.

Define the functionality $cal(F)_"ROT"$:
- The sender $P_A$ receives the random tuple $(t_0, t_1)$, where $t_0, t_1$ are
  $kappa$-bit messages.
- The receiver $P_B$ inputs a bit $x$ and receives the corresponding $t_x$.

== Random OLE
=== Functionality $cal(F)_"ROLE"$
Define the functionality $cal(F)_"ROLE"$ which maintains a counter $k$ and
which allows to call an $"Extend"_k$ command multiple times.
- When calling $"Initialize"$ set up the functionality for subsequent calls to
  $"Extend"_k$.
- When calling $"Extend"_k$: $P_A$ receives $(a_k, x_k)$ and $P_B$ receives
  $(b_k, y_k)$.

such that $ y_k = a_k dot b_k + x_k$

=== Protocol $Pi_"ROLE"$
+ Initialization:
  - $P_B$ randomly samples $f arrow.l bb(F)$.
  - Both parties call $cal(F)_"ROT" (f)$, so $P_A$ knows
    $t_0^i, t_1^i$ and $P_B$ knows $t_(f_i)$.
  - With some PRF define: $s_(i,0)^k := "PRF"(t^i_0, k)$, $s_(i,1)^k :=
    "PRF"(t^i_1, k)$
  
+ $"Extend"_k$: This can be batched or/and repeated several times.
  - $P_A$ samples randomly $c_k arrow.l bb(F)$ and $e_k arrow.l bb(F)$
  - $P_B$ samples randomly $d_k arrow.l bb(F)$.
  - $P_A$ sends $e_k$ and $u_i^k = s_(i,0)^k - s_(i,1)^k + c_k$ to $P_B$.
  - $P_B$ defines $b_k = e_k + f$ and sends $d_k$ to $P_A$.
  - $P_A$ defines $a_k = c_k + d_k$ and outputs
    $x_k = sum 2^i s_(i,0)^k - a_k dot e_k$
  - $P_B$ computes $ y^k_i 
    &= f_i (u^k_i + d_k) + s_(i,f_i)^k \
    &= f_i (s_(i,0)^k - s_(i,1)^k + c_k + d_k) + s_(i,f_i)^k \
    &= f_i dot a_k + s_(i,0)^k $
    and outputs $y_k = 2^i y^k_i$

+ Now it holds that $y_k = a_k dot b_k + x_k$.
#pagebreak()

== Vector OLE
=== Functionality $cal(F)_"VOLE"$
Define the functionality $cal(F)_"VOLE"$ which maintains a counter $k$ and
which allows to call an $"Extend"_k$ command multiple times.
- When calling $"Initialize"$, $P_B$ inputs a field element $b$. This sets up the
  functionality for subsequent calls to $"Extend"_k$.
- When calling $"Extend"_k$: $P_A$ receives $(a_k, x_k)$ and $P_B$ receives
  $y_k$.

such that $ y_k = a_k dot b + x_k$

=== Protocol $Pi_"VOLE"$
*Note*: This is the $Pi_"COPEe"$ construction from KOS16.
+ Initialization:
  - $P_B$ chooses some field element $b$.
  - Both parties call $cal(F)_"ROT" (b)$, so $P_A$ knows
    $t_0^i, t_1^i$ and $P_B$ knows $t_(b_i)$.
  - With some PRF define: $s_(i,0)^k := "PRF"(t^i_0, k)$, $s_(i,1)^k :=
    "PRF"(t^i_1, k)$
  
+ $"Extend"_k$: This can be batched or/and repeated several times.
  - $P_A$ chooses some field element $a_k$ and sends
    $u_i^k = s_(i,0)^k - s_(i,1)^k + a_k$ to $P_B$.
  - $P_A$ outputs $x_k = sum 2^i s_(i,0)^k$
  - $P_B$ computes $ y^k_i 
    &= b_i dot u^k_i + s_(i,f_i)^k \
    &= b_i (s_(i,0)^k - s_(i,1)^k + a_k) + s_(i,f_i)^k \
    &= b_i dot a_k + s_(i,0)^k $
    and outputs $y_k = 2^i y^k_i$

+ Now it holds that $y_k = a_k dot b + x_k$.


== Random Vector OLE
=== Functionality $cal(F)_"RVOLE"$
Define the functionality $cal(F)_"RVOLE"$ which maintains a counter $k$ and
which allows to call an $"Extend"_k$ command multiple times.
- When calling $"Initialize"$, $P_B$ receives a field element $b$. This sets up
  the functionality for subsequent calls to $"Extend"_k$.
- When calling $"Extend"_k$: $P_A$ receives $(a_k, x_k)$ and $P_B$ receives
  $y_k$.

such that $ y_k = a_k dot b + x_k$

=== Protocol $Pi_"RVOLE"$
+ Initialization:
  - $P_B$ chooses some field element $f$.
  - Both parties call $cal(F)_"ROT" (f)$, so $P_A$ knows
    $t_0^i, t_1^i$ and $P_B$ knows $t_(f_i)$.
  - $P_A$ sends $e$ to $P_B$ and $P_B$ defines $b = e + f$.
  - With some PRF define: $s_(i,0)^k := "PRF"(t^i_0, k)$, $s_(i,1)^k :=
    "PRF"(t^i_1, k)$
  
+ $"Extend"_k$: This can be batched or/and repeated several times.
  - $P_A$ samples randomly $c_k arrow.l bb(F)$ and
    $P_B$ samples randomly $d_k arrow.l bb(F)$.
  - $P_A$ sends $u_i^k = s_(i,0)^k - s_(i,1)^k + c_k$ to $P_B$. 
  - $P_B$ sends $d_k$ to $P_A$.
  - $P_A$ defines $a_k = c_k + d_k$ and outputs
    $x_k = sum 2^i s_(i,0)^k - a_k dot e$
  - $P_B$ computes $ y^k_i 
    &= f_i (u^k_i + d_k) + s_(i,f_i)^k \
    &= f_i (s_(i,0)^k - s_(i,1)^k + c_k + d_k) + s_(i,f_i)^k \
    &= f_i dot a_k + s_(i,0)^k $
    and outputs $y_k = 2^i y^k_i$

+ Now it holds that $y_k = a_k dot b + x_k$.


== OLE from random OLE
=== Functionality $cal(F)_"OLE"$
Define the functionality $cal(F)_"OLE"$. After getting input $a$ from $P_A$ and $b$
from $P_B$ return $x$ to $P_A$ and $y$ to $P_B$ such that $x + y = a dot b$.

=== Protocol $Pi_"OLE"$
Both parties have access to a functionality $cal(F)_"ROLE"$, and call
$"Extend"_k$, so $P_A$ receives $(a'_k, x'_k)$ and $P_B$ receives $(b'_k, y'_k)$.
Then they perform the following derandomization:
- $P_A$ sends $u_k = a_k + a'_k$ to $P_B$.
- $P_B$ sends $v_k = b_k + b'_k$ to $P_A$.
- $P_A$ outputs $x_k = x'_k + a'_k dot v_k$.
- $P_B$ outputs $y_k = y'_k + b_k dot u_k$.

Now it holds that $ y_k - x_k
&= (y'_k + b_k dot u_k) - (x'_k + a'_k dot v_k) \
&= (y'_k + b_k dot (a_k + a'_k)) - (x'_k + a'_k dot (b_k + b'_k)) \
&= a_k dot b_k
$
