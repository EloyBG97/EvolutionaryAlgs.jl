using EvolutionaryAlgs
using Test


@testset "GA.jl" begin
    include("util/cross/cross.jl")
    include("util/mutation/mutation.jl")
    include("GGA.jl")
    include("SSGA.jl")
end
