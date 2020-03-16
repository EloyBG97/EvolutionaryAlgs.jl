using EvolutionaryAlgs
using Test

@testset "BlxCross.jl" begin
    @test begin
        p1 = rand(5)
        p2 = rand(5)
        alph = 0.3

        h = EvolutionaryAlgs.blx_cross(p1, p2,  alpha = alph)

        c = [p1 p2]
        c_max = map(maximum, eachrow(c))
        c_min = map(minimum, eachrow(c))

        i = c_max - c_min

        sup = c_max + i * alph
        inf = c_min - i * alph

        a = map(isless, eachcol(h), eachcol(sup))
        b = map(isless, eachcol(inf), eachcol(h))

        a1 = reduce(&,a)
        b1 = reduce(&,b)

        b1 && a1
    end
end
