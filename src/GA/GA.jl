include("../utility/selection.jl")
include("util/cross.jl")
include("util/mutation.jl")


export SSGA, GGA

mutable struct SSGAIn
   population::AbstractArray{<:Real, 2}
   fitness::AbstractArray{<:Real, 1}
   nEvals::Integer
   fcross::Function
   fselect::Function
   fmutation::Function
   pmutation::Real
end


function initialize!(self::SSGAIn, population::AbstractArray{<:Real, 2}, fitness::AbstractArray{<:Real, 1})
   self.population = population
   self.fitness = fitness

   nothing
end


mutable struct GGAIn
   population::AbstractArray{<:Real, 2}
   fitness::AbstractArray{<:Real, 1}
   nEvals::Integer
   fcross::Function
   fselect::Function
   fmutation::Function
   pmutation::Real
   pcross::Real
end

function initialize!(self::GGAIn, population::AbstractArray{<:Real, 2}, fitness::AbstractArray{<:Real, 1})
   self.population = population
   self.fitness = fitness

   nothing
end

"""
$(SIGNATURES)
Stationary Genetic Algorithm\n
fcross -> Cross Function\n
fselect -> Selection Function\n
fmutation -> Mutation Function\n
pmutation -> Mutation Probability\n
"""
function SSGA(;
   fcross::Function = blx_cross,
   fselect::Function = roulette_wheel_selection,
   fmutation::Function = norm_mutation!,
   pmutation::Real = 0.3,
)

   SSGAIn(Array{Float32}(undef, 0, 0), Array{Float32}(undef, 0), 0, fcross, fselect, fmutation, pmutation)
end

"""
$(SIGNATURES)
Generacional Genetic Algorithm\n
fcross -> Cross Function\n
fselect -> Selection Function\n
fmutation -> Mutation Function\n
pmutation -> Mutation Probability\n
pcross -> Cross Probability\n
"""
function GGA(;
   fcross::Function = blx_cross,
   fselect::Function = roulette_wheel_selection,
   fmutation::Function = norm_mutation!,
   pmutation::Real = 0.3,
   pcross::Real = 0.7,
)

   GGAIn(Array{Float32}(undef, 0, 0), Array{Float32}(undef, 0), 0, fcross, fselect, fmutation, pmutation, pcross)
end


function optimize!(
   input::SSGAIn,
   ffitness::Function,
   maxeval::Integer,
   maximize::Bool,
   cmp::Function,
   fbest::Function,
   fworst::Function,
   dmin::Real = 0.0,
   dmax::Real = 1.0,
)

   @assert 0 <= input.pmutation <= 1 "pmutation must be in [0,1]"
   

   (p1_idx, p2_idx) = input.fselect(input.population, input.fitness)

   p1 = input.population[p1_idx, :]
   p2 = input.population[p2_idx, :]

   h = input.fcross(p1, p2)

   map(eachrow(h)) do x
      if input.pmutation < rand()
         input.fmutation(x)
      end
   end

   clamp!(h, dmin, dmax)

   fit_children = map(ffitness, eachrow(h))

   map(eachrow(h), fit_children) do x, y
      worst = fworst(input.fitness)

      if cmp(input.fitness[worst], y)
         input.population[worst, :] = x
         input.fitness[worst] = y
      end
   end

   input.nEvals += length(fit_children)
   nothing
end

function optimize!(
   input::GGAIn,
   ffitness::Function,
   maxeval::Integer,
   maximize::Bool,
   cmp::Function,
   fbest::Function,
   fworst::Function,
   dmin::Real = 0.0,
   dmax::Real = 1.0,
)

   @assert 0 <= input.pmutation <= 1 "pmutation must be in [0,1]"
   @assert 0 <= input.pcross <= 1 "pcross must be in [0,1]"


   popsize = size(input.population, 1)
   ndim = size(input.population, 2)

   nextpop = Array{Real,2}(undef, 0, ndim)
   nextfit = Array{Real,1}(undef, 0)

   (p1_idx, p2_idx) = input.fselect(input.population, input.fitness)

   p1 = input.population[p1_idx, :]
   p2 = input.population[p2_idx, :]

   h = input.fcross(p1, p2)
 
 
   map(eachrow(h)) do x
      if input.pmutation < rand()
         input.fmutation(x)
      end
   end
 
   clamp!(h, dmin, dmax)
   nextpop = [nextpop; h]
   fit_children = map(ffitness, eachrow(h)) 
   nextfit = [nextfit; fit_children]


   ncross = div(ceil(input.pcross * popsize), length(h)) - 1

   fit_children = nothing

   for _ = 1:ncross
      (p1_idx, p2_idx) = input.fselect(input.population, input.fitness)

      p1 = input.population[p1_idx, :]
      p2 = input.population[p2_idx, :]


      h = input.fcross(p1, p2)


      map(eachrow(h)) do x
         if input.pmutation < rand()
            input.fmutation(x)
         end
      end

      clamp!(h, dmin, dmax)

      nextpop = [nextpop; h]

      fit_children = map(ffitness, eachrow(h))

      nextfit = [nextfit; fit_children]
   end

   
   #Elitism
   best = fbest(input.fitness)
   bestpop = input.population[best, :]
   bestfit = input.fitness[best]

   input.population = nextpop
   input.fitness = nextfit

   worst = fworst(input.fitness)
   input.fitness[worst] = bestfit
   input.population[worst, :] = bestpop

   input.nEvals += length(nextfit)
   nothing
end
