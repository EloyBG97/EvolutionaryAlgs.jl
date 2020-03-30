using EvolutionaryAlgs
using Test


@testset "cross.jl" begin
    # Write your own tests here.
    include("bestCross.jl")
    include("current2bestCross.jl")

end
