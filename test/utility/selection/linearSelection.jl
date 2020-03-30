using EvolutionaryAlgs
using StatsBase
using Test


@testset "linearSelection.jl" begin
    @test begin
        population = rand(5,2)
        fitness = rand(5)

        p = EvolutionaryAlgs.linear_selection(population, fitness)
        true
    end
end
