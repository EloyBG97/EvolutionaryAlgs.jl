using EvolutionaryAlgs
using Test


@testset "selection.jl" begin
    # Write your own tests here.
    include("rouletteWheelSelection.jl")
    include("tournamentSelection.jl")
    include("reverseMixedPairingSelection.jl")
    include("linearSelection.jl")



end
