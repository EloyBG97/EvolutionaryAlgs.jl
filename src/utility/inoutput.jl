
mutable struct OutputIterAlg
    population::AbstractArray{Real, 2}
    fitness::AbstractArray{Real, 1}
    evalIter::Integer
end

mutable strut OutputAlg
    population::AbstractArray{Real, 2}
    fitness::AbstractArray{Real, 1}
    totalEval::Integer
end

mutable struct Input
    population::AbstractArray{Real, 2}
    fitness::AbstractArray{Real, 2}
    bestFitness::AbstractArray{Real, 2}
end
