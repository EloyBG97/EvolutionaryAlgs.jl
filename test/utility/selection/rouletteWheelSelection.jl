using EvolutionaryAlgs
using StatsBase
using Test


@testset "rouletteWheelSelection.jl" begin
    begin

        population = rand(5, 6)
        fitness = rand(5)

        p = EvolutionaryAlgs.roulette_wheel_selection(population, fitness)
        @test true
    end
end
