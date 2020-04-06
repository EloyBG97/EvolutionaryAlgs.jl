using EvolutionaryAlgs
using Test

@testset "tournamentSelection.jl" begin
    begin
        fitness = rand(40)
        population = rand(40, 6)
        selected = EvolutionaryAlgs.tournament_selection(population, fitness)

        @test minimum(fitness) != fitness[selected]
    end
end
