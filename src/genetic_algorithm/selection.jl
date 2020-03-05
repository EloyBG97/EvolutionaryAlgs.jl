using Random

"""
For each gen, is been assigned a probability to be chosen by the next formula:

``\frac{ffitness(gen)}∑^n_{i=0}fitness(gen_i)``

population ->\n
ffitnes -> fitness function\n
prop -> by default 0.5\n
"""
function roulette_wheel_selection(population::Array{T,2}, ffitness::Function, prop::Float64 = 0.5) where {T <: Any}
    gensize = size(population, 2)
    popsize = size(population, 1)
    selectedpop = Array{T,2}(undef, 0, gensize)
    ptotal = sum(map(ffitness,eachrow(population)))

    last = 0
    sort_pop = sort(population, dims = 1, by = ffitness, rev = true)

    for gen in eachrow(sort_pop)
        pgen = ffitness(gen)/ptotal

        if rand() >= pgen
            gen = reshape(gen, (1, gensize))
            selectedpop = vcat(selectedpop, gen)
            last = last + 1

            if last == floor(prop * popsize)
                break
            end
        end
    end

    return selectedpop
end

"""
Select the 1/prop best part from the population\n
population ->\n
ffitnes -> fitness function\n
prop -> by default 0.5\n
"""
function linear_selection(population::Array{T,2}, ffitness::Function, prop::Float64 = 0.5) where {T <: Any}
    sort_pop = sort(population, dims = 1, by = ffitness, rev = true)
    popsize = size(population, 1)

    sizeselected = convert(UInt64, floor(prop * popsize))

    sort_pop[1:sizeselected,:]
end

function random_selection(population::Array{T,2}, ffitness::Function, prop::Float64 = 0.5) where {T <: Any}
    popsize = size(population, 1)
    sizeselected = convert(Int64, floor(prop * popsize))

    perm = randperm(popsize)

    selectedpop = population[perm, :]

    return selectedpop[1:sizeselected, :]
end
