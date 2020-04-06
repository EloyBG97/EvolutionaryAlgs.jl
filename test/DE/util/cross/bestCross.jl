using EvolutionaryAlgs
using Test

@testset "bestCross.jl" begin
    begin
        population = rand(10, 5)
        fitness = rand(10)
        current = population[1, :]


        h = EvolutionaryAlgs.bestCross(population, fitness, current, argmax)

        @test size(h) == (1, 5)
    end
end
