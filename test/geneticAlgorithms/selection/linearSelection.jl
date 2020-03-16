using EvolutionaryAlgs
using StatsBase
using Test


@testset "linearSelection.jl" begin
    @test begin
        n = 5
        repeats = 5000

        index_array = Array{Int64, 1}(undef, repeats)
        prob_array = Array{Int64, 1}(undef, n)

        fitness = rand(n)

        for i in 1:repeats
            index_array[i] = EvolutionaryAlgs.linear_selection(fitness)
        end

        for i in 1:n
            prob_array[i] = count(x->(x==i), index_array)
        end

        sortperm(fitness) == sortperm(prob_array)
    end
end
