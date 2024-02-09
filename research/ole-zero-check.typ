#set page(paper: "a4")
#set par(justify: true)
#set text(size: 12pt)

= Zero Check for Oblivious Linear Evaluation 

In many subprotocols of TLSNotary we use OLEs to convert shares of a product into
shares of a sum. We recall the definition of the functionality:

=== Functionality $cal(F)_"OLE"$
Define the functionality $cal(F)_"OLE"$. After getting input $a$ from $P_A$ and $b$
from $P_B$ return $x$ to $P_A$ and $y$ to $P_B$ such that $y = a dot b + x$.

Problems arise in the presence of a malicious adversary, who inputs $0$ into the
protocol, because now $y = x$, which means that privacy for the honest party's
output is no longer guaranteed.

To address this shortcoming both parties can run the following protocol, which
allows an honest party to detect an input of $0$. Without loss of generality
let's assume $P_B$ is honest and wants to check if $P_A$ used a 0 input. The
protocol can be repeated with roles swapped, to also check that $P_B$ was honest. 
Note that these executions can be batched.

=== Protocol $Pi_"OLE-Zero"$
+ $P_A$ chooses some OLE input $a_k$ and $P_B$ chooses $b_k$ for $k = 1...l$.
  These are the base OLEs we want to check for 0 input of $P_A$.
+ Both parties call $cal(F)_"ROLE" -> (a_0, b_0), (x_0, y_0)$. This is needed as
  a mask later.
+ $P_A$ sets $a_(k + 1) := a_(k - l)^(-1)$ , and $P_B$ sets $b_(k + 1) := y_(k - l)$ for
  $k = l...2l$.
+ Both parties call $cal(F)_"OLE" (a_k, b_k) -> (x_k, y_k)$ for
  $k = 1...(2l + 1)$. 
+ $P_A$ computes $ s = sum_(k = 0)^l - x_k dot a_k^(-1) + sum_(k = l + 1)^(2l +
  1) - x_k$ and sends $s$ to $P_B$.
+ $P_B$ checks that $sum_(k = 0)^l y_k  = s + sum_(k = l + 1)^(2l + 1) y_k $. If
  this does not hold $P_B$ aborts.

=== Intuition

