using EvolutionaryAlgs
using Test


@testset "PSO.jl" begin
    @test begin
        pop, fit = EvolutionaryAlgs.optimizePSOGlobal(x -> -x[1]*x[1] - x[2]*x[2] , 500, maximize = true, popsize = 30, ndim = 2, dmin = -10, dmax = 10, fcallback = EvolutionaryAlgs.callback_print)
        true
    end

    @test begin
        pop, fit = EvolutionaryAlgs.optimizePSOLocal(x -> -x[1]*x[1] - x[2]*x[2] , 500, maximize = true, popsize = 30, ndim = 2, dmin = -10, dmax = 10, fcallback = EvolutionaryAlgs.callback_print)
        true
    end

end
