using EvolutionaryAlgs
using Test


@testset "DE.jl" begin
    include("util/cross/cross.jl")

    begin
        feval = x -> x[1] * x[1] + x[2] * x[2]
        result = EvolutionaryAlgs.optimizeDE(
            feval,
            1000,
            popsize = 6,
            fcross = EvolutionaryAlgs.current2bestCross,
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
