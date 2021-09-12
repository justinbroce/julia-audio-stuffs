
mutable struct Envelope
    fs::Float64   
    attack::Float64 #attack in seconds
    decay::Float64  #decay in seconds
    sustain::Float64 #sustain
    sustainTime::Float64 # sustain duration in seconds
    release::Float64 #release in seconds
end
function getAttack(env)
    size = env.fs * env.attack 
    return 0.0 : inv(size) : 1
end
function getDecay(env)
    size = env.fs * env.decay
    return 1:inv(size)*-(1-env.sustain):env.sustain
end
function getRelease(env)
    size =env.fs * env.release
    return env.sustain : inv(size)*-env.sustain : 0
end
function getSustain(env)
    size = round(env.fs * env.sustainTime)
    return zeros(Int(floor(size))).+env.sustain
end

function applyEnvelope(samples::AbstractVector{T}, env)where
    {T<:Real}
    returnVector = T[] #signal to return
    size = length(samples) #length of the original signal
    #get vectors that represent attack, decay of a given envelope
    attack = getAttack(env) 
    decay = getDecay(env)
    release = getRelease(env)
    decayAttack = length(attack)+length(decay)
    sustain = getSustain(env)
    sustainLength = length(sustain)
    #appending attack part of the envelope
    append!(returnVector, attack.*samples[1:length(attack)] ) 
    #appending decay
    append!(returnVector, decay.*samples[1+length(attack):decayAttack] ) 
    #appending sustain
    append!(returnVector, sustain .* samples[decayAttack+1:sustainLength+decayAttack])
    #appending release
    append!(returnVector, release.*samples[sustainLength+decayAttack+1:sustainLength+decayAttack+length(release)])  
    return returnVector
end 

