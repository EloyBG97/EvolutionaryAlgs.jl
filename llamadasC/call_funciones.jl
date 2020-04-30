function cec20_function_eval(nfunc::Integer, x::AbstractArray)
	res = [0.0]

	ccall((:cec20_test_func, "cec20_test_func.so"), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Cint, Cint, Cint), x, res, lenght(x), 1, nfunc)

	res[1]
end

function cec2020_function(nfunc::Integer)
	f = x -> cec20_function_eval(nfunc, x)
end
