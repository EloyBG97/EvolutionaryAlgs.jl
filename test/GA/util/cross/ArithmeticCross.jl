using EvolutionaryAlgs
using Test

@testset "ArithmeticCross.jl" begin
    begin
        p1 = rand(5)
        p2 = rand(5)

        h = EvolutionaryAlgs.arithmetic_cross(p1, p2)

        @test h == reshape((p1 + p2) / 2, 1, 5)
    end
end
