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
+ $P_B$ checks that $sum_(k = 0)^l b_k  = s + sum_(k = l + 1)^(2l + 1) y_k $. If
  this does not hold $P_B$ aborts.

=== Intuition
+ We notice that a linear function has an inverse: $ y(x) &= m x + n \
  y^(-1)(x) &= 1/m x - 1/m n $ such that $y^(-1)(y(x)) = x$. So if we have some
  value $x_0$ and plug it in into $y(x)$ we get $y(x_0) = y_0$. Then the inverse
  function gives us back $y^(-1)(y_0) = x_0$.
+ Having a function $y(x) = n$, is a constant function. This function does not
  have an inverse, because we cannot solve for $x$. So there is no way to get
  back from $y_0 arrow.r x_0$. But this is the exact thing what happens when
  some of the parties $P_(A"/"B)$ inputs 0 into the OLE. Maybe we can exploit
  this to construct some check.
+ To have an easy example, we now look at a single OLE, but it also works for an
  arbitrary number. So we want to come up with a check for a single
  $cal(F)_"OLE" (a_0, b_0) -> (x_0, y_0)$. We assume now $P_B$ wants to check if $P_A$
  did input $a_0 = 0$ into this OLE. So $P_A$ inputs $a_0$ and gets $x_0$, and $P_B$
  inputs $b_0$ and gets $y_0$, such that $y_0 = a_0 b_0 + x_0$. Notice, how we have the
  analogy to the linear function. We now have $y(b)$, $P_A$ being the function
  provider, defining the function with slope $a_0$ and offset $x_0$. $P_B$ is the
  evaluator, plugging in $b_0$ into $y(b)$ and getting $y_0$.
+ $P_A$ now has to pass a check. He is required to invert the function, which
  gives him $ y^(-1) (b) = 1/a b - 1/a x $
  Now the problem is that when trying to do an OLE with this inverse function 
  $P_A$ can only invert the slope $a_1$ but not the offset $x_1$ since this is
  the output of the OLE for him. But what he can do is calculate the difference
  and send this as a correction to $P_B$. $P_B$ will input his output from the
  OLE before and expect to get his original input (including a correction term),
  since they call the inverse function.

  So both parties will now call the inverse OLE. $P_A$ will input
  $a_1 = a_0^(-1)$ and $P_B$ will input $b_1 = y_0$, such that
  $ cal(F)_"OLE" (a_1, b_1) arrow.r (x_1, y_1) =
  cal(F)_"OLE" (a_0^(-1), y_0) arrow.r (x_1, y_1)$. So the equation will be
  $ y_1 = 1/a_0 y_0 + x_1 $ Using that $y_0 = a_0 b_0 + x_0$, we get
  $ y_1 = b_0 + x_0 / a_0 + x_1 $
  In other words $P_B$ will get $y_1$ as an output. $P_A$ will send him the
  correction term $s = -x_0/a_0 - x_1$ and $P_B$ will check that $y_1 + s =
  b_0$.
+ The last thing we have to make sure is that $P_B$ cannot abuse this check
  to get some information about the inputs and outputs of $P_A$. For example,
  when $P_B$ plugs in a $b_1 eq.not y_0$ he would learn another point on the
  inverse function, not belonging to the original point. He can easily do the
  math and arrive at
  $
    x_0 &= (b_0 b_1 -y_0 (y_1 + s)) / (b_0 - y_1 - s) \ 
    a_0 &= (y_0 - x_0) / b_0 \
    a_1 &= 1 / a_0 \
    x_1 &= - x_0 / a_0 - s
  $

  Since $P_B$ knows $y_0, y_1, b_0, b_1, s$ this would totally leak the inputs
  and outputs of $P_A$.
+ We address this by introducing a ROLE which works as a mask for the correction
  term. $P_A$ and $P_B$ call $cal(F)_"ROLE" arrow.r (a_2, x_2), (b_2, y_2)$ and
  then the inverse OLE for this ROLE (note this has to be an OLE because it is
  chosen input) $ cal(F)_"OLE" (a_3, b_3) arrow.r (x_3, y_3) = cal(F)_"OLE"
  (a_2^(-1), y_2) arrow.r (x_3, y_3)$. Then instead of sending $s = -x_0 / a_0 -
  x_1$, $P_A$ will send $s = -x_0 / a_0 - x_1 -x_2 / a_2 - x_3$ and $P_B$ will
  check that $y_1 + y_3 + s = b_0 + b_2$. Note that a single ROLE is enough to
  mask the correction term for an arbitrary amount of OLEs, not just 1 like in
  this example.



