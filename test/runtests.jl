using EvolutionaryAlgs
using Test


@testset "EvolutionaryAlgs.jl" begin
    # Write your own tests here.
    include("GA/GA.jl")
    include("DE/DE.jl")
    include("BFO/BFO.jl")
    include("PSO/PSO.jl")
    include("FA/FA.jl")
    include("GSA/GSA.jl")
    include("utility/utility.jl")
end
