using EvolutionaryAlgs
using Test

@testset "BlxCross.jl" begin
    @test begin
        p1 = rand(5)
        p2 = rand(5)

        h = EvolutionaryAlgs.blx_cross(p1, p2)
        true
    end
end
