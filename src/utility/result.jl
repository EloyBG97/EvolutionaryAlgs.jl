
mutable struct Result
    population::AbstractArray{Real, 2}
    fitness::AbstractArray{Real, 1}
    nEvals::Integer
end
