# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export PostIterationTrait, RunAfterIteration, DontRunAfterIteration
export postiteration, postiterationhook

"""
Abstract type for trait denoting hooks that should run after an iteration finishes.
"""
abstract type PostIterationTrait end

"""
Exhibited by hooks that run after an iteration finishes.

Such hooks must take the output of [`SemioticOpt.iteration`](@ref) `z` as input and return
`z` back, potentially modified.

To set this trait for a hook, run
```julia
julia> PostIterationTrait(::Type{MyHook}) = RunAfterIteration()
```
"""
struct RunAfterIteration <: PostIterationTrait end

"""
Exhibited by hooks that don't run after an iteration finishes.

This is the default case.
You should not have to set it manually for any hooks.
"""
struct DontRunAfterIteration <: PostIterationTrait end

PostIterationTrait(::Type) = DontRunAfterIteration()

"""
    postiterationhook(
        hs::AbstractVecOrTuple{H}, a::OptAlgorithm, z::AbstractVector{T}; locals...
    ) where {H<:Hook,T<:Real}

Run hooks that the code should execute after [`SemioticOpt.iteration`](@ref).
"""
function postiteration(
    hs::AbstractVecOrTuple{H}, a::OptAlgorithm, z::AbstractVector{T}; locals...
) where {H<:Hook,T<:Real}
    for h in hs
        z = postiterationhook(h, a, z; locals...)
    end
    return z
end

function postiterationhook(
    h::H, a::OptAlgorithm, z::AbstractVector{T}; locals...
) where {H,T<:Real}
    return postiterationhook(PostIterationTrait(H), h, a, z; locals...)
end
"""
    postiterationhook(
        ::RunAfterIteration, h::Hook, a::OptAlgorithm, z::AbstractVector{T}; locals...
    ) where {T<:Real}

Raise an error if the hook exhibits [`SemioticOpt.RunAfterIteration`](@ref) but has not
implemented [`SemioticOpt.postiterationhook`](@ref).
"""
function postiterationhook(
    ::RunAfterIteration, h::Hook, a::OptAlgorithm, z::AbstractVector{T}; locals...
) where {T<:Real}
    return error(
        "$(typeof(h)) registered as `IsStoppingCondition`, but `stophook` hasn't been " *
        "defined for it.",
    )
end
"""
postiterationhook(
    ::DontRunAfterIteration, h::Hook, a::OptAlgorithm, z::AbstractVector{T}; locals...
) where {T<:Real}

If the hook shouldn't run after an iteration, just return `z` unmodified.
"""
function postiterationhook(
    ::DontRunAfterIteration, ::Hook, ::OptAlgorithm, z::AbstractVector{T}; locals...
) where {T<:Real}
    return z
end
