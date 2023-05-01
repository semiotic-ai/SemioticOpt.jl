# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export Hook, Hooks

"""
Abstract type for hooks.
"""
abstract type Hook end

"""
    A collection of hooks.
"""
const Hooks = Union{Vector{<:Hook}, Tuple{Vararg{<:Hook}}}