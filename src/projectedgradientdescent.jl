# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export ProjectedGradientDescent

"""
    ProjectedGradientDescent(;
        x::AbstractVector{T}, η::T, hooks::AbstractVecOrTuple{<:Hook}, t::F
    ) where {T<:Real,F<:Function}
    ProjectedGradientDescent(g::G, t::F) where {G<:GradientDescent,F<:Function}

Specifies parameters for [`SemioticOpt.GradientDescent`](@ref) and the projection function `t`.

`t` takes as input the vector to be projected `x` and returns the projected vector.

# Forwarded Methods
- [`SemioticOpt.x`](@ref)
- [`SemioticOpt.η`](@ref)
- [`SemioticOpt.hooks`](@ref)
"""
struct ProjectedGradientDescent{G<:GradientDescent,F<:Function} <: OptAlgorithm
    g::G
    t::F

    function ProjectedGradientDescent(;
        x::AbstractVector{T}, η::T, hooks::AbstractVecOrTuple{<:Hook}, t::F
    ) where {T<:Real,F<:Function}
        g = GradientDescent(; x=x, η=η, hooks=hooks)
        return new{typeof(g),F}(g, t)
    end
    function ProjectedGradientDescent(g::G, t::F) where {G<:GradientDescent,F<:Function}
        return new{G,F}(g, t)
    end
end

Lazy.@forward ProjectedGradientDescent.g x, η, hooks

"""
    x(g::ProjectedGradientDescent)
    x(g::ProjectedGradientDescent, v)

The current best guess for the solution. If using the setter, `v` is the new value.

The setter is not in-place.
See [`SemioticOpt.x!`](@ref).
"""
function x(a::ProjectedGradientDescent, v)
    return @set a.g = x(a.g, v)
end
"""
    x!(g::ProjectedGradientDescent, v)

In-place setting of `a.g.x` to `v`

See [`SemioticOpt.x`](@ref).
"""
function x!(a::ProjectedGradientDescent, v)
    _ = x!(a.g, v)
    return a
end

"""
    iteration(f::Function, a::ProjectedGradientDescent)

Apply `a` to `f`, projected based on `a.t`.
"""
iteration(f::Function, a::ProjectedGradientDescent) = a.t(iteration(f, a.g))
