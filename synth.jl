
using Random 
const frequencies = Dict("c"=>16.3516,"c#"=>17.32391, "d"=>18.35405, "d#"=>19.44544, "e"=>20.60172, 
"f"=>21.82676, "f#"=>23.12465, "g"=>24.49971, "g#" => 25.95654, "a"=>27.5, "a#"=>29.13524,
"b"=>30.86771
)
#check input string to see if it matches convention
function checkInput(input::AbstractString)
    if (length(input) >3 || length(input) < 2 ) return false end
    return !isnothing(match(r"([a-g]#?[\d])"i, input))
end
#returns the correct frequency for the given note  and octave
function getFreq(input::AbstractString)
    if !checkInput(input) return false end
    if length(input)==2
        noteName = lowercase(string(input[1]))
        octave = parse(Int, input[2])
    else
        noteName = lowercase(input[1:2])
        octave = parse(Int, input[3])
    end
    return frequencies[noteName] * 2^octave
end    
function getFreq(input::Real)
    return input
end
#returns a vector where fs is sampling rate, from 0 to seconds in increments of 1/fs
function getTimeVector(seconds,fs)
    return 0.0 : inv(fs) : seconds
end
#returns a sin wave at give frequency for givin time
function getSine(seconds, hz, fs = 41000.0)
    t = 0.0 : inv(fs) : seconds
    sin.(2π  *  hz  *  t )
end
#returns a sin wave at given note name and time
function getSine(seconds, freq::AbstractString, fs = 41000.0)
    hz = getFreq(freq)
    t = 0.0 : inv(fs) : seconds
    sin.(2π  *  hz  *  t )
end

#=returns a saw wave at give frequency for givin time
#note to self:change to the series formation of saw wave
to remove aliasing
=#
function getSaw(seconds, hz, fs = 41000.0)
    timeVector = getTimeVector(seconds, fs)
    2 .* mod.(timeVector * hz, 1).-1
end
#returns a sin wave at given note name and time
function getSaw(seconds, freq::AbstractString, fs = 41000.0)
    hz = getFreq(freq)
    timeVector = getTimeVector(seconds, fs)
    2 .* mod.(timeVector * hz, 1).-1
end
function lfo(signal::AbstractVector{T},hz,fun::Function, i::Tuple = (1,40),fs=41000)where
    {T<:Real}
    inc = Float64(0)
    newSignal = T[]
    f(x) = (i[2]-i[1])*sin(2π * x * hz)/2 + (i[2]+i[1])/2
    for i in signal 
        push!(newSignal, fun(i,f(inc)))
        inc+=inv(fs)
    end
    return newSignal
end

#returns a vector containing random noise for seconds
function getRand(seconds,fs= 41000)
    rng = MersenneTwister(1234)
    count = length(0.0 : inv(fs) : seconds)
    return rand!(rng, zeros(count)).*2 .-1
end



