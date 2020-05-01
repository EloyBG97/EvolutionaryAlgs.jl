include("../utility/selection.jl")
include("../utility/callbacks.jl")
include("util/cross.jl")

using Distributions

export DE

mutable struct DEIn
   population::AbstractArray{<:Real, 2}
   fitness::AbstractArray{<:Real, 1}
   nEvals::Integer
   fcross::Function
end

function setData!(self::DEIn, population::AbstractArray{<:Real, 2}, fitness::AbstractArray{<:Real, 1})
   self.population = population
   self.fitness = fitness
end

function DE(; fcross::Function = bestCross)
   DEIn(Array{Float32}(undef, 0,0), Array{Float32}(undef, 0), 0, fcross)
end

function optimize!(
   input::DEIn,
   ffitness::Function,
   maxeval::Integer,
   maximize::Bool,
   cmp::Function,
   fbest::Function,
   fworst::Function,
   dmin::Real = 0.0,
   dmax::Real = 1.0;
)
   popsize = size(input.population, 1)
   ndim = size(input.population, 2)
   nextpop = Array{Float32,2}(undef, 0, ndim) #Float32

   map(eachrow(input.population)) do individual
      #input.population, input.fitness
      h = input.fcross(input.population, input.fitness, individual, fbest)

      clamp!(h, dmin, dmax)
      nextpop = [nextpop; h]
   end

   nextfit = map(ffitness, eachrow(nextpop))
   idx = cmp.(input.fitness, nextfit)

   input.fitness[idx] = nextfit[idx]
   input.population[idx, :] = nextpop[idx, :]

   input.nEvals += length(nextfit)
   nothing
end
