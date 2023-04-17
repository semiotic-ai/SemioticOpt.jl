# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

@testset "gradientdescent" begin
    function makegd()
        return GradientDescent(;
            x=[100.0, 50.0],
            η=1e-1,
            hooks=[StopWhen((a; kws...) -> norm(x(a) - kws[:z]) < 1.0)]
        )
    end
    distfromzero(n) = norm([0.0, 0.0] - x(n))
    f(x) = sum(x .^ 2)
    @testset "iteration" begin
        lipschitzconstant = 2
        g = GradientDescent(;
            x=[100.0, 50.0],
            η=stepsize(lipschitzconstant),
            hooks=[StopWhen((a; kws...) -> norm(x(a) - kws[:z]) < 1.0)]
        )
        z = SemioticOpt.iteration(f, g)
        @test z == [-100.0, -50.0]
    end

    @testset "minimize" begin
        glarge = GradientDescent(;
            x=[100.0, 50.0],
            η=1e-1,
            hooks=[StopWhen((a; kws...) -> norm(x(a) - kws[:z]) < 2.0)]
        )
        gsmall = makegd()
        nlarge = minimize(f, glarge)
        nsmall = minimize(f, gsmall)
        @test x(gsmall) != x(nsmall)  # Check has not mutated
        @test distfromzero(nlarge) > distfromzero(nsmall)  # Check that as ϵ→0, solution approaches 0
    end

    @testset "minimize!" begin
        glarge = GradientDescent(;
            x=[100.0, 50.0],
            η=1e-1,
            hooks=[StopWhen((a; kws...) -> norm(x(a) - kws[:z]) < 2.0)]
        )
        gsmall = makegd()
        nlarge = minimize!(f, glarge)
        nsmall = minimize!(f, gsmall)
        @test x(gsmall) == x(nsmall)  # Check has mutated
        @test distfromzero(nlarge) > distfromzero(nsmall)  # Check that as ϵ→0, solution approaches 0
    end
end
