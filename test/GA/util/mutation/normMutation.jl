using EvolutionaryAlgs
using Test

@testset "normMutation.jl" begin
    begin
        p1 = rand(5)

        EvolutionaryAlgs.norm_mutation!(p1)
        @test true
    end
end
