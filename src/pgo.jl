# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export PairwiseGreedyOpt, x, x!

"""
    PairwiseGreedyOpt(; kmax::I, x::V, xinit::V, f::F, a::A, hooks::S) where {
        I<:Integer,
        T<:Real,
        V<:AbstractVector{T},
        S<:AbstractVecOrTuple{<:Hook},
        F<:Function,
        A<:Function,
    }

Parameters for the pairwise greedy optimization algorithm.

# Fields
- `kmax::I`: The maximum support size.
- `x::V`: The current best guess for the solution.
- `xinit::V`: The initial solution vector.
- `f::F`: The objective function of the inner loop.
    This could be, for instance, a convex relaxation of the problem.
- `a::A`: A function that takes a vector and returns an instance of [`SemioticOpt.OptAlgorithm`](@ref).
    This is the algorithm that will be used to optimize the objective function `f`.
- `hooks::S`: A tuple of [`SemioticOpt.Hook`](@ref)s that will be called at various points in the algorithm.


`f` and `a` are a bit tricky, so let's discuss them.
`f` is the objective function. When you define the objective function, know that we need a function of
`x` and `ixs` (a vector of indices) from you. This is so that we can compute the gradient with
respect to `x`.
Take a look at the following example.

```julia
julia> f(x, ixs, a, b) = -((a[ixs] .* x) ./ (x .+ b[ixs])) |> sum
julia> aa = Float64[1, 1, 1000, 1]
julia> bb = Float64[1, 1, 1, 1]
julia> f(x, ixs) = f(x, ixs, aa, bb)
```

Notice how this works.
First, we define the objective function with the extra arguments `a` and `b`.
Then, we define a new function that takes only `x` and `ixs` and calls the original function with
hardcoded values for `a` and `b`.
Importantly, notice that we don't select only `ixs` from `x` in our definition of `f`.
This is because `SemioticOpt` will do that for us.

Now, let's discuss `a`.
`a` is the algorithm instantiator.
It'll take the current `x[ixs]` and return an `OptAlgorithm` that can be used to minimize `f` in-place.
For example:

```julia
julia> using SemioticOpt
julia> using LinearAlgebra
julia> function makepgd(x)
            return ProjectedGradientDescent(;
                x=x,
                η=1e-1,
                hooks=[StopWhen((a; kws...) -> norm(SemioticOpt.x(a) - kws[:z]) < 1.0)],
                t=x -> σsimplex(x, 1)  # Project onto unit-simplex
            )
        end
```

Notice here that we pass in `x` to the algorithm instantiator, which then gets assigned to the field `x`.

Let's also talk `hooks`.
In general, PGO utilises two stopping hooks, so you must provide these.

```julia
julia> using SemioticOpt
julia> hooks=[
    StopWhen((a; kws...) -> kws[:f](kws[:z]) ≥ kws[:f](SemioticOpt.x(a)))
    StopWhen(
        (a; kws...) -> length(kws[:z]) == length(SemioticOpt.nonzeroixs(kws[:z]))
    )
],
```

The first of these stops when the next iteration decreases the value of the objective
function.
The second stops when the support size is the length of the vector, meaning that there
are no more swaps we could make.

# Example

```julia
julia> using SemioticOpt
julia> f(x, ixs, a, b) = -((a[ixs] .* x) ./ (x .+ b[ixs])) |> sum
julia> aa = Float64[1, 1, 1000, 1]
julia> bb = Float64[1, 1, 1, 1]
julia> f(x, ixs) = f(x, ixs, aa, bb)
julia> function makepgd(v)
           return ProjectedGradientDescent(;
               x=v,
               η=1e-1,
               hooks=[StopWhen((a; kws...) -> norm(SemioticOpt.x(a) - kws[:z]) < 1.0)],
               t=v -> σsimplex(v, 1)  # Project onto unit-simplex
           )
       end
julia> alg = PairwiseGreedyOpt(;
           kmax=4,
           x=zeros(4),
           xinit=zeros(4),
           f=f,
           a=makepgd,
           hooks=[
               StopWhen((a; kws...) -> kws[:f](kws[:z]) ≥ kws[:f](SemioticOpt.x(a))),
               StopWhen(
                   (a; kws...) -> length(kws[:z]) == length(SemioticOpt.nonzeroixs(kws[:z]))
               )
           ]
       )
PairwiseGreedyOpt{Int64, Float64, Vector{Float64}, Vector{StopWhen}, typeof(f), typeof(makepgd)}(4, [0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0], f, makepgd, StopWhen[StopWhen(var"#7#11"()), StopWhen(var"#9#12"())])
```
"""
Base.@kwdef struct PairwiseGreedyOpt{
    I<:Integer,
    T<:Real,
    V<:AbstractVector{T},
    S<:AbstractVecOrTuple{<:Hook},
    F<:Function,
    A<:Function,
} <: OptAlgorithm
    kmax::I
    x::V
    xinit::V
    f::F
    a::A
    hooks::S
