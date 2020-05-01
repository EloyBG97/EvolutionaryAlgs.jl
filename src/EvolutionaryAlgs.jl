module EvolutionaryAlgs

using Random
using StatsBase
using Distances
using Distributions
using DocStringExtensions

include("GA/GA.jl")
include("DE/DE.jl")
include("PSO/PSO.jl")
include("BFO/BFO.jl")
include("FA/FA.jl")
include("optimize/optimize.jl")
include("utility/callback.jl")



end # module
