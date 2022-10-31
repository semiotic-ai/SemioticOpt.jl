# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

@testset "hook" begin
    struct FakeOptAlg <: SemioticOpt.OptAlgorithm end
    struct FakeHook <: Hook end
    a = FakeOptAlg()

    @testset "stoptrait" begin
        h = FakeHook()
        @test !stophook(h, a; Dict()...)

        SemioticOpt.StopTrait(::Type{FakeHook}) = IsStoppingCondition()
        @test_throws Exception stophook(h, a; Dict()...)
    end

    @testset "StopWhen" begin
        function counter(h, a)
            i = 0
            while !shouldstop(h, a; Base.@locals()...)
                i += 1
            end
            return i
        end

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
end
