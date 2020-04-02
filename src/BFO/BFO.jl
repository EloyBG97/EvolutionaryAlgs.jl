include("../utility/callbacks.jl")
function optimizeBFO(
   ffitness::Function,
   maxeval::Integer;
   maximize::Bool = true,
   population::AbstractArray{<:Real,2} = Array{Real,2}(undef, 0, 0),
   fitness::AbstractArray{<:Real,1} = Array{Real,1}(undef, 0),
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
               idx = map((x, y) -> cmp(x, y), fitness, Jlast)
               dotpro = map(eachrow(del[idx, :])) do x
                  sqrt(x'x)
               end

               population[idx, :] + runLenght * (del[idx, :] ./ dotpro)

               #If JLast is worse than fitness
               idx = [!i for i in idx]
               del = rand(Uniform(-1, 1), popsize, ndim)
               dotpro = map(eachrow(del[idx, :])) do x
                  sqrt(x'x)
               end

               population[idx, :] =
                  population[idx, :] + runLenght * (del[idx, :] ./ dotpro)

               #Test Range Domain
               idx = map(x -> x > dmax, population)
               n = count(x -> x == 1, idx)

               population[idx] = ones(n) * dmax

               idx = map(x -> x < dmin, population)
               n = count(x -> x == 1, idx)

               population[idx] = ones(n) * dmin

               fitness = map(ffitness, eachrow(population))

            end

            Jchem = [Jchem fitness]
         end



         Jhealth = reshape(sum(Jchem, dims = 2), popsize)


         I = sortperm(Jhealth, rev = maximize)
         Jhealth1 = Jhealth[I]

         halfidx = I[1:div(popsize, 2)]
         halfpop = population[halfidx, :]
         halffit = fitness[halfidx]

         population = [halfpop; halfpop]
         fitness = [halffit; halffit]
      end


      r = rand(popsize)

      idx = map(x -> x > Ped, r)
      n = count(x -> x == 1, idx)

      population[idx, :] = rand(Uniform(dmin, dmax), n, ndim)
      fitness[idx] = map(ffitness, eachrow(population[idx, :]))

      worst = fworst(fitness)
      fitness[worst] = bestfit
      population[worst, :] = bestpop


      fcallback(l, population, fitness, best = fbest)
   end

   return population, fitness
end
