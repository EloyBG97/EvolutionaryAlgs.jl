using EvolutionaryAlgs
using Test


@testset "geneticAlgorithms.jl" begin
     # Write your own tests here.
    include("selection/selection.jl")
    include("cross/cross.jl")
    include("mutation/mutation.jl")

    @test begin
        pop, fit = EvolutionaryAlgs.optimizeGGA(x -> x[1]*x[1] + x[2]*x[2] , 1000, popsize=6, ndim = 2, dmin = 0, dmax = 10)
        true
    end

    @test begin
        pop, fit = EvolutionaryAlgs.optimizeEGA(x -> x[1]*x[1] + x[2]*x[2] , 1000, popsize=6, ndim = 2, dmin = 0, dmax = 10)
        true
    end

end
