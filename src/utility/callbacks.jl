function callback_none(i, population, fitness)
   nothing
end

function callback_print(i, pop, fit; fbest)
    best = fbest(fit)

    println("Iteration ", i,": ")
    println(pop[best,:])
    println(fit[best])
end
