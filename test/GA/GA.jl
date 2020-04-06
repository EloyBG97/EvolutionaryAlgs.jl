using EvolutionaryAlgs
using Test


@testset "GA.jl" begin
    include("util/cross/cross.jl")
    include("util/mutation/mutation.jl")

    begin
        feval = x -> x[1] * x[1] + x[2] * x[2]
        result = EvolutionaryAlgs.optimizeGGA(
            feval,
            1000,
            popsize = 6,
            ndim = 2,
            dmin = 0,
            dmax = 10,
        )
        @test result.evals <= 1000
        @test all(result.fitness[result.bestidx] .>= result.fitness)
        @test all(map(feval, eachrow(result.population)) == result.fitness)
        @test result.population == clamp.(result.population, 0, 10)
    end

    begin
        feval = x -> x[1] * x[1] + x[2] * x[2]
        result = EvolutionaryAlgs.optimizeSSGA(
            feval,
            2500,
            popsize = 60,
            ndim = 2,
            dmin = 0,
            dmax = 10,
        )
        @test result.evals <= 2500
        @test all(result.fitness[result.bestidx] .>= result.fitness)
        @test all(map(feval, eachrow(result.population)) == result.fitness)
        @test result.population == clamp.(result.population, 0, 10)
    end

end
