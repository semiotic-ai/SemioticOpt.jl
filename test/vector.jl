# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

@testset "vector" begin
    @testset "nonzerosixs" begin
        @test nonzeroixs([1.0, 0.0, 2.0, 0.0, 3.0]) == [1, 3, 5]
    end

    @testset "klargestixs" begin
        @test klargestixs([1.0, 0.0, 2.0, 0.0, 3.0], 2) == [5, 3]
        @test klargestixs(zeros(5), 2) == [1, 2]
        @test klargestixs([1.0, 1.0, 2.0, 2.0], 3) == [3, 4, 1]
    end
end