using EvolutionaryAlgs
using Test

@testset "normMutation.jl" begin
    @test begin
        p1 = rand(5)

        EvolutionaryAlgs.norm_mutation!(p1)
        true
    end
end
