export FA

mutable struct FAIn
   population::AbstractArray{<:Real, 2}
   fitness::AbstractArray{<:Real, 1} #Intensity Source
   nEvals::Integer

   lightAbsortion::Real
   distance::Metric
 end

function initialize!(self::FAIn, population::AbstractArray{<:Real}, fitness::AbstractArray{<:Real})
   self.population = population
   self.fitness = fitness

   nothing
end

function FA(;lightAbsortion::Real = 0.3, distance::Metric = Euclidean())
   FAIn(Array{Float32}(undef, 0, 0), Array{Float64}(undef, 0), 0, 
        lightAbsortion, distance)
end

function optimize!(
   input::FAIn,
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

    for i = 1:popsize
        popaux = reshape(input.population[i, :], 1, ndim)
        idx = cmp.(input.fitness[i], input.fitness)
        n = count(x -> x == 1, idx)

        aux = popaux .* ones(n)

        dist = map(input.distance, eachrow(aux), eachrow(input.population[idx, :]))

        atractiveness = exp.(-2 * input.lightAbsortion .* dist)

        input.population[idx, :] =
            input.population[idx, :] + atractiveness .* (input.population[idx, :] .- popaux)
   
        clamp!(input.population, dmin, dmax)        

        input.fitness = map(ffitness, eachrow(input.population))
    end

    input.nEvals += popsize*popsize
    nothing
end
