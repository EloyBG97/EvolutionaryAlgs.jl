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
    current::AbstractArray{<:Real,1},
    best::AbstractArray{<:Real,1},
    parent1::AbstractArray{<:Real,1},
    parent2::AbstractArray{<:Real,1};
    f::Real = 0.75,
    p::Real = 0.5,
    dmin::Real = 0.0,
    dmax::Real = 1.0,
)
    n = length(current)
    offspring = Array{Real,1}(undef, n)

    for i = 1:n
        if rand() > p
            offspring[i] = best[i] + f * (parent1[i] - parent2[i])

            if offspring[i] < dmin
                offspring[i] = dmin
            end

            if offspring[i] > dmax
                offspring[i] = dmax
            end
        else
            offspring[i] = current[i]
        end
    end

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
    current::AbstractArray{<:Real,1},
    best::AbstractArray{<:Real,1},
    parent1::AbstractArray{<:Real,1},
    parent2::AbstractArray{<:Real,1};
    f::Real = 0.75,
    p::Real = 0.5,
    dmin::Real = 0.0,
    dmax::Real = 1.0,
)
    n = length(current)
    offspring = Array{Real,1}(undef, n)

    for i = 1:n
        if rand() > p
            offspring[i] =
                current[i] +
                f * (best[i] - current[i]) +
                f * (parent1[i] - parent2[i])

            if offspring[i] < dmin
                offspring[i] = dmin
            end

            if offspring[i] > dmax
                offspring[i] = dmax
            end
        else
            offspring[i] = current[i]
        end
    end

    reshape(offspring, 1, length(offspring))

end
