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

"""
    swap!(v::AbstractVector{T}, support::AbstractVector{I}, f, fa) where {T<:Real,I<:Integer}

Generate the best swap in-place for `v` on `support` for objective `f` and algorithm instantiator `fa`.

`f` and `fa` are a bit tricky, so let's discuss them.
`f` is the objective function. When you define the objective function, know that we need a function of
`v` and `support` from you. This is so that we can compute the gradient with respect to `v`.
Take a look at the following example.

```julia
julia> f(x, ixs, a, b) = -((a[ixs] .* x) ./ (x[ixs] .+ b[ixs])) |> sum
julia> aa = Float64[1, 1, 1000, 1]
julia> bb = Float64[1, 1, 1, 1]
julia> f(x, ixs) = f(x, ixs, aa, bb)
```

Notice how this works.
First, we define the objective function with the extra arguments `a` and `b`.
Then, we define a new function that takes only `x` and `ixs` and calls the original function with
hardcoded values for `a` and `b`.
This is the function that we will pass to `swap!`.

Now, let's discuss `fa`.
`fa` is the algorithm instantiator.
It'll take the current `v[support]` and return an `OptAlgorithm` that can be used to minimize `f` in-place.
For example:

```julia
julia> using SemioticOpt
julia> using LinearAlgebra
julia> function makepgd(v)
            return ProjectedGradientDescent(;
                x=v,
                η=1e-1,
                hooks=[StopWhen((a; kws...) -> norm(SemioticOpt.x(a) - kws[:z]) < 1.0)],
                t=v -> σsimplex(v, 1)  # Project onto unit-simplex
            )
        end
```

Notice here that we pass in `v` to the algorithm instantiator, which then gets assigned to the field `x`.

# Example
```julia
julia> using SemioticOpt
julia> using LinearAlgebra
julia> f(x, ixs, a, b) = -((a[ixs] .* x) ./ (x[ixs] .+ b[ixs])) |> sum
julia> aa = Float64[1, 1, 1000, 1]
julia> bb = Float64[1, 1, 1, 1]
julia> f(x, ixs) = f(x, ixs, aa, bb)
julia> function makepgd(v)
            return ProjectedGradientDescent(;
            x=v,
            η=1e-1,
            hooks=[SemioticOpt.StopWhen((a; kws...) -> norm(SemioticOpt.x(a) - kws[:z]) < 1.0)],
            t=v -> SemioticOpt.σsimplex(v, 1)  # project onto unit-simplex
        )
end
julia> x = zeros(4)
julia> support = [1, 2, 3]
julia> SemioticOpt.swap!(x, support, f, makepgd)
4-element Vector{Float64}:
 0.0
 0.0
 1.0
 0.0
```
"""
function swap!(v::AbstractVector{T}, support::AbstractVector{I}, f, fa) where {T<:Real,I<:Integer}
    a = fa(v[support])
    _f = x -> f(x, support)
    sol = minimize!(_f, a)
    v[support] .= x(sol)
    return v
end
