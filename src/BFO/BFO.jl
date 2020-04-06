include("../utility/callbacks.jl")
include("../utility/result.jl")

function optimizeBFO(
   ffitness::Function,
   maxeval::Integer;
   maximize::Bool = true,
   population::AbstractArray{<:Real,2} = Array{Float32,2}(undef, 0, 0),
   fitness::AbstractArray{<:Real,1} = Array{Float64,1}(undef, 0),
   chemotasticStep::Integer = 20,
   swinStep::Integer = 20,
   reproductiveStep::Integer = 20,
   elimDispStep::Integer = 20,
   Ped::Real = 0.9,
   runLenght::Real = 0.01,
   popsize::Integer = 0,
   ndim::Integer = 0,
   dmin::Real = 0.0,
   dmax::Real = 1.0,
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
      fitness = map(ffitness, eachrow(population)) #fitness
      eval = popsize
   else
      eval = 0
   end

   Jlast = fitness

   for l = 1:elimDispStep
      best = fbest(fitness)
      bestfit = fitness[best]
      bestpop = population[best, :]

      for k = 1:reproductiveStep
         Jchem = fitness
         for j = 1:chemotasticStep
            for m = 1:swinStep
               Jlast = fitness

               del = rand(Uniform(-1, 1), popsize, ndim)

               dotpro = map(eachrow(del)) do x
                  sqrt(x'x)
               end

               population = population + (runLenght ./ dotpro) .* del

               #If JLast is better than fitness
               idx = cmp.(fitness, Jlast)
               population[idx, :] =
                  population[idx, :] +
                  runLenght * (
                     del[idx, :] ./
                     sqrt.(sum(del[idx, :] .* del[idx, :], dims = 2))
                  )

               #If JLast is worse than fitness
               idx = .!idx
               del = rand(Uniform(-1, 1), popsize, ndim)

               population[idx, :] =
                  population[idx, :] +
                  runLenght * (
                     del[idx, :] ./
                     sqrt.(sum(del[idx, :] .* del[idx, :], dims = 2))
                  )

               clamp!(population, dmin, dmax)

               fitness = map(ffitness, eachrow(population))
               eval += popsize

            end

            Jchem = [Jchem fitness]
         end



         Jhealth = reshape(sum(Jchem, dims = 2), popsize)


         I = sortperm(Jhealth, rev = maximize)

         halfidx = I[1:div(popsize, 2)]
         halfpop = population[halfidx, :]
         halffit = fitness[halfidx]

         population = [halfpop; halfpop]
         fitness = [halffit; halffit]
      end


      r = rand(popsize)

      idx = r .> Ped
      n = count(x -> x == 1, idx)

      population[idx, :] = rand(Uniform(dmin, dmax), n, ndim)
      fitness[idx] = map(ffitness, eachrow(population[idx, :]))
      eval += n

      worst = fworst(fitness)
      fitness[worst] = bestfit
      population[worst, :] = bestpop


      fcallback(l, population, fitness, fbest)
   end


   return Result(population, fitness, fbest(fitness), eval)
end
