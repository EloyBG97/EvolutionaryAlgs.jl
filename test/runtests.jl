using EvolutionaryAlgs
using Test


@testset "EvolutionaryAlgs.jl" begin
    # Write your own tests here.
    include("geneticAlgorithms/geneticAlgorithms.jl")
    include("differentialEvolution/differentialEvolution.jl")
end
