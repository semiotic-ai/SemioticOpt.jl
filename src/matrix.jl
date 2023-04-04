# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export repeatwithoutdiag

"""
    repeatwithoutdiag(v::AbstractVector{T}) where {T<:Real}

The same as `repeat(v, 1, length(v))` but without the diagonal.
"""
function repeatwithoutdiag(v::AbstractVector{T}) where {T<:Real}
    k = length(v)
    ixs = CartesianIndices((k, k))
    ixs = filter(x -> x.I[1] ≠ x.I[2], ixs)
    ii = Matrix{Int32}(undef, k - 1, k)
    for i in LinearIndices(ii)
        ii[i] = v[ixs[i].I[1]]
    end
    return ii
end
