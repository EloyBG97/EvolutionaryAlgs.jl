function g_constant(G0::Real, alpha::Real, eval::Integer, maxeval::Integer)
   G0 * exp(-alpha * eval/maxeval)
end
