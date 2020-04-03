include("../utility/selection.jl")
include("../utility/callbacks.jl")
include("../utility/DE/cross.jl")

using Distributions

function optimizeDE(
   ffitness::Function,
   maxeval::Integer;
   maximize::Bool = true,
   population::AbstractArray{<:Real,2} = Array{Real,2}(undef, 0, 0),
   fitness::AbstractArray{<:Real,1} = Array{Real,1}(undef, 0),
   fcross::Function = bestCross,
   fselect::Function = roulette_wheel_selection,
   popsize::Integer = 0,
   ndim::Integer = 0,
   dmin::Real = 0.0,
   dmax::Real = 1.0,
   fcallback::Function = callback_none,
)

   @assert ((popsize != 0 && ndim != 0) || size(population) != (0, 0)) "Error, ndim and popsize must be defined"
   @assert dmin < dmax "dmin < dmax"

   if maximize
      fworst = x -> argmin(x)
      fbest = x -> argmax(x)
      cmp = (a, b) -> a < b
   else
      fworst = x -> argmax(x)
      fbest = x -> argmin(x)
      cmp = (a, b) -> a > b
   end

   if size(population) == (0, 0)
      population = rand(Uniform(dmin, dmax), popsize, ndim)
   else
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

   i = 1
   while eval < maxeval
      nextpop = Array{Real,2}(undef, 0, ndim)
      nextfit = Array{Real,1}(undef, 0)

      best = fbest(fitness)
      pop_best = population[best, :]

      map(eachrow(population)) do individual
         p1_idx = fselect(population, fitness)

         p2_idx = fselect(population, fitness)

         while p1_idx == p2_idx
            p2_idx = fselect(population, fitness)
         end

         p1 = population[p1_idx, :]
         p2 = population[p2_idx, :]


         h = fcross(individual, pop_best, p1, p2, dmin = dmin, dmax = dmax)


         fit_children = ffitness(h)
         eval += 1

         nextfit = [nextfit; fit_children]
         nextpop = [nextpop; h]
      end

      for i = 1:popsize
         if cmp(fitness[i], nextfit[i])
            fitness[i] = nextfit[i]
            population[i, :] = nextpop[i, :]
         end
      end


      fcallback(i, population, fitness, fbest = fbest)
      i += 1
   end

   return population, fitness
end
