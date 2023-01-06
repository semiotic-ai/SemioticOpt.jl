# Algorithms

This section will introduce you to the basic workflow that you'll use to optimise functions,
as well as the algorithms we've implemented.

Generally speaking, there are two parts to optimising.
The first is to specify the function you want to optimise.
Say,

```julia
julia> f(x) = sum(x .^ 2)
```

Then, you want to create a [Hook](@ref hooks) with the [`SemioticOpt.IsStoppingCondition`](@ref) trait.
Else, optimisation will get stuck in an infinite loop.

```julia
julia> using LinearAlgebra
julia> h = StopWhen((a; locals...) -> norm(x(a) - locals[:z]) < 1e-6)  # Stop when the residual is less than the tolerance
```

Then, you want to choose the algorithm you want to use for minimisation and specify its parameters.

```julia
julia> a = GradientDescent(; x=[100.0, 50.0], η=1e-1, hooks=[h,])  # Specify parameters for optimisation
```

Finally, you'll run `minimize!` or `minimize`.

```julia
julia> sol = minimize!(f, a)  # Optimise
```

```@docs
SemioticOpt.minimize!
SemioticOpt.minimize
```

`sol` here is a struct containing various metadata.
If you only care about the optimal value of `x`, then grab it using

```julia
julia> SemioticOpt.x(sol)
```

## Gradient Descent

From [Wikipedia](https://en.wikipedia.org/wiki/Gradient_descent):

> [Gradient Descent]... is a first-order iterative optimization algorithm for finding a local minimum of a differentiable function. The idea is to take repeated steps in the opposite direction of the gradient (or approximate gradient) of the function at the current point, because this is the direction of steepest descent. 

If the function we're optimising `f` is convex, then a local minimum is also a global minimum.
The update rule for gradient descent is ``x_{n+1}=x_n - η∇f(x_n)``.

```@docs
SemioticOpt.GradientDescent
```

### A Quick Interlude: Choosing Step Size

If your function is L-Lipschitz and the optimal point``f^* > -\infty``, then
``\eta < 2 / L`` will converge to the optimal point.
Note that ``\eta`` is the step size.
See [Theorem 4.2](http://users.ece.utexas.edu/~cmcaram/EE381V_2012F/Lecture_4_Scribe_Notes.final.pdf)
for details.
So that you don't have to remember this relationship, just know that if you can tell us
the Lipschitz constant of the function you're trying to minimise, we'll tell you what the
step size is. 

```@docs
SemioticOpt.stepsize
```

## Projected Gradient Descent

Projected Gradient Descent is a more general gradient descent in a sense.
Whereas gradient descent itself has no constraint, projected gradient descent allows
for you to specify a constraint.
In particular, here, we are interested in solving the problem of ``\min_x f(x)`` subject to
some constraints.
Those constraints define the feasible region ``\mathcal{C}``.
Thus, the full problem we're trying to solve is ``\min_x f(x) \textrm{subject to } x\in\mathcal{C}``.
Once we do the standard gradient descent step, here we project the result onto the feasible set.
In other words, 

```math
\begin{align*}
    y_{n} &= x_n - η∇f(x_n) \\
    x_{n+1} &= \textrm{Pr}(y_n)_\mathcal{C}
\end{align*}
```

To use PGD, you'll need to specify `t`, the projection function.
Any projection function must take only `x` as input.
To get more complex behaviour, you may find it useful to leverage currying (partial function application).

Let's look at an example of this.
Say we want to minimise ``f(x)=\sum x^2`` subject to a unit simplex constraint.
We provide a function [`SemioticOpt.σsimplex`](@ref).
However, this function doesn't only take `x` as input, but also takes `σ`.
In order to create a projection function in terms of only `x`, we will apply currying by creating
a new function.

```julia
julia> using SemioticOpt
julia> unitsimplex(x) = σsimplex(x, 1)
```

Now, we can create a PGD parameters struct and solve our problem.

```julia
julia> using LinearAlgebra
julia> f(x) = sum(x.^2)
julia> a = ProjectedGradientDescent(;
            x=[100.0, 50.0],
            η=1e-1,
            hooks=[StopWhen((a; kws...) -> norm(x(a) - kws[:z]) < 1e-6)],
            t=unitsimplex,
        )
julia> aopt = minimize(f, a)
julia> SemioticOpt.x(aopt)
2-element Vector{Float64}:
 0.5000023384026198
 0.49999766159738035
```

```@docs
SemioticOpt.ProjectedGradientDescent
```

### Predefined Projection Functions

```@docs
SemioticOpt.σsimplex
SemioticOpt.gssp
```

## Halpern Iteration

[Halpern iteration](https://projecteuclid.org/journals/bulletin-of-the-american-mathematical-society/volume-73/issue-6/Fixed-points-of-nonexpanding-maps/bams/1183529119.pdf)
is a method of anchoring an iterative optimisation algorithm to some anchor point ``x_0``.
The general form of the algorithm is given by

```math
x_{k+1} = \lambda_{k+1}x_0 + (1 - \lambda_{k+1})T(x_k)
```

Here, ``T: \mathbb{R}^d \to \mathbb{R}^d`` is a non-expansive map
(i.e., ``\forall x,y \in \mathbb{R}^d: ||T(x) - T(y)|| \leq ||x - y||``).
``\lambda_k`` is a step size that must be chosen such that it satisfies the properties.

```math
\begin{align*}
    \lim_{k\to\infty} \lambda_k &= 0 \\
    \sum_{k=1}^\infty \lambda_k &= \infty \\
    \sum_{k=1}^\infty |\lambda_{k+1} - \lambda_k| &< \infty \\
\end{align*}
```

A reasonable first guess for ``\lambda_k`` might be ``\frac{1}{k}`` if you're unsure about
what to pick.

!!! note
    In the formula for Halpern Iteration, we actually use ``k+1``. In our code, you should still define ``\lambda_k`` as we'll add the one for you.

This is an implicitly regularised method.
If you use an algorithm like gradient descent with Halpern Iteration, you'll converge to
the solution with the minimum ``\ell2`` distance from `x₀`.

Implementation-wise, we've actually defined Halpern Iteration using a [Hook](@ref hooks)
that exhibits the [`SemioticOpt.RunAfterIteration`](@ref) trait.
To use this, you'll want to add this hook to an existing algorithm.
For example,

```julia
julia> using LinearAlgebra
julia> f(x) = sum(x.^2)
julia> a = GradientDescent(;
            x=[100.0, 50.0],
            η=1e-1,
            hooks=[
                StopWhen((a; kws...) -> norm(x(a) - kws[:z]) < 1e-6),
                HalpernIteration(; x₀=[10, 10], λ=k -> 1 / k),
            ],
        )
julia> o = minimize!(f, a)
julia> x(o)
2-element Vector{Float64}:
 0.005945303210463734
 0.005945303210463734
```

```@docs
SemioticOpt.HalpernIteration
```
