using EvolutionaryAlgs
using Test

@testset "permMutation.jl" begin
    begin
        p1 = rand(5)

        EvolutionaryAlgs.perm_mutation!(p1)
        @test true
    end
end
