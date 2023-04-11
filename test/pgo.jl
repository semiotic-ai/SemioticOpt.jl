# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

@testset "pgo" begin
    @testset "possiblesupports" begin
        ixs = 1:2 |> collect
        n = 4
        isfull = false
        k = length(ixs)
        out = SemioticOpt.possiblesupports(Val(isfull), k, ixs, n)
        @test out |> size == (k + 1, n - k)
        @test out[:, 1] == [1, 2, 3]
        @test out[:, 2] == [1, 2, 4]


        isfull = true
        out = SemioticOpt.possiblesupports(Val(isfull), k, ixs, n)
        @test out |> size == (k, k * (n - k))
        @test out[:, 1] == [2, 3]
        @test out[:, 2] == [2, 4]
        @test out[:, 3] == [1, 3]
        @test out[:, 4] == [1, 4]

        ixs = 1:3 |> collect
        n = 4
        isfull = true
        kmax = 3
        out = SemioticOpt.possiblesupports(kmax, ixs, n)
        k = length(ixs)
        @test out |> size == (k, k * (n - k))
        @test out[:, 1] == [2, 3, 4]
        @test out[:, 2] == [1, 3, 4]
        @test out[:, 3] == [1, 2, 4]
    end
end
