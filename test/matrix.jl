# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

@testset "matrix" begin
    @testset "repeatwithoutdiag" begin
        @test repeatwithoutdiag([1.0, 2.0, 3.0]) == reshape([2.0, 3.0, 1.0, 3.0, 1.0, 2.0], 2, 3)
    end
end