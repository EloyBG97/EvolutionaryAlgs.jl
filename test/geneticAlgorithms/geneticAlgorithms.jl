using EvolutionaryAlgs
using Test


@testset "geneticAlgorithms.jl" begin
    # Write your own tests here.
    include("selection/selection.jl")
    include("cross/cross.jl")
    include("mutation/mutation.jl")

end
