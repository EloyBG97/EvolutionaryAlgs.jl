using EvolutionaryAlgs
using Test


@testset "CMAES.jl" begin
    begin
        alg = CMAES()

        feval = x -> x[1] * x[1] + x[2] * x[2]

        result = optimize(
            feval,
            1000,
            maximize = true,
            popsize = 60,
            ndim = 2,
            dmin = 0,
            dmax = 10,
            alg = alg,
            fcallback = callback_print
        )

        @test result.nEvals <= 1000
        @test all(maximum(result.fitness) .>= result.fitness)
        @test all(map(feval, eachrow(result.population)) == result.fitness)
        @test result.population == clamp.(result.population, 0, 10)
    end
end
