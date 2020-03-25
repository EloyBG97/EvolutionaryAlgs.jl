using EvolutionaryAlgs
using StatsBase
using Test


@testset "rouletteWheelSelection.jl" begin
    @test begin
        n = 5
        repeats = 5000

        index_array = Array{Int64, 1}(undef, repeats)
        prob_array = Array{Int64, 1}(undef, n)

        population = rand(n, 6)
        fitness = rand(n)

        for i in 1:repeats
            index_array[i] = EvolutionaryAlgs.roulette_wheel_selection(population, fitness)
        end

        for i in 1:n
            prob_array[i] = count(x->(x==i), index_array)
        end

        sortperm(fitness) == sortperm(prob_array)
    end
end
