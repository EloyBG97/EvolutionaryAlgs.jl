include("util/enviroment.jl")

export PSOG, PSOL

#BEGIN STRUCT DEFINITION
mutable struct PSOGIn
   population::AbstractArray{<:Real, 2}
   fitness::AbstractArray{<:Real, 1}
   nEvals::Integer
   
   bestpop::AbstractArray{<:Real, 2}
   bestfit::AbstractArray{<:Real, 1}
   velocity::AbstractArray{<:Real, 2}
   vmax::Real
   vmin::Real
   phi1::Real
   phi2::Real           
end

function initialize!(self::PSOGIn, population::AbstractArray{<:Real, 2}, fitness::AbstractArray{<:Real, 1})
   self.population = population
   self.bestpop = population

   self.fitness = fitness
   self.bestfit = fitness

   self.velocity = rand(Uniform(self.vmin, self.vmax), size(population))

   nothing
end

#BEGIN STRUCT DEFINITION
mutable struct PSOLIn
   population::AbstractArray{<:Real, 2}
   fitness::AbstractArray{<:Real, 1}
   nEvals::Integer

   bestpop::AbstractArray{<:Real, 2}
   bestfit::AbstractArray{<:Real, 1}
   velocity::AbstractArray{<:Real, 2}
   vmax::Real
   vmin::Real
   phi1::Real
   phi2::Real
   sizeEnv::Integer
end

function initialize!(self::PSOLIn, population::AbstractArray{<:Real, 2}, fitness::AbstractArray{<:Real, 1})
   self.population = population
   self.bestpop = population

   self.fitness = fitness
   self.bestfit = fitness

   self.velocity = rand(Uniform(self.vmin, self.vmax), size(population))
   nothing
end


function PSOG(; vmax::Real = 1, vmin::Real = 0, phi1::Real = 1.05, phi2::Real = 1.05)
   PSOGIn(Array{Float32}(undef, 0, 0), Array{Float64}(undef, 0), 0,
        Array{Float32}(undef, 0, 0), Array{Float64}(undef, 0),
        Array{Float32}(undef, 0, 0), vmax, vmin, phi1, phi2)
end

function PSOL(; vmax::Real = 1, vmin::Real = 0, phi1::Real = 1.05, phi2::Real = 1.05, sizeEnv::Integer = 3)
   PSOLIn(Array{Float32}(undef, 0, 0), Array{Float64}(undef, 0), 0,
        Array{Float32}(undef, 0, 0), Array{Float64}(undef, 0),
        Array{Float32}(undef, 0, 0), vmax, vmin, phi1, phi2, sizeEnv)
end


function optimize!(
   input::PSOGIn,
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

   best = fbest(input.bestfit)

   #Best global position
   globalbestpop = input.bestpop[best, :]

   #Best global fitness
   globalbestfit = input.bestfit[best]

   input.velocity =
      input.velocity +
      input.phi1 * rand(popsize) .* (input.bestpop - input.population) +
      input.phi2 * rand(popsize) .* (reshape(globalbestpop, 1, ndim) .- input.population)


   clamp!(input.velocity, input.vmin, input.vmax)

   input.population = input.population + input.velocity
   clamp!(input.population, dmin, dmax)

   input.fitness = map(ffitness, eachrow(input.population))

   idxBetter = cmp.(input.bestfit, input.fitness)

   input.bestfit[idxBetter] .= input.fitness[idxBetter]
   input.bestpop[idxBetter, :] .= input.population[idxBetter, :]

   input.nEvals += popsize
   nothing
end



function optimize!(
   input::PSOLIn,
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

  #Find Enviroment
  bestEnvPop = findEnviroment(input.population, input.fitness, fbest, input.sizeEnv)

  input.velocity =
     input.velocity +
     input.phi1 * rand(popsize) .* (input.bestpop - input.population) +
     input.phi2 * rand(popsize) .* (bestEnvPop .- input.population)


  #Test Range Velocity Domain
  clamp!(input.velocity, dmin, dmax)

  input.population = input.population + input.velocity

  #Test Range Domain
  clamp!(input.population, dmin, dmax)


  input.fitness = map(ffitness, eachrow(input.population))

  idxBetter = cmp.(input.bestfit, input.fitness)

  input.bestfit[idxBetter] .= input.fitness[idxBetter]
  input.bestpop[idxBetter, :] .= input.population[idxBetter, :]

  input.nEvals += popsize
  nothing
end
