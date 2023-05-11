# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

@testset "hook" begin
    struct FakeOptAlg <: SemioticOpt.OptAlgorithm end
    struct FakeHook <: Hook end
    a = FakeOptAlg()
    function counter(h, a)
        i = 0
        while !shouldstop(h, a; Base.@locals()...)
            z = [1, 2]
            i += 1
            z = postiteration(h, a, z; Base.@locals()...)
        end
        return i
    end

    @testset "stoptrait" begin
        h = FakeHook()
        @test !stophook(h, a; Dict()...)

        SemioticOpt.StopTrait(::Type{FakeHook}) = IsStoppingCondition()
        @test_throws Exception stophook(h, a; Dict()...)
    end

    @testset "StopWhen" begin
        h = StopWhen((a; kws...) -> kws[:i] ≥ 5)  # Stop when i ≥ 5
        i = counter((h,), a)
        @test i == 5
    end

    @testset "postiterationtrait" begin
        h = FakeHook()
        z = [1, 1]
        @test postiterationhook(h, a, z; Dict()...) == z

        SemioticOpt.PostIterationTrait(::Type{FakeHook}) = RunAfterIteration()
        @test_throws Exception postiterationhook(h, a, z; Dict()...)
    end

    @testset "Logger" begin
        @testset "VectorLogger" begin
            stop = StopWhen((a; kws...) -> kws[:i] ≥ 5)  # Stop when i ≥ 5
            h = VectorLogger(name="i", frequency=1, data=Int32[], f=(a; kws...) -> kws[:i])
            i = counter((h, stop), a)
            @test SemioticOpt.data(h) == 1:5 |> collect
        end

        @testset "ConsoleLogger" begin
            stop = StopWhen((a; kws...) -> kws[:i] ≥ 1)  # Stop when i ≥ 1
            h = ConsoleLogger(name="i", frequency=1, f=(a; kws...) -> kws[:i])
            out = @capture_out counter((h, stop), a)
            @test out == "i: 1\n"
        end
    end
end
