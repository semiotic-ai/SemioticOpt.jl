# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

using SemioticOpt
using LinearAlgebra
using Test

for f in readlines(joinpath(@__DIR__, "testgroups"))
    include(f * ".jl")
end
