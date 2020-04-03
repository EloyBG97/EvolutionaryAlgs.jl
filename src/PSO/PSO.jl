include("../utility/callbacks.jl")
function optimizePSO(
   ffitness::Function,
   maxeval::Integer;
   maximize::Bool = true,
   population::AbstractArray{<:Real,2} = Array{Real,2}(undef, 0, 0),
   fitness::AbstractArray{<:Real,1} = Array{Real,1}(undef, 0),
   popsize::Integer = 0,
   ndim::Integer = 0,
   dmin::Real = 0.0,
   dmax::Real = 1.0,
   vmin::Real = 0.0,
   vmax::Real = 1.0,
   phi1::Real = 1.05,
   phi2::Real = 1.05,
   fcallback::Function = callback_none,
)

   @assert ((popsize != 0 && ndim != 0) || size(population) != (0, 0)) "Error, ndim and popsize must be defined"
   @assert dmin < dmax "dmin < dmax"

   if maximize
      fbest = x -> argmax(x)
      fworst = x -> argmin(x)

      cmp = (a, b) -> a < b
   else
      fbest = x -> argmin(x)
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

   #Best particle position
   popBest = population

   #Best particle fitness
   fitBest = fitness

   best = fbest(fitBest)

   #Best global position
   gBestPop = popBest[best, :]

   #Best global fitness
   gBestFit = fitBest[best]


   velocity = rand(Uniform(vmin, vmax), popsize, ndim)

   i = 0
   while eval < maxeval
      velocity =
         velocity +
         phi1 * rand(popsize) .* (popBest - population) +
         phi2 * rand(popsize) .* (reshape(gBestPop, 1, ndim) .- population)


      #Test Range Velocity Domain
      idx = map(x -> x > vmax, velocity)
      n = count(x -> x == 1, idx)

      velocity[idx] = ones(n) * vmax

      idx = map(x -> x < vmin, velocity)
      n = count(x -> x == 1, idx)

      velocity[idx] = ones(n) * vmin


      population = population + velocity

      #Test Range Domain
      idx = map(x -> x > dmax, population)
      n = count(x -> x == 1, idx)

      population[idx] = ones(n) * dmax

      idx = map(x -> x < dmin, population)
      n = count(x -> x == 1, idx)

      population[idx] = ones(n) * dmin


      fitness = map(ffitness, eachrow(population))
      eval = eval + popsize

      idxBetter = map(cmp, fitBest, fitness)

      fitBest[idxBetter] = fitness[idxBetter]
      popBest[idxBetter, :] = population[idxBetter, :]

      best = fbest(fitBest)
      gBestPop = popBest[best, :]
      gBestFit = fitBest[best]

      fcallback(i, popBest, fitBest, fbest = fbest)
      i = i + 1
   end

   return popBest, fitBest
end
