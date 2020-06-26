using EvolutionaryAlgs
using Test


@testset "DE.jl" begin
    include("util/cross/cross.jl")

    begin
        alg = DE(fcross = EvolutionaryAlgs.current2bestCross)



        feval = x -> x[1] * x[1] + x[2] * x[2]
        result = optimize(
            feval,
            1000,
            maximize = true,
            population = rand(60, 2),
            dmin = 0,
            dmax = 10,
            alg = alg,
        )

        @test result.nEvals <= 1000
        @test all(maximum(result.fitness) .>= result.fitness)
        @test all(map(feval, eachrow(result.population)) == result.fitness)
        @test result.population == clamp.(result.population, 0, 10)

    end

    begin
        alg = DE(fcross = EvolutionaryAlgs.current2bestCross)



        feval = x -> x[1] * x[1] + x[2] * x[2]
        result = optimize(
            feval,
            1000,
            maximize = false,
            population = rand(60, 2),
            dmin = 0,
            dmax = 10,
            alg = alg,
        )

        @test result.nEvals <= 1000
        @test all(minimum(result.fitness) .<= result.fitness)
        @test all(map(feval, eachrow(result.population)) == result.fitness)
        @test result.population == clamp.(result.population, 0, 10)

    end

end
