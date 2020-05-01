using EvolutionaryAlgs
using Test


@testset "optimize.jl" begin
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
        alg = SSGA(fcross = EvolutionaryAlgs.arithmetic_cross)

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
        )

        @test result.nEvals <= 1000
        @test all(maximum(result.fitness) .>= result.fitness)
        @test all(map(feval, eachrow(result.population)) == result.fitness)
        @test result.population == clamp.(result.population, 0, 10)
    end

    begin
        alg = GGA(pcross = 0.75, pmutation = 0.25)

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
        )

        @test result.nEvals <= 1000
        @test all(maximum(result.fitness) .>= result.fitness)
        @test all(map(feval, eachrow(result.population)) == result.fitness)
        @test result.population == clamp.(result.population, 0, 10)
    end

    begin
        alg = BFO()

        feval = x -> x[1] * x[1] + x[2] * x[2]

        result = optimize(
            feval,
            1000,
            maximize = true,
            popsize = 60,
            ndim = 2,
            dmin = 0,
            dmax = 10,
            alg = alg
        )

        @test result.nEvals <= 1000
        @test all(maximum(result.fitness) .>= result.fitness)
        @test all(map(feval, eachrow(result.population)) == result.fitness)
        @test result.population == clamp.(result.population, 0, 10)
    end

    begin
        alg = PSOG()

        feval = x -> x[1] * x[1] + x[2] * x[2]

        result = optimize(
            feval,
            1000,
            maximize = true,
            popsize = 60,
            ndim = 2,
            dmin = 0,
            dmax = 10,
            alg = alg
        )

        @test result.nEvals <= 1000
        @test all(maximum(result.fitness) .>= result.fitness)
        @test all(map(feval, eachrow(result.population)) == result.fitness)
        @test result.population == clamp.(result.population, 0, 10)
    end

    begin
        alg = PSOL()

        feval = x -> x[1] * x[1] + x[2] * x[2]

        result = optimize(
            feval,
            1000,
            maximize = true,
            popsize = 60,
            ndim = 2,
            dmin = 0,
            dmax = 10,
            alg = alg
        )

        @test result.nEvals <= 1000
        @test all(maximum(result.fitness) .>= result.fitness)
        @test all(map(feval, eachrow(result.population)) == result.fitness)
        @test result.population == clamp.(result.population, 0, 10)
    end

end
