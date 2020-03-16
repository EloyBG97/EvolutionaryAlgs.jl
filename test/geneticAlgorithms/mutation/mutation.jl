using EvolutionaryAlgs
using Test


@testset "mutation.jl" begin
    # Write your own tests here.
    include("normMutation.jl")
    include("permMutation.jl")

end
