# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export GradientDescent, x, x!, η, ϵ

"""
    GradientDescent(;x::V, η::T, hooks::S) where {
        T<:Real,V<:AbstractVector{T},S<:AbstractVecOrTuple{<:Hook}
    }

Parameters for gradient descent learning.

# Fields
- `η::T` is the learning rate/step size.
- `x::V` is the current best guess for the solution.
- `hooks::S` are the hooks
"""
Base.@kwdef struct GradientDescent{
    T<:Real,V<:AbstractVector{T},S<:AbstractVecOrTuple{<:Hook}
} <: OptAlgorithm
    x::V
    η::T
    hooks::S
end

"""
    x(g::GradientDescent)
    x(g::GradientDescent, v)

The current best guess for the solution. If using the setter, `v` is the new value.

The setter is not in-place.
See [`SemioticOpt.x!`](@ref).
"""
x(g::GradientDescent) = g.x
x(g::GradientDescent, v) = @set g.x = v
"""
    x!(g::GradientDescent, v)

In-place setting of `g.x` to `v`

See [`SemioticOpt.x`](@ref).
"""
function x!(g::GradientDescent, v)
    g.x .= v
    return g
end
"""
    η(g::GradientDescent)

The learning rate/step size.
"""
η(g::GradientDescent) = g.η
"""
    hooks(g::GradientDescent)

The hooks used by the algorithm.
"""
hooks(g::GradientDescent) = g.hooks

"""
    iteration(f::Function, a::GradientDescent)

One iteration of `a` on the function `f`.

This function is unexported.
"""
function iteration(f::Function, a::GradientDescent)
    ∇f = first(Zygote.gradient(f, x(a)))
    z = x(a) .- η(a) * ∇f
    return z
end
