# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export σsimplex, gssp

"""
    σsimplex(x::AbstractVector{T}, σ::Real) where {T<:Real}

Project `x` onto the `σ`-simplex.

In other words, project `x`s to be non-negative and sum to `σ`.

This operation is precision-senstive, so we conver the data to bigfloat within the function.
We then convert back to `T` before returning.

We use RoundDown while converting from BigFloat to `T` to ensure that the sum of the
projected vector is less than or equal to `σ`.
"""
function σsimplex(x::AbstractVector{T}, σ::Real) where {T<:Real}
    _x = convert(Vector{BigFloat}, x)
    _σ = convert(BigFloat, σ)
    n = length(_x)
    μ = sort(_x; rev=true)
    ρ = maximum((1:n)[μ-(cumsum(μ).-_σ)./(1:n).>zero(BigFloat)])
    θ = (sum(μ[1:ρ]) - _σ) / ρ
    _w = max.(_x .- θ, zero(BigFloat))
    _w .= T.(_w, RoundDown)
    return _w
end

"""
    gssp(x::AbstractVector{<:Real}, k::Int, σ::Real)

Project `x` onto the intersection of the set of `k`-sparse vectors and the `σ`-simplex.

Reference: http://proceedings.mlr.press/v28/kyrillidis13.pdf
"""
function gssp(x::AbstractVector{<:Real}, k::Int, σ::Real)
    # Get k biggest indices of x
    biggest_ixs = klargestixs(x, k)
    # Project the subvector of the biggest indices onto the simplex
    v = x[biggest_ixs]
    vproj = σsimplex(v, σ)
    w = zeros(eltype(vproj), length(x))
    w[biggest_ixs] .= vproj
    return w
end
