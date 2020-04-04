using EvolutionaryAlgs
using Test


@testset "linearSelection.jl" begin
    @test begin
        population = rand(60,2)
        fitness = rand(60)

        p = EvolutionaryAlgs.findEnviroment(population, fitness, argmax, sizeEnv = 5)

        size(p) == size(population)
    end
end
