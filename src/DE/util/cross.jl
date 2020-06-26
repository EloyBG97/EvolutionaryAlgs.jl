"""
$(SIGNATURES)
Generate child from the best to 2 ramdomly taken parents\n
population -> Current population\n
fitness -> Population cost\n
current -> Current individual\n
fbest -> Function to choose the best individual\n
f -> Cross Strenght\n
p -> Cross Probability\n
"""
function bestCross(
    population::AbstractArray{<:Real,2},
    fitness::AbstractArray{<:Real,1},
    current::AbstractArray{<:Real,1},
    fbest::Function;
    f::Real = 0.75,
    p::Real = 0.5,
)


    popsize = size(population, 1)
    ndim = size(population, 2)

    pidx = rand(1:popsize, 2)

    bestidx = fbest(fitness)

    parents = population[pidx, :]
    offspring = copy(current)

    idx = rand(ndim) .> p
    offspring[idx] =
        population[bestidx, idx] + f * (parents[1, idx] - parents[2, idx])

    reshape(offspring, 1, length(offspring))
end

"""
$(SIGNATURES)
Generate child from the current to the best\n
population -> Current population\n
fitness -> population cost\n
current -> Current individual\n
fbest -> Funtion to choose the best individual\n
f -> Cross Strenght\n
p -> Cross Probability\n
"""
function current2bestCross(
    population::AbstractArray{<:Real,2},
    fitness::AbstractArray{<:Real,1},
    current::AbstractArray{<:Real,1},
    fbest::Function;
    f::Real = 0.75,
    p::Real = 0.5,
)

    n = length(current)
    pidx = rand(1:n, 2)

    bestidx = fbest(fitness)

    parents = population[pidx, :]
    offspring = copy(current)

    idx = rand(n) .> p

    offspring[idx] =
        current[idx] +
        f * (population[bestidx, idx] - current[idx]) +
        f * (parents[1, idx] - parents[2, idx])

    reshape(offspring, 1, length(offspring))

end
