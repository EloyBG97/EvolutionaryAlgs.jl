include("../utility/callbacks.jl")
include("../utility/result.jl")

export BFO

function BFO(;
   chemotasticStep::Integer = 20,
   swinStep::Integer = 20,
   reproductiveStep::Integer = 20,
   Ped::Real = 0.9,
   runLenght::Real = 0.01
)

   (result, ffitness, maxeval, maximize, cmp, fbest, fworst, dmin, dmax) -> 
      
      iterateBFO(result, ffitness, maxeval, maximize, cmp,  fbest, fworst,
         dmin, dmax, chemotasticStep = chemotasticStep, swinStep = swinStep, 
         reproductiveStep = reproductiveStep, Ped = Ped, runLenght = runLenght)

end

function iterateBFO(
   result::Result,
   ffitness::Function,
   maxeval::Integer,
   maximize::Bool,
   cmp::Function,
   fbest::Function,
   fworst::Function,
   dmin::Real = 0.0,
   dmax::Real = 1.0;

   chemotasticStep::Integer = 20,
   swinStep::Integer = 20,
   reproductiveStep::Integer = 20,
   Ped::Real = 0.9,
   runLenght::Real = 0.01,

)
   eval = 0
   Jlast =result.fitness

   popsize = size(result.population, 1)
   ndim = size(result.population, 2)

   best = fbest(result.fitness)
   bestfit =result.fitness[best]
   bestpop = result.population[best, :]

   k = 0

   while k < reproductiveStep && (eval + popsize) < maxeval
      Jchem =result.fitness
      j = 0

      while j < chemotasticStep && (eval + popsize) < maxeval
         m = 0

         while m < swinStep && (eval + popsize) < maxeval
            Jlast =result.fitness

            del = rand(Uniform(-1, 1), popsize, ndim)

            dotpro = map(eachrow(del)) do x
               sqrt(x'x)
            end

            result.population = result.population + (runLenght ./ dotpro) .* del

            #If JLast is better thanresult.fitness
            idx = cmp.(result.fitness, Jlast)
            result.population[idx, :] =
               result.population[idx, :] +
               runLenght * (
                  del[idx, :] ./
                  sqrt.(sum(del[idx, :] .* del[idx, :], dims = 2))
               )

            #If JLast is worse thanresult.fitness
            idx = .!idx
            del = rand(Uniform(-1, 1), popsize, ndim)

            result.population[idx, :] =
               result.population[idx, :] +
               runLenght * (
                  del[idx, :] ./
                  sqrt.(sum(del[idx, :] .* del[idx, :], dims = 2))
               )

            clamp!(result.population, dmin, dmax)

           result.fitness = map(ffitness, eachrow(result.population))
            eval += popsize

         end

         Jchem = [Jchem result.fitness]
      end



      Jhealth = reshape(sum(Jchem, dims = 2), popsize)


      I = sortperm(Jhealth, rev = maximize)

      halfidx = I[1:div(popsize, 2)]
      halfpop = result.population[halfidx, :]
      halffit =result.fitness[halfidx]

      result.population = [halfpop; halfpop]
     result.fitness = [halffit; halffit]
   end


   r = rand(popsize)

   idx = r .> Ped
   n = count(x -> x == 1, idx)

   result.population[idx, :] = rand(Uniform(dmin, dmax), n, ndim)
   result.fitness[idx] = map(ffitness, eachrow(result.population[idx, :]))
   eval += n

   worst = fworst(result.fitness)
   result.fitness[worst] = bestfit
   result.population[worst, :] = bestpop

   return Result(result.population,result.fitness, fbest(result.fitness), eval)

end
