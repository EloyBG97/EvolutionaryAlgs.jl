using Distances

function findEnviroment(
    population::AbstractArray{<:Real,2},
    fitness::AbstractArray{<:Real,1},
    fbest::Function;
    sizeEnv::Integer = 3,
    distance::Metric = Euclidean()
)
    ndim = size(population, 2)
    popsize = size(population, 1)
    enviroment = Array{Real,2}(undef, 0, ndim)

    for i = 1:popsize

        #distance = .√sum((population[i,:] .- population).^2, dims = 2)

        _distance = map(
            x -> Distances.evaluate(distance, x, population[i, :]),
            eachrow(population),
        )
        sortIdx = sortperm(_distance)

        envIdx = sortIdx[1:sizeEnv]

        best = fbest(fitness[envIdx])

        enviroment = [enviroment ; reshape(population[best, :], 1, ndim)]
    end

    enviroment
end
