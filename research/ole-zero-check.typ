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
allows an honest party to detect an input of $0$.

=== Protocol $Pi_"OLE-Zero"$
+ Both parties call $cal(F)_"OLE" (a_k, b_k) -> (x_k, y_k)$ for $k = 1...l$.
  These are the base OLEs, which we want to check for a 0 input. $l$ is defined
  by some outer protocol, $a_k$ is the chosen input of $P_A$, and $b_k$ is the
  chosen input of $P_B$.
+ Both parties call $cal(F)_"OLE" (a_k^(-1), y_k) -> (x_(l + k), y_(l + k))$ for
  $k = 1...l$. These are the check OLEs, which will be used to check the base
  OLEs.
+ Both parties call $cal(F)_"ROLE"$ 2-times, such that
  - $cal(F)_"ROLE" -> (a_0, b_0), (x_0, y_0)$
  - $cal(F)_"ROLE" -> (a_(2l + 1), b_(2l + 1)), (x_(2l + 1), y_(2l + 1))$
+ $P_A$ computes $R = product_(k=0)^l b_k$ and sends $R$ to $P_A$.

