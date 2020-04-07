include("../utility/selection.jl")
include("../utility/callbacks.jl")
include("util/cross.jl")

using Distributions

export DE

function DE(; fcross::Function = bestCross)
   (population, fitness, ffitness, cmp, fbest, fworst, dmin, dmax) -> privateDE(
      population,
      fitness,
      ffitness,
      cmp,
      fbest,
      fworst,
      dmin,
      dmax,
      fcross = fcross,
   )
end

function privateDE(
   population::AbstractArray{<:Real,2},
   fitness::AbstractArray{<:Real,1},
   ffitness::Function,
   cmp::Function,
   fbest::Function,
   fworst::Function,
   dmin::Real = 0.0,
   dmax::Real = 1.0;
   fcross::Function = bestCross,
)
   popsize = size(population, 1)
   ndim = size(population, 2)
   nextpop = Array{Float32,2}(undef, 0, ndim) #Float32

   map(eachrow(population)) do individual
      #population, fitness
      h = fcross(population, fitness, individual, fbest)

      clamp!(h, dmin, dmax)
      nextpop = [nextpop; h]
   end

   nextfit = map(ffitness, eachrow(nextpop))
   idx = cmp.(fitness, nextfit)

   fitness[idx] = nextfit[idx]
   population[idx, :] = nextpop[idx, :]

   Result(population, fitness, fbest(fitness), popsize)
end
