# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export StopTrait, IsStoppingCondition, IsNotStoppingCondition
export stophook, StopWhen, shouldstop

"""
Abstract type for stopping conditions traits
"""
abstract type StopTrait end

"""
Exhibited by hooks that are stopping conditions.

Stopping condition hooks must emit a boolean value when [`SemioticOpt.stophook`](@ref) is called.
If multiple hooks meet `IsStoppingCondition` are instantiated at the same time, we assume that
they are meant to be OR'ed, so if any of them is true, optimisation is finished.
For more complex behaviour, consider defining a more complex function using a single
[`StopWhen`](@ref).

To set this trait for a hook, run
```julia
julia> StopTrait(::Type{MyHook}) = IsStoppingCondition()
```
"""
struct IsStoppingCondition <: StopTrait end

"""
Exhibited by hooks that are not stopping conditions.

This is the default case.
You should not have to set it manually for any hooks.
"""
struct IsNotStoppingCondition <: StopTrait end

StopTrait(::Type) = IsNotStoppingCondition()

"""
    shouldstop(hs::AbstractVecOrTuple{H}, a::OptAlgorithm; locals...)

Map over the hooks `hs` to check for stopping conditions.

This performs an `OR` operation if there are multiple hooks that have the
[`SemioticOpt.IsStoppingCondition`](@ref) trait.
"""
function shouldstop(hs::AbstractVecOrTuple{H}, a::OptAlgorithm; locals...) where {H<:Hook}
    return any(map(h -> stophook(h, a; locals...), hs))
end

function stophook(h::T, a::OptAlgorithm; locals...) where {T}
    return stophook(StopTrait(T), h, a; locals...)
end
"""
    stophook(::IsStoppingCondition, h::Hook, a::OptAlgorithm; locals...)

Raise an error if the hook is a stopping condition but has not implemented
[`SemioticOpt.stophook`](@ref).
"""
function stophook(::IsStoppingCondition, h::Hook, a::OptAlgorithm; locals...)
    return error(
        "$(typeof(h)) registered as `IsStoppingCondition`, but `stophook` hasn't been " *
        "defined for it.",
    )
end
"""
    stophook(h::IsNotStoppingCondition, a::OptAlgorithm; locals...)

If the hook isn't a stopping condition, it shouldn't be considered in the OR, so return false.
"""
stophook(::IsNotStoppingCondition, h::Hook, a::OptAlgorithm; locals...) = false

"""
    StopWhen(f::Function)

Stops optimisation when some condition is met.

The condition is set by `f`.
Note that `f` gets access to variables in the [`SemioticOpt.minimize`](@ref) scope.
This means, for example, that it can use `locals[:z]` to compute residuals.
This has the [`SemioticOpt.IsStoppingCondition`](@ref) trait.
"""
Base.@kwdef struct StopWhen <: Hook
    f::Function
end
StopTrait(::Type{StopWhen}) = IsStoppingCondition()

"""
Getter for the stop-function.
"""
f(h::StopWhen) = h.f

"""
    stophook(::IsStoppingCondition, h::StopWhen, a::OptAlgorithm; locals...)

Call the stop-function on `a` and `;locals`.
"""
function stophook(::IsStoppingCondition, h::StopWhen, a::OptAlgorithm; locals...)
    return f(h)(a; locals...)
end
