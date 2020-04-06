function callback_none(i, population, fitness, fbest)
    nothing
end

function callback_print(i, pop, fit, fbest)
    best = fbest(fit)

    #print log
    println("Iteration ", i, ": ")
    println(pop[best, :])
    println(fit[best])
end
