include("utility/Gconstant.jl")

export GSA

mutable struct GSAIn
   population::AbstractArray{<:Real, 2} 
   fitness::AbstractArray{<:Real, 1}
   nEvals::Integer
   nIter::Integer
   velocity::AbstractArray{<:Real, 2}

   g_constant::Function
   final_per::Integer
   G0::Real
   alpha::Real
end


function initialize!(self::GSAIn, population::AbstractArray{<:Real, 2}, fitness::AbstractArray{<:Real, 1})
   self.population = population
   self.fitness = fitness
   
   self.velocity = zeros(size(population))
   nothing
end

function GSA(;
   g_constant::Function = g_constant,
   final_per::Integer = 2,
   G0::Real = 100000,
   alpha::Real = 15
)

   GSAIn(Array{Float32}(undef, 0, 0), Array{Float32}(undef, 0), 0, 0,Array{Float32}(undef, 0, 0), g_constant, final_per, G0, alpha)
end

function optimize!(
   input::GSAIn,
   ffitness::Function,
   maxeval::Integer,
   maximize::Bool,
   cmp::Function,
   fbest::Function,
   fworst::Function,
   dmin::Real = 0.0,
   dmax::Real = 1.0,
)

   popsize = size(input.population, 1)
   ndim = size(input.population, 2)

   maxiter = div(maxeval, popsize)

   M = nothing
   #Calculate Mass
   best_idx = fbest(input.fitness)
   worst_idx = fworst(input.fitness)

   bestfit = input.fitness[best_idx]
   worstfit = input.fitness[worst_idx]

   if(bestfit == worstfit)
      M = ones(popsize)
   else
      M = (input.fitness .- worstfit) ./ (bestfit - worstfit)
   end

   #Gfield
   kbest = input.final_per + (1 - input.nIter/maxiter) * (100 - input.final_per)
   kbest = round(popsize * kbest / 100)
   kbest = convert(Integer, kbest)

   sortm = sortperm(M, rev = true)

   E = zeros(popsize, ndim)
   
   kbestpop = input.population[sortm[1:kbest], :]
   kbestmass = M[sortm[1:kbest]]
   for i = 1:popsize   
      diffpop_idx = eachrow(kbestpop)  .!= eachrow(reshape(input.population[i, :], 1, ndim)) 
      n = count(x -> x == 1, diffpop_idx)
      auxpop = kbestpop[diffpop_idx, :]
      auxmass = kbestmass[diffpop_idx]

      R = euclidean.(eachrow(reshape(input.population[i, :], 1, ndim)),eachrow(auxpop))
      aux = 1 ./ (R .^ 2 .+ eps())
 
      aux1 = (auxpop .- reshape(input.population[i, :], 1, ndim)) .* aux
      aux2 = rand(n) .* auxmass
      aux3 = aux1 .* aux2

      E[i, :] = sum(aux3, dims = 1)
   end

   G = g_constant(input.G0, input.alpha, input.nIter, maxiter)

   a = E .* G

   input.population = input.population + input.velocity + 0.5 * a
   input.velocity = rand(popsize, ndim) .* input.velocity + a 

   clamp!(input.population, dmin, dmax)

   input.fitness = map(ffitness, eachrow(input.population))
   input.nEvals += length(input.fitness)

   nothing  
end
