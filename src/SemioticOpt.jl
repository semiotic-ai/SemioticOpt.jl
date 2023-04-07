module SemioticOpt

using Base: AbstractVecOrTuple

using Accessors
using Lazy
using LinearAlgebra
using Zygote

abstract type OptAlgorithm end

include("vector.jl")
include("matrix.jl")
include("hook/core.jl")
include("hook/stop.jl")
include("hook/postiteration.jl")
include("project.jl")
include("core.jl")
include("gradientdescent.jl")
include("projectedgradientdescent.jl")
include("halperniteration.jl")
include("pgo.jl")

end
