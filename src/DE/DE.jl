include("../utility/selection.jl")
include("../utility/callbacks.jl")
include("util/cross.jl")

using Distributions

function optimizeDE(
   ffitness::Function,
   maxeval::Integer;
   maximize::Bool = true,
   population::AbstractArray{<:Real,2} = Array{Float32,2}(undef, 0, 0),
   fitness::AbstractArray{<:Real,1} = Array{Float64,1}(undef, 0),
   fcross::Function = bestCross,
   popsize::Integer = 0,
   ndim::Integer = 0,
   dmin::Real = 0.0,
   dmax::Real = 1.0,
   fcallback::Function = callback_none,
)

   @assert ((popsize != 0 && ndim != 0) || size(population) != (0, 0)) "Error, ndim and popsize must be defined"
   @assert dmin < dmax "dmin < dmax"

   if maximize
      fworst = argmin
      fbest = argmax
      cmp = <
   else
      fworst = argmax
      fbest = argmin
      cmp = >
   end

   if size(population) == (0, 0)
      population = rand(Uniform(dmin, dmax), popsize, ndim)
   else
      dmin = floor(minimun(population))
      dmax = ceil(maximun(population))

      if ndim == 0
         ndim = size(population, 2)
      else
         @assert ndim == size(population, 2)
      end

      if popsize == 0
         popsize = size(population, 1)
      else
         @assert popsize == size(population, 1)
      end
   end

   if size(fitness) == (0,)
      fitness = map(ffitness, eachrow(population))
      eval = popsize
   else
      eval = 0
   end

   result = Result(population, fitness, fbest(fitness), eval)

   i = 1
   while eval + popsize < maxeval

      result = iterationDE(
         result.population,
         result.fitness,
         ffitness,
         cmp,
         fbest,
         fworst,
         dmin,
         dmax,
         fcross = fcross,
      )

      fcallback(i, population, fitness, fbest)
      eval += result.evals
      i += 1
   end

   return Result(population, fitness, fbest(fitness), eval)
end

function iterationDE(
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
