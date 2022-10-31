# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

@testset "projectedgradientdescent" begin
    f(x) = sum(x .^ 2)
    @testset "no projection should match gradientdescent" begin
        function makepgd()
            return ProjectedGradientDescent(;
                x=[100.0, 50.0],
                η=1e-1,
                hooks=[StopWhen((a; kws...) -> norm(x(a) - kws[:z]) < 1.0)],
                t=x -> x
            )
        end
        @testset "iteration" begin
            g = makepgd()
            z = SemioticOpt.iteration(f, g)
            @test z == [80.0, 40.0]
        end
    end
    @testset "minimize" begin
        a = ProjectedGradientDescent(;
            x=[100.0, 50.0],
            η=1e-1,
            hooks=[StopWhen((a; kws...) -> norm(x(a) - kws[:z]) < 1e-6)],
            t=x -> σsimplex(x, 1)  # Project onto unit-simplex
        )
        res = minimize(f, a)
        @test isapprox(x(res), [0.5, 0.5]; atol=1e-3)
        @test x(a) != x(res)  # Not in-place
    end
    @testset "minimize!" begin
        a = ProjectedGradientDescent(;
            x=[100.0, 50.0],
            η=1e-1,
            hooks=[StopWhen((a; kws...) -> norm(x(a) - kws[:z]) < 1e-6)],
            t=x -> σsimplex(x, 1)  # Project onto unit-simplex
        )
        res = minimize!(f, a)
        @test isapprox(x(res), [0.5, 0.5]; atol=1e-3)
        @test x(a) == x(res)  # in-place
    end
end
