"""
$(SIGNATURES)
Add to each value N(0, σ)\n
h -> Gen has to be mutate\n
sigma -> Standard Desviation\n
"""
function norm_mutation!(h::AbstractArray{<:Real,1}; sigma::Real = 1)
    sizeh = size(h, 1)
    norm = Distributions.Normal(0, sigma)

    h = h + rand(norm, sizeh)
end

"""
$(SIGNATURES)
Change positions of two gen's values\n
h -> Gen has to be mutate\n
"""
function perm_mutation!(h::AbstractArray{<:Real,1})
    sizeh = size(h, 1)

    i = rand(1:sizeh, 2)

    h[i[[1 2]]] = h[i[[2 1]]]

    h
end