end

"""
    x(g::PairwiseGreedyOpt)
    x(g::PairwiseGreedyOpt, v)

The current best guess for the solution. If using the setter, `v` is the new value.

The setter is not in-place.
See [`SemioticOpt.x!`](@ref).
"""
x(g::PairwiseGreedyOpt) = g.x
x(g::PairwiseGreedyOpt, v) = @set g.x = v
"""
    x!(g::PairwiseGreedyOpt, v)

In-place setting of `g.x` to `v`

See [`SemioticOpt.x`](@ref).
"""
function x!(g::PairwiseGreedyOpt, v)
    g.x .= v
    return g
end
"""
    kmax(g::PairwiseGreedyOpt)

The maximum support size.
"""
kmax(g::PairwiseGreedyOpt) = g.kmax
"""
    f(g::PairwiseGreedyOpt)

The objective function of the inner loop.
"""
f(g::PairwiseGreedyOpt) = g.f
"""
    a(g::PairwiseGreedyOpt)

The algorithm instantiator for the inner loop.
"""
a(g::PairwiseGreedyOpt) = g.a
"""
    xinit(g::PairwiseGreedyOpt)

The initial solution vector.
"""
xinit(g::PairwiseGreedyOpt) = g.xinit
"""
    hooks(g::PairwiseGreedyOpt)

The hooks used by the algorithm.
"""
hooks(g::PairwiseGreedyOpt) = g.hooks

"""
    currentsupport(v::AbstractVector{T}, kmax::Integer) where {T<:Real}

Return the current support of `v` with maximum support size `kmax`.

# Example
```julia
julia> using SemioticOpt
julia> kmax = 4
julia> x = [0.4, 0.0, 0.3, 0.0]
julia> out = SemioticOpt.currentsupport(x, kmax)
2-element view(::Vector{Int64}, 1:2) with eltype Int64:
 1
 3
julia> x = [0.0, 0.0, 0.0, 0.0]
julia> out = SemioticOpt.currentsupport(x, kmax)
0-element view(::Vector{Int64}, 1:0) with eltype Int64
```
"""
function currentsupport(v::AbstractVector{T}, kmax::Integer) where {T<:Real}
    nnz = v |> nonzeroixs |> length
    _k = min(kmax, nnz)
    return klargestixs(v, _k)
end

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

