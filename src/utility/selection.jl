"""
$(SIGNATURES)
For each gen, is been assigned a probability to be chosen by the next formula:\n

``\frac{ffitness(gen)}∑^n_{i=0}fitness(gen_i)``\n

fitnes -> fitness value array\n
"""
function roulette_wheel_selection(
    population::AbstractArray{<:Real,2},
    fitness::AbstractArray{<:Real,1},
)

    sumfitness = 1 / sum(fitness)
    selection_prob = fitness * sumfitness

    fitness_sort_idx = sortperm(fitness)
    fitness_sort = fitness[fitness_sort_idx]
    sort!(selection_prob)

    selection_acum_prob = cumsum(selection_prob)
    sample_prob = sample(selection_acum_prob, 1, replace = false)

    index_bit = in(sample_prob).(selection_acum_prob)
    index_fitness_sort = 1:length(fitness)

    i = index_fitness_sort[index_bit][1]

    fitness_sort_idx[i]

end

"""
$(SIGNATURES)
For each gen, is been assigned a probability to be chosen by the fitness value\n
fitnes -> fitness value array\n
"""
function linear_selection(
    fpopulation::AbstractArray{<:Real,2},
    fitness::AbstractArray{<:Real,1},
)
    maxfitness = 1 / maximum(fitness)
    selection_prob = fitness * maxfitness

    fitness_sort = sort(fitness)
    sort!(selection_prob)

    selection_acum_prob = cumsum(selection_prob)
    sample_prob = sample(selection_acum_prob, 1, replace = false)

    index_bit = in(sample_prob).(selection_acum_prob)
    index_fitness_sort = 1:length(fitness)

    i = index_fitness_sort[index_bit][1]

    findall(x -> x == fitness_sort[i], fitness)[1]
end


"""
$(SIGNATURES)
Take k random fitness and select the best of them's index\n
fitnes -> fitness value array\n
k -> Number of competitors\n
"""
function tournament_selection(
    population::AbstractArray{<:Real,2},
    fitness::AbstractArray{<:Real,1};
    k::Integer = 3,
)
    p = rand(1:length(fitness), k)

    tournament = fitness[p]

    findmax(tournament)[2]
end

"""
$(SIGNATURES)
Take one gen randomly and take other group of nnam gen randomly too. The select\n
gen, was the further gen of the group from the first gen.\n
population ->\n
distance -> way to calculate distances\n
nnam -> size of the group\n
"""
function reverse_mixed_pairing_selection(
    population::AbstractArray{<:Real,2},
    fitness::AbstractArray{<:Real,1};
    distance::Metric = Euclidean(),
    nnam::Integer = 3,
)

    p1 = rand(1:size(population, 1))
    p2 = rand(1:size(population, 1), nnam)

    reference = population[p1, :]
    posible_parent = reshape(population[p2, :][:], nnam, size(population, 2))

    _distance = map(
        x -> Distances.evaluate(distance, reference, x),
        eachrow(posible_parent),
    )
    parent = findmax(_distance)[2]

    p2[parent]
end
