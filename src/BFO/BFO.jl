export BFO

mutable struct BFOIn
   population::AbstractArray{<:Real, 2}
   fitness::AbstractArray{<:Real, 1}
   nEvals::Integer
   chemotacticStep::Integer
   swimStep::Integer
   reproductiveStep::Integer
   eliminationStep::Integer
   Ped::Real
   runLength::Real
end

function initialize!(self::BFOIn, population::AbstractArray{<:Real, 2}, fitness::AbstractArray{<:Real, 1})
   self.population = population
   self.fitness = fitness
   nothing
end

"""
$(SIGNATURES)
Bacterial Foraging\n
chemotacticStep -> Number of movements of each bacteria\n
swimStep -> Number of swims in each movemet\n
reproductiveStep -> Number of reproduction of each generation\n
Ped -> Dispersion/elimination probability\n
runLength -> Distance of each run\n
"""
function BFO(;
   chemotacticStep::Integer = 20,
   swimStep::Integer = 20,
   reproductiveStep::Integer = 20,
   eliminationStep::Integer = 20,
   Ped::Real = 0.9,
   runLength::Real = 0.01
)
   BFOIn(Array{Float32}(undef, 0, 0), Array{Float32}(undef, 0), 0, chemotacticStep, swimStep, reproductiveStep, eliminationStep, Ped, runLength)

end

function optimize!(
   input::BFOIn,
   ffitness::Function,
   maxeval::Integer,
   maximize::Bool,
   cmp::Function,
   fbest::Function,
   fworst::Function,
   dmin::Real = 0.0,
   dmax::Real = 1.0
)
   Jlast = input.fitness
   lastpop = input.population

   popsize = size(input.population, 1)
   ndim = size(input.population, 2)

   best = fbest(input.fitness)
   bestfit =input.fitness[best]
   bestpop = input.population[best, :]

   i = 0
   while i < input.eliminationStep && (input.nEvals + popsize) < maxeval
   
   k = 0

      while k < input.reproductiveStep && (input.nEvals + popsize) < maxeval
         Jchem =input.fitness
         j = 0

         while j < input.chemotacticStep && (input.nEvals + popsize) < maxeval
            m = 0
	    letswim = ones(popsize)
            

            while m < input.swimStep && (input.nEvals + popsize) < maxeval
               del = rand(Uniform(-1, 1), popsize, ndim)

               dotpro = map(eachrow(del)) do x
                  sqrt(x'x)
               end

               input.population = input.population + (input.runLength ./ dotpro) .* del

               #If JLast is better than fitness
               idx = cmp.(input.fitness, Jlast)
               idx = idx .& letswim
               Jlast[idx] = input.fitness[idx]
               input.population[idx, :] =
                 input.population[idx, :] +
                  input.runLength * (
                     del[idx, :] ./
                     sqrt.(sum(del[idx, :] .* del[idx, :], dims = 2))
                  )

               #If JLast is worse than fitness
               idx = .!idx
               letswim[idx] = zeros(sum(idx))

               clamp!(input.population, dmin, dmax)

               input.fitness = map(ffitness, eachrow(input.population))
            
               input.nEvals += popsize

            end #END SWIM

            Jchem = [Jchem input.fitness]
         end #END CHEMOTAXIS



         Jhealth = reshape(sum(Jchem, dims = 2), popsize)


         I = sortperm(Jhealth, rev = maximize)

         halfidx = I[1:div(popsize, 2)]
         halfpop = input.population[halfidx, :]
         halffit = input.fitness[halfidx]

         input.population = [halfpop; halfpop]
         input.fitness = [halffit; halffit]
      end #END REPRODUCTION


      r = rand(popsize)

      idx = r .> input.Ped
      n = count(x -> x == 1, idx)

      if(input.nEvals + n > maxeval)
         idx = idx[:maxevals]
      end

      input.population[idx, :] = rand(Uniform(dmin, dmax), n, ndim)
      input.fitness[idx] = map(ffitness, eachrow(input.population[idx, :]))
   
      input.nEvals += length(idx)

      worst = fworst(input.fitness)
      input.fitness[worst] = bestfit
      input.population[worst, :] = bestpop

      nothing
   end #END DISPERSION
end
