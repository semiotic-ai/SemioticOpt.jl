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

"""
    possiblesupports(kmax::Integer, ixs::AbstractVector{<:Integer}, n::Integer)

Compute the possible supports for this iteration of the outer loop of pgo.

Here, `kmax` is the maximum support size, `ixs` is the current support, and `n` is length
of the solution vector.

# Example
```julia
julia> using SemioticOpt
julia> ixs = 1:3 |> collect
julia> n = 4
julia> isfull = true
julia> kmax = 3
julia> out = SemioticOpt.possiblesupports(kmax, ixs, n)
3×3 Matrix{Int32}:
 2  1  1
 3  3  2
 4  4  4
```
"""
function possiblesupports(kmax::Integer, ixs::AbstractVector{<:Integer}, n::Integer)
    k = length(ixs)
    return possiblesupports(Val(k == kmax), k, ixs, n)
end
"""
    possiblesupports(::Val{false}, k::Integer, ixs::AbstractVector{<:Integer}, n::Integer)

Compute the possible supports for this iteration of the outer loop of pgo.

Here, `k` is the current support size, `ixs` is the current support, and `n` is length
of the solution vector.

This method runs when the support is not full.

# Example
```julia
julia> using SemioticOpt
julia> ixs = 1:2 |> collect
julia> n = 4
julia> isfull = false
julia> k = length(ixs)
julia> out = SemioticOpt.possiblesupports(Val(isfull), k, ixs, n)
3×2 Matrix{Int32}:
 1  1
 2  2
 3  4
```
"""
function possiblesupports(::Val{false}, k::Integer, ixs::AbstractVector{<:Integer}, n::Integer)
    nr = k + 1
    nc = n - k
    s = Matrix{Int32}(undef, nc, nr)  # column-major but backwards, so will transpose
    @inbounds s[:, 1:k] .= ixs'
    @inbounds s[:, k+1] .= setdiff(1:n, ixs)
    return s'
end
"""
    possiblesupports(::Val{true}, ixs::AbstractVector{<:Integer}, n::Integer)

Return the possible supports for this iteration of the outer loop of pgo.

Here, `k` is the current support size, `ixs` is the current support, and `n` is length
of the solution vector.

This method runs when the support is full.

# Example
```julia
julia> using SemioticOpt
julia> ixs = 1:2 |> collect
julia> n = 4
julia> isfull = true
julia> k = length(ixs)
julia> out = SemioticOpt.possiblesupports(Val(isfull), k, ixs, n)
2×4 Matrix{Int32}:
 2  2  1  1
 3  4  3  4
```
"""
function possiblesupports(::Val{true}, k::Integer, ixs::AbstractVector{<:Integer}, n::Integer)
    nr = k
    nc = k * (n - k)
    s = Matrix{Int32}(undef, nc, nr)  # column major, but backwards, so will transpose
    @inbounds s[:, 1:(k-1)] .= repeat(repeatwithoutdiag(ixs)'; inner=(Int32(nc / k), 1))
    @inbounds s[:, k] .= repeat(setdiff(1:n, ixs), k)
    return s'
end
