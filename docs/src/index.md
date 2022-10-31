```@meta
CurrentModule = SemioticOpt
```

# SemioticOpt

This package implements optimisation algorithms for use within simulation and production.
For the most part, your workflow should look something like

```julia
julia> using SemioticOpt
julia> using LinearAlgebra
julia> f(x) = sum(x .^ 2)  # Specify function to optimise as min f(x)
julia> a = GradientDescent(;
            x=[100.0, 50.0],  # Specify parameters for optimisation
            η=1e-1,
            hooks=[StopWhen((a; kws...) -> norm(x(a) - kws[:z]) < 1e-6)],  # hook stops opt when residual is below 1e-6.
        )
julia> sol = minimize!(f, a)  # Optimise
julia> @show SemioticOpt.x(sol)  # Print out the optimal value
2-element Vector{Float64}:
 3.4163644416613304e-6
 1.6909278549636878e-6
```

!!! note
    As a rule, we recommend you use an accessor function rather than accessing struct fields directly when using this package. That will lend itself to greater stability in case we change stuff internally. As an example, prefer to use `x(a)` as compared with `a.x`, where `a` is the `GradientDescent` struct used in the example before. Similarly, for setting, prefer `x(a, v)` to `a.x = v`. Not only does this pattern aid in stability, but also in functionality such as handling setting for immutable structs.

## Installation

Make sure you've installed [Julia 1.8 or greater](https://julialang.org/).
From the Julia REPL:

```julia
julia> ]
Pkg> add https://github.com/semiotic-ai/SemioticOpt.jl
```

To specify a version, use

```julia
julia> ]
Pkg> add https://github.com/semiotic-ai/SemioticOpt.jl#v0.1.0
```
