using EvolutionaryAlgs
using Test


@testset "roulette_wheel_selection" begin
    @test begin
        population = rand(40, 20)
        selectedpop = EvolutionaryAlgs.roulette_wheel_selection(population, sum)

        size(selectedpop, 1) == 20 && size(selectedpop, 2) == 20
    end

    @test begin
        population = rand(43, 20)
        selectedpop = EvolutionaryAlgs.roulette_wheel_selection(population, sum, 0.75)

        size(selectedpop, 1) == 32 && size(selectedpop, 2) == 20
    end

    @test begin
        population = rand(120, 40)
        selectedpop = EvolutionaryAlgs.roulette_wheel_selection(population, sum)

        size(selectedpop, 1) == 60 && size(selectedpop, 2) == 40
    end

    @test begin
        population = rand(503, 75)
        selectedpop = EvolutionaryAlgs.roulette_wheel_selection(population, sum, 0.75)

        size(selectedpop, 1) == 377 && size(selectedpop, 2) == 75
    end
end

@testset "linear_selection" begin
    @test begin
        population = rand(40, 20)
        selectedpop = EvolutionaryAlgs.linear_selection(population, sum)

        size(selectedpop, 1) == 20 && size(selectedpop, 2) == 20
    end

    @test begin
        population = rand(45, 20)
        selectedpop = EvolutionaryAlgs.linear_selection(population, sum, 0.75)

        size(selectedpop, 1) == 33 && size(selectedpop, 2) == 20
    end

    @test begin
        population = rand(129, 40)
        selectedpop = EvolutionaryAlgs.linear_selection(population, sum)

        size(selectedpop, 1) == 64 && size(selectedpop, 2) == 40
    end

    @test begin
        population = rand(500, 75)
        selectedpop = EvolutionaryAlgs.linear_selection(population, sum, 0.75)

        size(selectedpop, 1) == 375 && size(selectedpop, 2) == 75
    end
end

@testset "random_selection" begin
    @test begin
        population = rand(40, 20)
        selectedpop = EvolutionaryAlgs.random_selection(population, sum)

        size(selectedpop, 1) == 20 && size(selectedpop, 2) == 20
    end

    @test begin
        population = rand(45, 20)
        selectedpop = EvolutionaryAlgs.random_selection(population, sum, 0.75)

        size(selectedpop, 1) == 33 && size(selectedpop, 2) == 20
    end

    @test begin
        population = rand(129, 40)
        selectedpop = EvolutionaryAlgs.random_selection(population, sum)

        size(selectedpop, 1) == 64 && size(selectedpop, 2) == 40
    end

    @test begin
        population = rand(500, 75)
        selectedpop = EvolutionaryAlgs.random_selection(population, sum, 0.75)

        size(selectedpop, 1) == 375 && size(selectedpop, 2) == 75
    end
end
