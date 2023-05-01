@testset "halperniteration" begin
    struct FakeOptAlg <: SemioticOpt.OptAlgorithm end
    a = FakeOptAlg()

    h = HalpernIteration(; x₀=[1, 1], λ=k -> 1 / k)
    z = [5, 8]
    znew = postiteration((h,), a, z; Dict(:i => 0)...)  # Should be x₀ to start
    @test znew == [1, 1]

    znew = postiteration((h,), a, z; Dict(:i => 1e10)...)  # Get closer to z over time
    @test znew ≈ [5, 8]

    a = GradientDescent(;
        x=[100.0, 50.0],
        η=1e-1,
        hooks=[
            StopWhen((a; kws...) -> norm(x(a) - kws[:z]) < 2.0),
            HalpernIteration(; x₀=[10, 10], λ=k -> 1 / (k - 1)),
        ]
    )
    f(x) = sum(x .^ 2)
    o = minimize!(f, a)
    @test x(o) == [9.0, 9.0]
end
