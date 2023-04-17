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
        f(x, ixs, a, b) = -((a[ixs] .* x) ./ (x .+ b[ixs])) |> sum
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

        support = [3, 2]
        SemioticOpt.swap!(x, support, f, makepgd)
        @test x == [0, 0, 1, 0]
    end

    @testset "bestswap" begin
        f(x, ixs, a, b) = -((a[ixs] .* x) ./ (x .+ b[ixs])) |> sum
        aa = Float64[1, 1, 1000, 1]
        bb = Float64[1, 1, 1, 1]
        f(x, ixs) = f(x, ixs, aa, bb)
        c = 0.1  # per non-zero cost
        selection = x -> f(x, 1:length(x)) + c * length(SemioticOpt.nonzeroixs(x))

        function makepgd(v)
            return ProjectedGradientDescent(;
                x=v,
                η=1e-1,
                hooks=[StopWhen((a; kws...) -> norm(SemioticOpt.x(a) - kws[:z]) < 1.0)],
                t=v -> σsimplex(v, 1)  # Project onto unit-simplex
            )
        end
        supports = [[1 3]; [2 2]]
        xinit = zeros(4)
        v, o = SemioticOpt.bestswap(xinit, supports, selection, f, makepgd)
        @test v == [0, 0, 1, 0]
        @test o == -499.9
    end

    @testset "iteration" begin
        f(x, ixs, a, b) = -((a[ixs] .* x) ./ (x .+ b[ixs])) |> sum
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
        alg = PairwiseGreedyOpt(;
            kmax=4,
            x=zeros(4),
            xinit=zeros(4),
            f=f,
            a=makepgd,
            hooks=[StopWhen((a; kws...) -> kws[:f](kws[:z]) ≤ kws[:f](SemioticOpt.x(a)))]
        )

        c = 0.1  # per non-zero cost
        selection = x -> f(x, 1:length(x)) + c * length(SemioticOpt.nonzeroixs(x))

        z = SemioticOpt.iteration(selection, alg)
        @test z == [0, 0, 1, 0]
    end

    @testset "minimize" begin
        f(x, ixs, a, b) = -((a[ixs] .* x) ./ (x .+ b[ixs])) |> sum
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
        alg = PairwiseGreedyOpt(;
            kmax=4,
            x=zeros(4),
            xinit=zeros(4),
            f=f,
            a=makepgd,
            hooks=[StopWhen((a; kws...) -> kws[:f](kws[:z]) ≤ kws[:f](SemioticOpt.x(a)))]
        )

        c = 0.1  # per non-zero cost
        selection = x -> f(x, 1:length(x)) + c * length(SemioticOpt.nonzeroixs(x))

        res = SemioticOpt.minimize(selection, alg)
        @test SemioticOpt.x(res) == [0, 0, 1, 0]
    end

    @testset "minimize" begin
        f(x, ixs, a, b) = -((a[ixs] .* x) ./ (x .+ b[ixs])) |> sum
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
        alg = PairwiseGreedyOpt(;
            kmax=4,
            x=zeros(4),
            xinit=zeros(4),
            f=f,
            a=makepgd,
            hooks=[
                StopWhen((a; kws...) -> kws[:f](kws[:z]) ≤ kws[:f](SemioticOpt.x(a))),
                StopWhen(
                    (a; kws...) -> length(kws[:z]) == length(SemioticOpt.nonzeroixs(kws[:z]))
                )
            ]
        )

        c = 0.1  # per non-zero cost
        selection = x -> f(x, 1:length(x)) + c * length(SemioticOpt.nonzeroixs(x))

        res = SemioticOpt.minimize!(selection, alg)
        @test SemioticOpt.x(res) == [0, 0, 1, 0]
    end
end
