using EvolutionaryAlgs
using Test

@testset "tournamentSelection.jl" begin
    begin
        fitness = rand(40)
        population = rand(40, 6)
        (p1, p2) = EvolutionaryAlgs.tournament_selection(population, fitness)

        print(p1, p2)
        @test minimum(fitness) != fitness[p1]
        @test minimum(fitness) != fitness[p2]
    end
end
