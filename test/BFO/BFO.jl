using EvolutionaryAlgs
using Test


@testset "BFO.jl" begin
    @test begin
        pop, fit = EvolutionaryAlgs.optimizeBFO(x -> x[1]*x[1] + x[2]*x[2] , 1000, maximize = true, popsize = 60, ndim = 2, dmin = 0, dmax = 10, fcallback = EvolutionaryAlgs.callback_print)
        true
    end

end
