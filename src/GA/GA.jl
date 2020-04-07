include("../utility/selection.jl")
include("util/cross.jl")
include("util/mutation.jl")
include("../utility/callbacks.jl")
include("../utility/result.jl")


using Distributions

export SSGA, GGA

function SSGA(;
   fcross::Function = blx_cross,
   fselect::Function = roulette_wheel_selection,
   fmutation::Function = norm_mutation!,
   pmutation::Real = 0.3,
)

   (population, fitness, ffitness, cmp, fbest, fworst, dmin, dmax) -> privateSSGA(
      population,
      fitness,
      ffitness,
      cmp,
      fbest,
      fworst,
      dmin,
      dmax,
      fcross = fcross,
      fselect = fselect,
      fmutation = fmutation,
      pmutation = pmutation,
   )

end

function GGA(;
   fcross::Function = blx_cross,
   fselect::Function = roulette_wheel_selection,
   fmutation::Function = norm_mutation!,
   pmutation::Real = 0.3,
   pcross::Real = 0.7,
)

   (population, fitness, ffitness, cmp, fbest, fworst, dmin, dmax) -> privateGGA(
      population,
      fitness,
      ffitness,
      cmp,
      fbest,
      fworst,
      dmin,
      dmax,
      fcross = fcross,
      fselect = fselect,
      fmutation = fmutation,
      pmutation = pmutation,
      pcross = pcross,
   )

end


function privateSSGA(
   population::AbstractArray{<:Real,2},
   fitness::AbstractArray{<:Real,1},
   ffitness::Function,
   cmp::Function,
   fbest::Function,
   fworst::Function,
   dmin::Real = 0.0,
   dmax::Real = 1.0;
   fcross::Function = blx_cross,
   fselect::Function = roulette_wheel_selection,
   fmutation::Function = norm_mutation!,
   pmutation::Real = 0.3,
)

   @assert 0 <= pmutation <= 1 "pmutation must be in [0,1]"

   p1_idx = fselect(population, fitness)
   p2_idx = fselect(population, fitness)

   while p1_idx == p2_idx
      p2_idx = fselect(population, fitness)
   end

   p1 = population[p1_idx, :]
   p2 = population[p2_idx, :]

   h = fcross(p1, p2)

   map(eachrow(h)) do x
      if pmutation < rand()
         fmutation(x)
      end
   end

   clamp!(h, dmin, dmax)

   fit_children = map(ffitness, eachrow(h))

   map(eachrow(h), fit_children) do x, y
      worst = fworst(fitness)

      if cmp(fitness[worst], y)
         population[worst, :] = x
         fitness[worst] = y
      end
   end

   return Result(population, fitness, fbest(fitness), length(fit_children))
end

function privateGGA(
   population::AbstractArray{<:Real,2},
   fitness::AbstractArray{<:Real,1},
   ffitness::Function,
   cmp::Function,
   fbest::Function,
   fworst::Function,
   dmin::Real = 0.0,
   dmax::Real = 1.0;
   fcross::Function = blx_cross,
   fselect::Function = roulette_wheel_selection,
   fmutation::Function = norm_mutation!,
   pmutation::Real = 0.3,
   pcross::Real = 0.7,
)

   @assert 0 <= pmutation <= 1 "pmutation must be in [0,1]"
   @assert 0 <= pcross <= 1 "pcross must be in [0,1]"


   popsize = size(population, 1)
   ndim = size(population, 2)

   nextpop = Array{Real,2}(undef, 0, ndim)
   nextfit = Array{Real,1}(undef, 0)

   ncross = ceil(pcross * popsize)

   fit_children = nothing

   for _ = 1:ncross
      p1_idx = fselect(population, fitness)

      p2_idx = fselect(population, fitness)

      while p2_idx == p1_idx
         p2_idx = fselect(population, fitness)
      end

      p1 = population[p1_idx, :]
      p2 = population[p2_idx, :]


      h = fcross(p1, p2)


      map(eachrow(h)) do x
         if pmutation < rand()
            fmutation(x)
         end
      end

      clamp!(h, dmin, dmax)

      nextpop = [nextpop; h]

      fit_children = map(ffitness, eachrow(h))

      nextfit = [nextfit; fit_children]
   end

   eval = length(fit_children)

   bestnextpop = sortperm(nextfit)
   nextpop = nextpop[bestnextpop, :]
   nextfit = nextfit[bestnextpop]

   #Elitism
   best = fbest(fitness)
   bestpop = population[best, :]
   bestfit = fitness[best]

   population = nextpop[1:popsize, :]
   fitness = nextfit[1:popsize]

   worst = fworst(fitness)
   fitness[worst] = bestfit
   population[worst, :] = bestpop

   return Result(population, fitness, fbest(fitness), ncross * eval)

end
