export callback_print, callback_plot

function callback_none(evals, population, fitness, fbest)
    nothing
end

function callback_print(evals, pop, fit, fbest)
    best = fbest(fit)

    #print log
    println("Num Evals ", evals, ": ")
    println(pop[best, :])
    println(fit[best])
end


