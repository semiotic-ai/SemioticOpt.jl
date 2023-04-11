# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0


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
