using EvolutionaryAlgs
using Test

@testset "tournamentSelection.jl" begin
    @test begin
        fitness = rand(40)
        selected = EvolutionaryAlgs.tournament_selection(fitness)

        minimum(fitness) != fitness[selected]
    end
end
