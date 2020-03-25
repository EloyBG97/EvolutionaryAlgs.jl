using DocStringExtensions

"""
$(SIGNATURES)
The child is the arithmetic mean of parents\n
p1 -> Parent1\n
p1 -> Parent2\n
"""
function arithmetic_cross(p1::AbstractArray{T, 1}, p2::AbstractArray{T, 1}; dmin::Real = 0, dmax::Real = 1) where {T <: Real}
    @assert length(p1) == length(p2)

    if  T <: AbstractFloat
        h1= (p1 + p2) / 2
    else
        h1 = div(p1 + p2, 2)
    end

    h2 = [missing for _ in 1:length(p1)]

    reshape([h1 h2], 2, length(p1))
end
"""
$(SIGNATURES)
The child is randomly generated into interval generated from parents\n
p1 -> Parent1\n
p1 -> Parent2\n
"""
function blx_cross(p1::AbstractArray{<:Real, 1}, p2::AbstractArray{<:Real, 1}; alpha::Real = 0.3, dmin::Real = 0.0, dmax::Real = 1.0)
    @assert length(p1) == length(p2)

    c = [p1 p2]

    c_max = map(maximum, eachrow(c))
    c_min = map(minimum, eachrow(c))

    i = c_max - c_min

    sup = c_max + i * alpha
    inf = c_min - i * alpha

    map!(sup, sup) do x
        if x > dmax
            dmax
        else
            x
        end

    end

    map!(inf, inf) do x
        if x < dmin
            dmin
        else
            x
        end
    end

    interval = [inf sup]

    h1 = map(x -> rand(x[1]:x[2]), eachrow(interval))
    h2 = map(x -> rand(x[1]:x[2]), eachrow(interval))

    reshape([h1 h2], 2, length(p1))
end
