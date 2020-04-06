include("../utility/selection.jl")
include("util/cross.jl")
include("util/mutation.jl")
include("../utility/callbacks.jl")
include("../utility/result.jl")


using Distributions

function optimizeSSGA(
   ffitness::Function,
   maxeval::Integer;
   maximize::Bool = true,
   population::AbstractArray{<:Real,2} = Array{Real,2}(undef, 0, 0),
   fitness::AbstractArray{<:Real,1} = Array{Real,1}(undef, 0),
   fcross::Function = blx_cross,
   fselect::Function = roulette_wheel_selection,
   fmutation::Function = norm_mutation!,
   pmutation::Real = 0.3,
   popsize::Integer = 0,
   ndim::Integer = 0,
   dmin::Real = 0.0,
   dmax::Real = 1.0,
   fcallback::Function = callback_none,
)

   @assert ((popsize != 0 && ndim != 0) || size(population) != (0, 0)) "Error, ndim and popsize must be defined"

   if maximize
      fbest = argmax
      fworst = argmin
      cmp = <
   else
      fbest = argmin
      fworst = argmax
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

      result = iterationSSGA(
         result.population,
         result.fitness,
         ffitness,
         cmp,
         fbest,
         fworst,
         dmin,
         dmax,
         fcross = fcross,
         fselect = fselect,
         fmutation = fmutation,
         pmutation = pmutation,
      )

      fcallback(i, population, fitness, fbest)
      eval += result.evals
      i += 1
   end

   return Result(population, fitness, fbest(fitness), eval)
end

function iterationSSGA(
   population::AbstractArray{<:Real,2},
   fitness::AbstractArray{<:Real,1},
   ffitness::Function,
   cmp::Function,
   fbest::Function,
   fworst::Function,
   dmin::Real = 0.0,
   dmax::Real = 1.0;
   fcross::Function = blx_cross,
   fselect::Function = roulette_wheel_selection,
   fmutation::Function = norm_mutation!,
   pmutation::Real = 0.3,
)

   p1_idx = fselect(population, fitness)
   p2_idx = fselect(population, fitness)

   while p1_idx == p2_idx
      p2_idx = fselect(population, fitness)
   end

   p1 = population[p1_idx, :]
   p2 = population[p2_idx, :]

   h = fcross(p1, p2)

   map(eachrow(h)) do x
      if pmutation < rand()
         fmutation(x)
      end
   end

   clamp!(h, dmin, dmax)

   fit_children = map(ffitness, eachrow(h))

   map(eachrow(h), fit_children) do x, y
      worst = fworst(fitness)

      if cmp(fitness[worst], y)
         population[worst, :] = x
         fitness[worst] = y
      end
   end

   return Result(population, fitness, fbest(fitness), length(fit_children))
end

function optimizeGGA(
   ffitness::Function,
   maxeval::Integer;
   maximize::Bool = true,
   population::AbstractArray{<:Real,2} = Array{Real,2}(undef, 0, 0),
   fitness::AbstractArray{<:Real,1} = Array{Real,1}(undef, 0),
   fcross::Function = blx_cross,
   fselect::Function = roulette_wheel_selection,
   fmutation::Function = norm_mutation!,
   pmutation::Real = 0.3,
   pcross::Real = 0.7,
   popsize::Integer = 0,
   ndim::Integer = 0,
   dmin::Real = 0.0,
   dmax::Real = 1.0,
   fcallback::Function = callback_none,
)

   @assert ((popsize != 0 && ndim != 0) || size(population) != (0, 0)) "Error, ndim and popsize must be defined"

   if maximize
      fbest = argmax
      fworst = argmin
   else
      fbest = argmin
      fworst = argmax
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

   i = 1


   result = Result(population, fitness, fbest(fitness), eval)

   i = 1
   while eval + popsize < maxeval

      result = iterationGGA(
         result.population,
         result.fitness,
         ffitness,
         cmp,
         fbest,
         fworst,
         dmin,
         dmax,
         fcross = fcross,
         fselect = fselect,
         fmutation = fmutation,
         pmutation = pmutation,
         pcross = pcross,
      )

      fcallback(i, population, fitness, fbest)
      eval += result.evals
      i += 1
   end


   return Result(population, fitness, fbest(fitness), eval)
end

function iterationGGA(
   population::AbstractArray{<:Real,2},
   fitness::AbstractArray{<:Real,1},
   ffitness::Function,
   cmp::Function,
   fbest::Function,
   fworst::Function,
   dmin::Real = 0.0,
   dmax::Real = 1.0;
   fcross::Function = blx_cross,
   fselect::Function = roulette_wheel_selection,
   fmutation::Function = norm_mutation!,
   pmutation::Real = 0.3,
   pcross::Real = 0.7,
)
   popsize = size(population, 1)
   ndim = size(population, 2)

   nextpop = Array{Real,2}(undef, 0, ndim)
   nextfit = Array{Real,1}(undef, 0)

   ncross = ceil(pcross * popsize)

   fit_children = nothing

   for _ = 1:ncross
      p1_idx = fselect(population, fitness)

      p2_idx = fselect(population, fitness)

      while p2_idx == p1_idx
         p2_idx = fselect(population, fitness)
      end

      p1 = population[p1_idx, :]
      p2 = population[p2_idx, :]


      h = fcross(p1, p2)


      map(eachrow(h)) do x
         if pmutation < rand()
            fmutation(x)
         end
      end

      clamp!(h, dmin, dmax)

      nextpop = [nextpop; h]

      fit_children = map(ffitness, eachrow(h))

      nextfit = [nextfit; fit_children]
   end

   eval = length(fit_children)

   bestnextpop = sortperm(nextfit)
   nextpop = nextpop[bestnextpop, :]
   nextfit = nextfit[bestnextpop]

   #Elitism
   best = fbest(fitness)
   bestpop = population[best, :]
   bestfit = fitness[best]

   population = nextpop[1:popsize, :]
   fitness = nextfit[1:popsize]

   worst = fworst(fitness)
   fitness[worst] = bestfit
   population[worst, :] = bestpop

   return Result(population, fitness, fbest(fitness), ncross * eval)

end
