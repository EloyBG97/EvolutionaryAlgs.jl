include("../utility/selection.jl")
include("../utility/callbacks.jl")
include("util/cross.jl")

using Distributions

export DE

function DE(; fcross::Function = bestCross)
   (result, ffitness,maxeval, maximize, cmp, fbest, fworst, dmin, dmax) -> privateDE(
      result,
      ffitness,
      maxeval,
      maximize,
      cmp,
      fbest,
      fworst,
      dmin,
      dmax,
      fcross = fcross,
   )
end

function privateDE(
   input::Result,
   ffitness::Function,
   maxeval::Integer,
   maximize::Bool,
   cmp::Function,
   fbest::Function,
   fworst::Function,
   dmin::Real = 0.0,
   dmax::Real = 1.0;
   fcross::Function = bestCross,
)
   popsize = size(input.population, 1)
   ndim = size(input.population, 2)
   nextpop = Array{Float32,2}(undef, 0, ndim) #Float32

   map(eachrow(input.population)) do individual
      #input.population, input.fitness
      h = fcross(input.population, input.fitness, individual, fbest)

      clamp!(h, dmin, dmax)
      nextpop = [nextpop; h]
   end

   nextfit = map(ffitness, eachrow(nextpop))
   idx = cmp.(input.fitness, nextfit)

   input.fitness[idx] = nextfit[idx]
   input.population[idx, :] = nextpop[idx, :]

   Result(input.population, input.fitness, fbest(input.fitness), popsize)
end
