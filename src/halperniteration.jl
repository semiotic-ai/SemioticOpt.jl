# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export HalpernIteration

"""
    HalpernIteration{T<:Real,V<:AbstractVector{T}} <: Hook

A hook for using [Halpern Iteration](https://projecteuclid.org/journals/bulletin-of-the-american-mathematical-society/volume-73/issue-6/Fixed-points-of-nonexpanding-maps/bams/1183529119.pdf).
in which you should specify the `x₀` and `λ`.
"""
Base.@kwdef struct HalpernIteration{T<:Real,V<:AbstractVector{T},F<:Function} <: Hook
    x₀::V
    λ::F
end

"""
Get the anchor of `h`.
"""
x₀(h::HalpernIteration) = h.x₀
"""
Get the λ of `h`.
"""
λ(h::HalpernIteration) = h.λ

PostIterationTrait(::Type{<:HalpernIteration}) = RunAfterIteration()
function postiterationhook(
    ::RunAfterIteration,
    h::HalpernIteration,
    a::OptAlgorithm,
    z::AbstractVector{T};
    locals...,
) where {T<:Real}
    k = locals[:i]
    λₖ = λ(h)(k + 1)
    z = λₖ * x₀(h) .+ (1 .- λₖ) * z
    return z
end
