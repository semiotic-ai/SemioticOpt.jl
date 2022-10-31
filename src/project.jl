# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export σsimplex, gssp

"""
    σsimplex(x::AbstractVector{T}, σ::Real) where {T<:Real}

Project `x` onto the `σ`-simplex.

In other words, project `x`s to be non-negative and sum to `σ`.
"""
function σsimplex(x::AbstractVector{T}, σ::Real) where {T<:Real}
    n = length(x)
    μ = sort(x; rev=true)
    ρ = maximum((1:n)[μ - (cumsum(μ) .- σ) ./ (1:n) .> zero(T)])
    θ = (sum(μ[1:ρ]) - σ) / ρ
    w = max.(x .- θ, zero(T))
    return w
end

"""
    gssp(x::AbstractVector{<:Real}, k::Int, σ::Real)

Project `x` onto the intersection of the set of `k`-sparse vectors and the `σ`-simplex.

Reference: http://proceedings.mlr.press/v28/kyrillidis13.pdf
"""
function gssp(x::AbstractVector{<:Real}, k::Int, σ::Real)
    # Get k biggest indices of x
    biggest_ixs = partialsortperm(x, 1:k; rev=true)
    # Project the subvector of the biggest indices onto the simplex
    v = x[biggest_ixs]
    vproj = σsimplex(v, σ)
    w = zeros(eltype(vproj), length(x))
    w[biggest_ixs] .= vproj
    return w
end
