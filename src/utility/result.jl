
mutable struct Result
    population::AbstractArray{Real, 2}
    fitness::AbstractArray{Real, 1}
    bestidx::Integer
    evals::Integer
end
