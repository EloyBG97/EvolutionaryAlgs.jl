using EvolutionaryAlgs
using Test


@testset "genetic_algorithm/selection.jl" begin
    @test begin
        population = rand(40, 20)
        selectedpop = EvolutionaryAlgs.roulette_wheel_selection(population, sum)

        size(selectedpop, 1) == 20 && size(selectedpop, 2) == 20
    end

    @test begin
        population = rand(40, 20)
        selectedpop = EvolutionaryAlgs.roulette_wheel_selection(population, sum, 0.75)

        size(selectedpop, 1) == 30 && size(selectedpop, 2) == 20
    end

    @test begin
        population = rand(120, 40)
        selectedpop = EvolutionaryAlgs.roulette_wheel_selection(population, sum)

        size(selectedpop, 1) == 60 && size(selectedpop, 2) == 40
    end

    @test begin
        population = rand(500, 75)
        selectedpop = EvolutionaryAlgs.roulette_wheel_selection(population, sum, 0.75)

        size(selectedpop, 1) == 375 && size(selectedpop, 2) == 75
    end
end
