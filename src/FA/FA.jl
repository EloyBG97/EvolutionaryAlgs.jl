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

"""
$(SIGNATURES)
lightAbsortion -> Light Aabsortion Level\n
distance -> Distance Calculation Function\n
"""
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

    newpop = similar(input.population)
    newfit = similar(input.fitness)

    for i = 1:popsize
        popaux = reshape(input.population[i, :], 1, ndim)
        idx = cmp.(input.fitness[i], input.fitness)
        n = count(x -> x == 1, idx)

        aux = popaux .* ones(n)

        dist = map(input.distance, eachrow(aux), eachrow(input.population[idx, :]))

        atractiveness = exp.(-2 * input.lightAbsortion .* dist)

        newpop  =
            input.population[idx, :] + atractiveness .* (input.population[idx, :] .- popaux)
   
        clamp!(newpop, dmin, dmax)        

        newfit = map(ffitness, eachrow(newpop))
    end

    input.fitness = [input.fitness; newfit]
    input.population = [input.population; newpop]

    idx = sortperm(input.fitness, rev = maximize)

    input.population = input.population[ idx[1:popsize], : ]
    input.fitness = input.fitness[ idx[1:popsize] ]   

    input.nEvals += popsize*popsize
    nothing
end