In the case where `n == k`, this method will return a an `n` by `1` matrix whose
elements are just `ixs`.

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
    if nc > 0
        s = Matrix{Int32}(undef, nc, nr)  # column major, but backwards, so will transpose
        @inbounds s[:, 1:(k-1)] .= repeat(repeatwithoutdiag(ixs)'; inner=(Int32(nc / k), 1))
        @inbounds s[:, k] .= repeat(setdiff(1:n, ixs), k)
    else
        s = reshape(ixs, 1, n)
    end
    return s'
end

"""
    swap!(v::AbstractVector{T}, support::AbstractVector{I}, f, fa) where {T<:Real,I<:Integer}

Generate the best swap in-place for `v` on `support` for objective `f` and algorithm instantiator `fa`.

# Example
```julia
julia> using SemioticOpt
julia> using LinearAlgebra
julia> f(x, ixs, a, b) = -((a[ixs] .* x) ./ (x .+ b[ixs])) |> sum
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

"""
    bestswap(xinit::AbstractVector{T}, supports::AbstractMatrix{<:Integer}, selection, f, fa) where {T<:Real}

Compute the best swap from `xinit` on s ∈ `supports` for objective `f` and algorithm instantiator `fa`.

# Example
```julia
julia> using SemioticOpt
julia> using LinearAlgebra
julia> f(x, ixs, a, b) = -((a[ixs] .* x) ./ (x .+ b[ixs])) |> sum
julia> aa = Float64[1, 1, 1000, 1]
julia> bb = Float64[1, 1, 1, 1]
julia> f(x, ixs) = f(x, ixs, aa, bb)
julia> c = 0.1  # per non-zero cost
julia> selection = x -> f(x, 1:length(x)) + c * length(SemioticOpt.nonzeroixs(x))
julia> function makepgd(v)
           return ProjectedGradientDescent(;
               x=v,
               η=1e-1,
               hooks=[StopWhen((a; kws...) -> norm(SemioticOpt.x(a) - kws[:z]) < 1.0)],
               t=v -> σsimplex(v, 1)  # Project onto unit-simplex
           )
       end
julia> supports = [[1 3]; [2 2]]
julia> xinit = zeros(4)
julia> v, o = SemioticOpt.bestswap(xinit, supports, selection, f, makepgd)
([0.0, 0.0, 1.0, 0.0], -499.9)
```
"""
function bestswap(xinit::AbstractVector{T}, supports::AbstractMatrix{<:Integer}, selection, f, fa) where {T<:Real}
    # Pre-allocate
    npossibilities = size(supports, 2)
    xs = repeat(xinit, 1, npossibilities)
    os = zeros(npossibilities)

    # Compute optimal swap
    _ = map(eachcol(xs), eachcol(supports), 1:npossibilities) do x, support, i  # In-place so don't need to return or assign
        x[Not(support)] .= zero(T)
        v = swap!(x, support, f, fa)
        os[i] = selection(v)
        return nothing
    end

    # Find best objective value and return it and the corresponding vector
    o, ix = findmin(os)
    return xs[:, ix], o
end

"""
    iteration(obj::Function, alg::PairwiseGreedyOpt)

One iteration of the pairwise greedy optimization algorithm `alg` for objective `obj`.

# Example
```julia
julia> using SemioticOpt
julia> using LinearAlgebra
julia> f(x, ixs, a, b) = -((a[ixs] .* x) ./ (x .+ b[ixs])) |> sum
julia> aa = Float64[1, 1, 1000, 1]
julia> bb = Float64[1, 1, 1, 1]
julia> f(x, ixs) = f(x, ixs, aa, bb)
julia> function makepgd(v)
           return ProjectedGradientDescent(;
               x=v,
               η=1e-1,
               hooks=[StopWhen((a; kws...) -> norm(SemioticOpt.x(a) - kws[:z]) < 1.0)],
               t=v -> σsimplex(v, 1)  # Project onto unit-simplex
           )
       end
julia> alg = PairwiseGreedyOpt(;
           kmax=4,
           x=zeros(4),
           xinit=zeros(4),
           f=f,
           a=makepgd,
           hooks=[StopWhen((a; kws...) -> kws[:f](kws[:z]) ≥ kws[:f](SemioticOpt.x(a)))]
       )
julia> c = 0.1  # per non-zero cost
julia> selection = x -> f(x, 1:length(x)) + c * length(SemioticOpt.nonzeroixs(x))
julia> z = SemioticOpt.iteration(selection, alg)
4-element Vector{Float64}:
 0.0
 0.0
 1.0
 0.0
```
"""
function iteration(obj::Function, alg::PairwiseGreedyOpt)
    v = x(alg)
    k = kmax(alg)

    # Find the current support
    ixs = currentsupport(v, k)

    # Find all possible next supports
    supports = possiblesupports(k, ixs, length(v))

    # Find the best swap using the possible supports
    v, _ = bestswap(xinit(alg), supports, obj, f(alg), a(alg))
    return v
end
