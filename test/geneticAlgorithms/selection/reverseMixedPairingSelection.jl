using EvolutionaryAlgs
using Test

@testset "reverseMixedPairingSelection.jl" begin
    @test begin
        population = rand(20, 40)

        selected = EvolutionaryAlgs.reverse_mixed_pairing_selection(population)
        true
    end
end
