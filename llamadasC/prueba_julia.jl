using EvolutionaryAlgs

include("call_funciones.jl")

feval = cec2020_function(1)

alg = DE(fcross = EvolutionaryAlgs.current2bestCross)



result = optimize(
         feval,
         1000,
         maximize = true,
         population = rand(60, 2),
         dmin = 0,
         dmax = 10,
         alg = alg,
     )

