# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export Logger, VectorLogger, ConsoleLogger

"""
Abstract type for logging data
"""
abstract type Logger <: Hook end
PostIterationTrait(::Type{<:Logger}) = RunAfterIteration()

"""Get the name of the `h`."""
name(h::Logger) = h.name
"""Get the function to record data"""
f(h::Logger) = h.f
"""Get the frequency at which `h` logs data."""
frequency(h::Logger) = h.frequency

function postiterationhook(
    ::RunAfterIteration,
    h::Logger,
    a::OptAlgorithm,
    z::AbstractVector{T};
    locals...
) where {T<:Real}
    if locals[:i] % frequency(h) == 0
        v = f(h)(a; locals...)
        logdata(h, v)
    end
    return z
end

"""
    VectorLogger{I<:Integer,T,V<:AbstractVector{T},F<:Function} <: Logger

A hook `name` for logging a value specified by `f` into a vector `data` at some `frequency`.
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
julia> h = VectorLogger(name="i", frequency=1, data=Int32[], f=(a; kws...) -> kws[:i])
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
Base.@kwdef struct VectorLogger{I<:Integer,T,V<:AbstractVector{T},F<:Function} <: Logger
    name::String
    frequency::I
    data::V
    f::F
end

"""Get the data of the `h`."""
data(h::VectorLogger) = h.data
"""Log `v` into the vector in `h`"""
logdata(h::VectorLogger, v) = push!(data(h), v)

"""
    ConsoleLogger{I<:Integer,F<:Function} <: Logger

A hook `name` for logging a value specified by `f` to the console at some `frequency`.
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
julia> h = ConsoleLogger(name="i", frequency=1, f=(a; kws...) -> kws[:i])
julia> _ = counter((h, stop), a);
i: 1
i: 2
i: 3
i: 4
i: 5
```
"""
Base.@kwdef struct ConsoleLogger{F<:Function,I<:Integer} <: SemioticOpt.Logger
    name::String
    frequency::I
    f::F
end

"""Print `v` to the console"""
logdata(h::ConsoleLogger, v) = println("$(name(h)): $v")
