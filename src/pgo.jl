# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export PGOOptFunction

"""
    struct PGOOptFunction{F<:Function,T<:Real,W<:AbstractVector{T},V<:AbstractVector{W}}

The function that is optimised in the inner loop of pairwise greedy optimization.

# Fields
- `f::F` is the function to be optimized. This function should be of the form `f(x, ixs, args...)`
    where `x` is the current solution vector, `ixs` is the indices of the current support vector.
- `args::V` is the arguments to `f` that are not `x` or `ixs`.

# Example
```julia
julia> using SemioticOpt
julia> f(x, ixs, args...) = sum(x[ixs] .^ 2)
julia> makepgofunc() = PGOOptFunction(f=f, args=[Float64[]])
julia> pgofunc = makepgofunc()
julia> ixs = [1, 2]
julia> x = [1.0, 2.0]
julia> _f = SemioticOpt.f(pgofunc)
julia> _args = SemioticOpt.args(pgofunc)
julia> _f(x, ixs, _args...)
5.0
julia> ixs = [1]
julia> _f(x, ixs, _args...)
1.0
```
"""
Base.@kwdef struct PGOOptFunction{
    F<:Function,
    T<:Real,
    W<:AbstractVector{T},
    V<:AbstractVector{W}
}
    f::F
    args::V
end

"""
    f(a::PGOOptFunction)

The function to be optimized in the inner loop of pairwise greedy optimization.
"""
f(a::PGOOptFunction) = a.f
"""
    args(a::PGOOptFunction)

The arguments to `f` that are not `x` or `ixs`.
"""
args(a::PGOOptFunction) = a.args
