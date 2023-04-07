# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

@testset "pgo" begin
    f(x, ixs, args...) = sum(x[ixs] .^ 2)
    makepgofunc() = PGOOptFunction(f=f, args=[Float64[]])
    distfromzero(n) = norm([0.0, 0.0] - x(n))

    @testset "PGOOptFunction" begin
        pgofunc = makepgofunc()
        ixs = [1, 2]
        x = [1.0, 2.0]
        _f = SemioticOpt.f(pgofunc)
        @test _f(x, ixs, pgofunc |> SemioticOpt.args) == 5.0
        ixs = [1]
        @test _f(x, ixs, pgofunc |> SemioticOpt.args) == 1.0
    end
end
