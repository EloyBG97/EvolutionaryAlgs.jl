function callback_none(i, population, fitness)
   nothing
end

function callback_print(i, pop, fit)
    best = argmax(fit)

    println("Selection ", i,": ")
    println(pop[best,:])
    println(fit[best])
end
