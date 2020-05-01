include("../utility/callbacks.jl")

export BFO

mutable struct BFOIn
   population::AbstractArray{<:Real, 2}
   fitness::AbstractArray{<:Real, 1}
   nEvals::Integer
   chemostaticStep::Integer
   swimStep::Integer
   reproductiveStep::Integer
   Ped::Real
   runLength::Real
end

function setData!(self::BFOIn, population::AbstractArray{<:Real, 2}, fitness::AbstractArray{<:Real, 1})
   self.population = population
   self.fitness = fitness
end

function BFO(;
   chemostaticStep::Integer = 20,
   swimStep::Integer = 20,
   reproductiveStep::Integer = 20,
   Ped::Real = 0.9,
   runLength::Real = 0.01
)
   BFOIn(Array{Float32}(undef, 0, 0), Array{Float32}(undef, 0), 0, chemostaticStep, swimStep, reproductiveStep, Ped, runLength)

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
   dmax::Real = 1.0;
)
   Jlast = input.fitness

   popsize = size(input.population, 1)
   ndim = size(input.population, 2)

   best = fbest(input.fitness)
   bestfit =input.fitness[best]
   bestpop = input.population[best, :]

   k = 0

   while k < input.reproductiveStep && (input.nEvals + popsize) < maxeval
      Jchem =input.fitness
      j = 0

      while j < input.chemostaticStep && (input.nEvals + popsize) < maxeval
         m = 0

         while m < input.swimStep && (input.nEvals + popsize) < maxeval
            Jlast = input.fitness

            del = rand(Uniform(-1, 1), popsize, ndim)

            dotpro = map(eachrow(del)) do x
               sqrt(x'x)
            end

            input.population = input.population + (input.runLength ./ dotpro) .* del

            #If JLast is better than fitness
            idx = cmp.(input.fitness, Jlast)
            input.population[idx, :] =
               input.population[idx, :] +
               input.runLength * (
                  del[idx, :] ./
                  sqrt.(sum(del[idx, :] .* del[idx, :], dims = 2))
               )

            #If JLast is worse than fitness
            idx = .!idx
            del = rand(Uniform(-1, 1), popsize, ndim)

            input.population[idx, :] =
               input.population[idx, :] +
               input.runLength * (
                  del[idx, :] ./
                  sqrt.(sum(del[idx, :] .* del[idx, :], dims = 2))
               )

            clamp!(input.population, dmin, dmax)

            input.fitness = map(ffitness, eachrow(input.population))
            
            input.nEvals += popsize

         end

         Jchem = [Jchem input.fitness]
      end



      Jhealth = reshape(sum(Jchem, dims = 2), popsize)


      I = sortperm(Jhealth, rev = maximize)

      halfidx = I[1:div(popsize, 2)]
      halfpop = input.population[halfidx, :]
      halffit = input.fitness[halfidx]

      input.population = [halfpop; halfpop]
      input.fitness = [halffit; halffit]
   end


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
end
