# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export Logger, VectorLogger

"""
Abstract type for logging data
"""
abstract type Logger <: Hook end
PostIterationTrait(::Type{<:Logger}) = RunAfterIteration()

"""
    VectorLogger{T,V<:AbstractVector{T},F<:Function} <: Logger

A hook `name` for logging a value specified by `f` into a vector `data`.
This hook exhibits the [`RunAfterIteration`](@ref) trait.

The value we want to log is returned by `f`.
Note that `f` gets access to variables in the [`SemioticOpt.minimize`](@ref) scope.
This means, for example, that it can use `locals[:i]` to store the iteration number.

```julia
julia> using SemioticOpt
julia> struct FakeOptAlg <: SemioticOpt.OptAlgorithm end
julia> a = FakeOptAlg()
julia> function counter(h, a)
           i = 0
           while !shouldstop(h, a; Base.@locals()...)
               z = [1, 2]
               i += 1
               z = postiteration(h, a, z; Base.@locals()...)
           end
           return i
       end
julia> stop = StopWhen((a; kws...) -> kws[:i] ≥ 5)  # Stop when i ≥ 5
julia> h = VectorLogger(name="i", data=Int32[], f=(a; kws...) -> kws[:i])
julia> i = counter((h, stop), a)
julia> SemioticOpt.data(h)
5-element Vector{Int32}:
 1
 2
 3
 4
 5
```
"""
Base.@kwdef struct VectorLogger{T,V<:AbstractVector{T},F<:Function} <: Logger
    name::String
    data::V
    f::F
end

"""
    Get the name of the `h`.
"""
name(h::VectorLogger) = h.name
"""
    Get the data of the `h`.
"""
data(h::VectorLogger) = h.data
"""
    Get the function to record data
"""
f(h::VectorLogger) = h.f

function postiterationhook(
    ::RunAfterIteration,
    h::VectorLogger,
    a::OptAlgorithm,
    z::AbstractVector{T};
    locals...
) where {T<:Real}
    push!(data(h), f(h)(a; locals...))
    return z
end
