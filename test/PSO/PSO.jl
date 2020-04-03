using EvolutionaryAlgs
using Test


@testset "PSO.jl" begin
    @test begin
        pop, fit = EvolutionaryAlgs.optimizePSO(x -> x[1]*x[1] + x[2]*x[2] , 1000, maximize = true, popsize = 5, ndim = 2, dmin = 0, dmax = 10, fcallback = EvolutionaryAlgs.callback_print)
        true
    end

end
