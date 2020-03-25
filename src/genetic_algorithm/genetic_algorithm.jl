include("selection.jl")
include("cross.jl")
include("mutation.jl")


using Distributions

function callback_none(i, population, fitness)
   nothing
end

function optimizeEGA(
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
      fworst = x -> argmin(x)
      cmp = (a, b) -> a < b
   else
      fworst = x -> argmax(x)
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
      p1_idx = fselect(population, fitness)
      p2_idx = fselect(population, fitness)

      while p1_idx == p2_idx
         p2_idx = fselect(population, fitness)
      end

      p1 = population[p1_idx, :]
      p2 = population[p2_idx, :]

      h = fcross(p1, p2, dmin = dmin, dmax = dmax)

      map(eachrow(h)) do x
         if pmutation < rand()
            fmutation(x, dmin = dmin, dmax = dmax)
         end
      end

      fit_children = map(ffitness, eachrow(h))
      eval += length(fit_children)


      map(eachrow(h), fit_children) do x, y
         worst = fworst(fitness)

         if cmp(fitness[worst], y)
            population[worst, :] = x
            fitness[worst] = y
         end
      end

      fcallback(i, population, fitness)
      i += 1
   end

   return population, fitness
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
      fbest = x -> argmax(x)
      fworst = x -> argmin(x)
   else
      fbest = x -> argmin(x)
      fworst = x -> argmax(x)
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

   ncross = ceil(pcross * popsize)

   while eval < maxeval
      nextpop = Array{Real,2}(undef, 0, ndim)
      nextfit = Array{Real,1}(undef, 0)

      for _ in 1:ncross

         p1_idx = fselect(population, fitness)

         p2_idx = fselect(population, fitness)

         while p2_idx == p1_idx
            p2_idx = fselect(population, fitness)
         end

         p1 = population[p1_idx, :]
         p2 = population[p2_idx, :]


         h = fcross(p1, p2, dmin = dmin, dmax = dmax)


         map(eachrow(h)) do x
            if pmutation < rand()
               fmutation(x, dmin = dmin, dmax = dmax)
            end
         end


         nextpop = [nextpop; h]

         fit_children = map(ffitness, eachrow(h))
         eval += length(fit_children)
         nextfit = [nextfit; fit_children]


      end


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

      fcallback(i, population, fitness)
      i += 1
   end


   return population, fitness
end
