include("synth.jl")
using Interpolations, Plots

function AD_chebyshev(order,x)

    return-(x*cos(order*acos(x))+order*sqrt(1-x^2)*sin(order*acos(x)))/(-1+order^2)

end


