using EvolutionaryAlgs
using Test


@testset "differentialEvolution.jl" begin
     # Write your own tests here.
    # include("selection/selection.jl")
    # include("cross/cross.jl")
    # include("mutation/mutation.jl")

    @test begin
        pop, fit = EvolutionaryAlgs.optimizeDE(x -> x[1]*x[1] + x[2]*x[2] , 1000, popsize=6, fcross = EvolutionaryAlgs.current2bestCross, ndim = 2, dmin = 0, dmax = 10, fcallback = EvolutionaryAlgs.callback_print)
        true
    end

end
