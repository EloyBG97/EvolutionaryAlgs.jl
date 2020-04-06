include("../utility/callbacks.jl")
include("util/enviroment.jl")
include("../utility/result.jl")


function optimizePSOGlobal(
   ffitness::Function,
   maxeval::Integer;
   maximize::Bool = true,
   population::AbstractArray{<:Real,2} = Array{Float32,2}(undef, 0, 0),
   fitness::AbstractArray{<:Real,1} = Array{Float64,1}(undef, 0),
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
      fbest = argmax
      fworst = argmin

      cmp = (a, b) -> a < b
   else
      fbest = x -> argmin(x)
      fworst = x -> argmax(x)

      cmp = (a, b) -> a > b
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
   while eval + popsize < maxeval
      velocity =
         velocity +
         phi1 * rand(popsize) .* (popBest - population) +
         phi2 * rand(popsize) .* (reshape(gBestPop, 1, ndim) .- population)


      clamp!(velocity, vmin, vmax)

      population = population + velocity
      clamp!(population, dmin, dmax)

      fitness = map(ffitness, eachrow(population))

      idxBetter = cmp.(fitBest, fitness)

      fitBest[idxBetter] .= fitness[idxBetter]
      popBest[idxBetter, :] .= population[idxBetter, :]

      best = fbest(fitBest)
      gBestPop = popBest[best, :]
      gBestFit = fitBest[best]

      fcallback(i, popBest, fitBest, fbest)
      eval = eval + popsize
      i = i + 1
   end

   return Result(popBest, fitBest, fbest(fitBest), eval)
end



function optimizePSOLocal(
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
   sizeEnv::Integer = 3,
   fcallback::Function = callback_none,
)

   @assert ((popsize != 0 && ndim != 0) || size(population) != (0, 0)) "Error, ndim and popsize must be defined"
   @assert dmin < dmax "dmin < dmax"

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

   #Best particle position
   popBest = population

   #Best particle fitness
   fitBest = fitness

   best = fbest(fitBest)



   velocity = rand(Uniform(vmin, vmax), popsize, ndim)

   i = 0
   while eval < maxeval
      #Find Enviroment
      bestEnvPop = findEnviroment(population, fitness, fbest, sizeEnv)

      velocity =
         velocity +
         phi1 * rand(popsize) .* (popBest - population) +
         phi2 * rand(popsize) .* (bestEnvPop .- population)


      #Test Range Velocity Domain
      clamp!(velocity, dmin, dmax)

      population = population + velocity

      #Test Range Domain
      clamp!(population, dmin, dmax)


      fitness = map(ffitness, eachrow(population))
      eval = eval + popsize

      idxBetter = cmp.(fitBest, fitness)

      fitBest[idxBetter] .= fitness[idxBetter]
      popBest[idxBetter, :] .= population[idxBetter, :]


      fcallback(i, popBest, fitBest, fbest)
      i = i + 1
   end

   return Result(popBest, fitBest, fbest(fitBest), eval)
end
