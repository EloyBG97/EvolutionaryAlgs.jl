using DocStringExtensions

"""
$(SIGNATURES)
The child is the arithmetic mean of parents\n
p1 -> Parent1\n
p1 -> Parent2\n
"""
function arithmetic_cross(p1::AbstractArray{T, 1}, p2::AbstractArray{T, 1}) where {T <: Real}
    @assert length(p1) == length(p2)

    if T <: AbstractFloat
        (p1 + p2) / 2
    else
        div(p1 + p2, 2)
    end
end
"""
$(SIGNATURES)
The child is randomly generated into interval generated from parents\n
p1 -> Parent1\n
p1 -> Parent2\n
"""
function blx_cross(p1::AbstractArray{T, 1}, p2::AbstractArray{T, 1}; alpha::T = 0.3) where {T <: Real}
    c = [p1 p2]

    c_max = map(maximum, eachrow(c))
    c_min = map(minimum, eachrow(c))

    i = c_max - c_min

    sup = c_max + i * alpha
    inf = c_min - i * alpha

    interval = [inf sup]

    h1 = map(x -> rand(x[1]:x[2]), eachrow(interval))
    h2 = map(x -> rand(x[1]:x[2]), eachrow(interval))

    [h1 h2]
end
