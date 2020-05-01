export optimize

function optimize(
   ffitness::Function,
   maxeval::Integer;
   maximize::Bool = true,
   population = missing,
   fitness = missing,
   popsize = missing,
   ndim = missing,
   dmin = missing,
   dmax = missing,
   alg = SSGA,
   fcallback::Function = callback_none,
)

   @assert ((!ismissing(popsize) && !ismissing(ndim)) || !ismissing(population)) "Error, ndim and popsize must be defined"
   @assert dmin < dmax "dmin must be lower than dmax"
   @assert maxeval > 0 "maxeval max be positive"

   if maximize
      fbest = argmax
      fworst = argmin
      cmp = <
   else
      fbest = argmin
      fworst = argmax
      cmp = >
   end

   if ismissing(population)
      population = rand(Uniform(dmin, dmax), popsize, ndim)
   else
      if(ismissing(dmin))
         dmin = floor(minimum(population))
      else
         @assert dmin <= floor(minimum(population)) "dmin no valid"
      end

      if(ismissing(dmin))
         dmax = ceil(maximum(population))
      else
         @assert dmax >= ceil(maximum(population)) "dmax no valid"
      end

      if ismissing(ndim)
         ndim = size(population, 2)
      else
         @assert ndim == size(population, 2)
      end

      if ismissing(popsize)
         popsize = size(population, 1)
      else
         @assert popsize == size(population, 1)
      end
   end

   if ismissing(fitness)
      fitness = map(ffitness, eachrow(population))
      eval = popsize
   else
      @assert (all(fitness == map(ffitness, eachrow(population)))) "Fitness not match to population"
      eval = 0
   end

   alg.nEvals += eval
   alg.population = population
   alg.fitness = fitness

   i = 1
   while alg.nEvals + popsize < maxeval

      optimize!(
         alg,
         ffitness,
         maxeval,
         maximize,
         cmp,
         fbest,
         fworst,
         dmin,
         dmax,
      )

      fcallback(i, alg.population, alg.fitness, fbest)
      i += 1
   end

   return Result(alg.population, alg.fitness, alg.nEvals)
end
