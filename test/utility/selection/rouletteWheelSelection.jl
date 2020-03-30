using EvolutionaryAlgs
using StatsBase
using Test


@testset "rouletteWheelSelection.jl" begin
    @test begin

        population = rand(5, 6)
        fitness = rand(5)

        p = EvolutionaryAlgs.roulette_wheel_selection(population, fitness)
        true
    end
end
