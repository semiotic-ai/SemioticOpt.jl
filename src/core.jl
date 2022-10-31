# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

export minimize, minimize!

"""
    minimize(f::Function, a::OptAlgorithm)

Minimize `f` using `a`.

This will generally be less performant than [`SemioticOpt.minimize!`](@ref).
However, there are cases in which this will be better, so we provide it as an option.

!!! warning
    If you don't provide any hook with the [`IsStoppingCondition`](@ref) trait,
    this will loop forever.
"""
minimize(f::Function, a::OptAlgorithm) = maybeminimize!(f, a, x)

"""
    minimize!(f::Function, a::OptAlgorithm)

Minimize `f` using `a`.

Does in-place updates of `a.x`.
This will generally be more performant than [`SemioticOpt.minimize`](@ref).
However, there are cases in which this will be worse, so we provide both.

!!! warning
    If you don't provide any hook with the [`IsStoppingCondition`](@ref) trait,
    this will loop forever.
"""
minimize!(f::Function, a::OptAlgorithm) = maybeminimize!(f, a, x!)

"""
    maybeminimize!(f::Function, a::OptAlgorithm, op::Function)

Minimize `f` using `a`, which calls `op` for updating `a.x`.

This function *may* be in-place.
Don't use it directly unless you know what you're doing.
This function is unexported.

!!! warning
    If you don't provide any hook with the [`IsStoppingCondition`](@ref) trait,
    this will loop forever.
"""
function maybeminimize!(f::Function, a::OptAlgorithm, op::Function)
    z = iteration(f, a)
    i = 0
    while !shouldstop(hooks(a), a; Base.@locals()...)
        a = op(a, z)
        z = iteration(f, a)
        z = postiteration(hooks(a), a, z; Base.@locals()...)
        i += 1
    end
    a = op(a, z)
    return a
end
