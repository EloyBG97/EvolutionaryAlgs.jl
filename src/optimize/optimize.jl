include("../utility/result.jl")

export optimize

"""
$(SIGNATURES)
Optimization\n
ffitness -> Fitness Evaluation Function\n
maxeval -> Max Evaluations Number\n
maximize -> If you want to maximize ffitness\n
population -> \n
fitness -> \n
popsize -> Population size\n
ndim -> Dimension of each Indvidual\n
dmin -> Min Domain Range\n
dmax -> Max Domain Range\n
alg -> Evolutionary Algorithm\n
fcallback -> Callback funtion called each iteration\n
"""
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
   alg = SSGA(),
   fcallback::Function = callback_none,
)

   @assert ((!ismissing(popsize) && !ismissing(ndim)) || !ismissing(population)) "Error, ndim and popsize must be defined"
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

      if(ismissing(dmax))
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
   initialize!(alg, population, fitness)

   i = 1
   
   pop = similar(population)
   fit = similar(fitness)
   eval = 0

   while  alg.nEvals  < maxeval
      pop = copy(population)
      fit = copy(fitness)
      eval = alg.nEvals

      fcallback(eval, alg.population, alg.fitness, fbest)

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

     
      i += 1
   end

   return Result(pop, fit, eval)
end
