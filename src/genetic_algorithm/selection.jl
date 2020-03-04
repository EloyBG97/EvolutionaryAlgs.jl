module selection

    function seleccion_ruleta(population::Array{T,2}, ffitness::Function, prop::Float64 = 0.5) where {T <: Any}
        gensize = size(population, 2)
        popsize = size(population, 1)
        selectedpop = Array{T,2}(undef, 0, gensize)
        ptotal = sum(map(ffitness,eachrow(population)))

        last = 0
        sort_pop = sort(population, dims = 1, by = ffitness, rev = true)
        for gen in eachrow(sort_pop)
            pgen = ffitness(gen)/ptotal

            if(rand() >= pgen)
                gen = reshape(gen, (1, gensize))
                selectedpop = vcat(selectedpop, gen)
                last = last + 1

                if(last == prop * popsize)
                    break
                end
            end
        end

        return selectedpop
    end
end
