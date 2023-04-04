# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export nonzeroixs, klargestixs

"""
    nonzeroixs(x::AbstractVector{T}) where {T<:Real}

Returns the indices of the non-zero elements of `x`.
"""
nonzeroixs(x::AbstractVector{T}) where {T<:Real} = findall(!iszero, x) 

"""
    klargestixs(x::AbstractVector{T}, k::I) where {T<:Real, I<:Integer}

Returns the indices of the `k` largest elements of `x`.

If all elements are the same, will just return the first `k` indices.
"""
klargestixs(x::AbstractVector{T}, k::I) where {T<:Real, I<:Integer} = partialsortperm(x, 1:k; rev=true)
