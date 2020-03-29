using EvolutionaryAlgs
using Test

@testset "bestCross.jl" begin
    @test begin
        current = rand(5)
        best = rand(5)
        parent1 = rand(5)
        parent2 = rand(5)

        @assert size(current) == size(best)
        @assert size(current) == size(parent1)
        @assert size(current) == size(parent2)

        h = EvolutionaryAlgs.bestCross(current, best, parent1, parent2)

        println(h)
        size(h) == size(current)
    end
end
