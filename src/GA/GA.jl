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

   (result, ffitness, maxeval, maximize, cmp, fbest, fworst, dmin, dmax) -> privateSSGA(
      result,
      ffitness,
      maxeval,
      maximize,
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

   (result, ffitness, maxeval, maximize, cmp, fbest, fworst, dmin, dmax) -> privateGGA(
      result,
      ffitness,
      maxeval,
      maximize,
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
   input::Result,
   ffitness::Function,
   maxeval::Integer,
   maximize::Bool,
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
   

   p1_idx = fselect(input.population, input.fitness)
   p2_idx = fselect(input.population, input.fitness)

   while p1_idx == p2_idx
      p2_idx = fselect(input.population, input.fitness)
   end

   p1 = input.population[p1_idx, :]
   p2 = input.population[p2_idx, :]

   h = fcross(p1, p2)

   map(eachrow(h)) do x
      if pmutation < rand()
         fmutation(x)
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

   return Result(input.population, input.fitness, fbest(input.fitness), length(fit_children))
end

function privateGGA(
   input::Result,
   ffitness::Function,
   maxeval::Integer,
   maximize::Bool,
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


   popsize = size(input.population, 1)
   ndim = size(input.population, 2)

   nextpop = Array{Real,2}(undef, 0, ndim)
   nextfit = Array{Real,1}(undef, 0)

   ncross = ceil(pcross * popsize)

   fit_children = nothing

   for _ = 1:ncross
      p1_idx = fselect(input.population, input.fitness)

      p2_idx = fselect(input.population, input.fitness)

      while p2_idx == p1_idx
         p2_idx = fselect(input.population, input.fitness)
      end

      p1 = input.population[p1_idx, :]
      p2 = input.population[p2_idx, :]


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
   best = fbest(input.fitness)
   bestpop = input.population[best, :]
   bestfit = input.fitness[best]

   input.population = nextpop[1:popsize, :]
   input.fitness = nextfit[1:popsize]

   worst = fworst(input.fitness)
   input.fitness[worst] = bestfit
   input.population[worst, :] = bestpop

   return Result(input.population, input.fitness, fbest(input.fitness), ncross * eval)

end
