using DocStringExtensions

"""
$(SIGNATURES)
Generate child from the best to 2 ramdomly taken parents\n
current -> Current individual\n
best -> best individual\n
parent1 -> Random individual\n
parent2 -> Random individual\n
f -> Cross Strenght\n
p -> Cross Probability\n
dmin -> Minimun gen value\n
dmax -> Maximun gen value\n
"""
function bestCross(
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
        population[bestidx, idx] + f * (parents[1, idx] - parents[2, idx])

    reshape(offspring, 1, length(offspring))
end

"""
$(SIGNATURES)
Generate child from the current to the best\n
current -> Current individual\n
best -> best individual\n
parent1 -> Random individual\n
parent2 -> Random individual\n
f -> Cross Strenght\n
p -> Cross Probability\n
dmin -> Minimun gen value\n
dmax -> Maximun gen value\n
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
