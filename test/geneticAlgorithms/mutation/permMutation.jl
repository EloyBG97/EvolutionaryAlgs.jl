using EvolutionaryAlgs
using Test

@testset "permMutation.jl" begin
    @test begin
        p1 = rand(5)

        EvolutionaryAlgs.perm_mutation!(p1)
    end
end
