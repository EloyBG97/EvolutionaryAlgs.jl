using EvolutionaryAlgs
using Test


@testset "PSO.jl" begin
    begin
        feval = x -> x[1] * x[1] + x[2] * x[2]
        result = EvolutionaryAlgs.optimizePSOGlobal(
            feval,
            1000,
            maximize = true,
            popsize = 60,
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
        result = EvolutionaryAlgs.optimizePSOLocal(
            feval,
            500,
            maximize = true,
            popsize = 30,
            ndim = 2,
            dmin = 0,
            dmax = 10,
        )

        @test result.evals <= 1000
        @test all(result.fitness[result.bestidx] .>= result.fitness)
        @test all(map(feval, eachrow(result.population)) == result.fitness)
        @test result.population == clamp.(result.population, 0, 10)
    end

end
