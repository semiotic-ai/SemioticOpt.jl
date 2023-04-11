# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

@testset "pgo" begin

    @testset "currentsupport" begin
        kmax = 4
        x = [0.4, 0.0, 0.3, 0.0]
        out = SemioticOpt.currentsupport(x, kmax)
        @test out == [1, 3]

        x = [0.0, 0.0, 0.0, 0.0]
        out = SemioticOpt.currentsupport(x, kmax)
        @test out == []
    end

    @testset "possiblesupports" begin
        ixs = Int32[]
        n = 4
        isfull = false
        k = length(ixs)
        out = SemioticOpt.possiblesupports(Val(isfull), k, ixs, n)
        @test out |> size == (k + 1, n - k)
        @test out[:, 1] == [1]
        @test out[:, 2] == [2]
        @test out[:, 3] == [3]
        @test out[:, 4] == [4]

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

    @testset "swap!" begin
        f(x, ixs, a, b) = -((a[ixs] .* x) ./ (x[ixs] .+ b[ixs])) |> sum
        aa = Float64[1, 1, 1000, 1]
        bb = Float64[1, 1, 1, 1]
        f(x, ixs) = f(x, ixs, aa, bb)

        function makepgd(v)
            return ProjectedGradientDescent(;
                x=v,
                η=1e-1,
                hooks=[StopWhen((a; kws...) -> norm(SemioticOpt.x(a) - kws[:z]) < 1.0)],
                t=v -> σsimplex(v, 1)  # Project onto unit-simplex
            )
        end

        x = zeros(4)
        support = [1, 2, 3]
        SemioticOpt.swap!(x, support, f, makepgd)
        @test x == [0, 0, 1, 0]
    end
end
