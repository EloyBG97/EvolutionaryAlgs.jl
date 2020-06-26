module EvolutionaryAlgs

using Random
using StatsBase
using Distances
using Distributions
using DocStringExtensions
using CMAEvolutionStrategy

include("GA/GA.jl")
include("DE/DE.jl")
include("PSO/PSO.jl")
include("BFO/BFO.jl")
include("FA/FA.jl")
include("GSA/GSA.jl")
include("optimize/optimize.jl")
include("utility/callback.jl")

end # module
