# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

@testset "project" begin
    @testset "σsimplex" begin
        x = Float64[1, 0, 0]
        σ = 1
        @test σsimplex(x, σ) == [1, 0, 0]  # Already on the simplex

        x = Float64[1, 0, 0]
        σ = 0.1
        @test σsimplex(x, σ) ≈ [0.1, 0, 0]  # Scale down

        x = Float64[-1, 0, 0]
        σ = 5
        @test σsimplex(x, σ) ≈ [1, 2, 2]  # Scale up
    end

    @testset "gssp" begin
        x = Float64[1, 2, 3]
        k = 1
        σ = 3
        @test gssp(x, k, σ) == [0, 0, 3]  # Since we're trying to sum to 3, choose the el that's already 3

        x = Float64[1, 2, 3]
        k = 2
        σ = 5
        @test gssp(x, k, σ) == [0, 2, 3]  # Since we're trying to sum to 5, choose the 2nd and 3rd elements

        x = Float64[1, 2, 3]
        k = 1
        σ = 5
        @test gssp(x, k, σ) == [0, 0, 5]  # Since we're trying to sum to 5, put 5 on the third element
    end
end
