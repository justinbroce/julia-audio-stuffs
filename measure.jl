mutable struct Measure
    bpm::Integer
    fs::Float64
    beats::Integer
    samples::AbstractArray
end
function format(m::Measure)
    return string("bpm: $(m.bpm)
          \nfs: $(m.fs)   
          \nbeats: $(m.beats) 
          \nsamples: $(length(m.samples))    
                        ")
end
function addToMeasure!(m::Measure, signal::AbstractVector, beat)
    beatLength = (60/m.bpm) * m.fs
    measureLength = Int(ceil(beatLength * m.beats - beatLength*beat))
    actualMeasureLength = Int(ceil(beatLength * m.beats))
    if(length(signal) > measureLength)
        throw(DomainError("
        error: signal is too large
        signal length: $(length(signal))                  
        measureLength: $measureLength
        "))
    end
    signalToPush = Float64[]
    append!(signalToPush, zeros(Int(ceil(beatLength * beat))))
    append!(signalToPush, signal)
    append!(signalToPush, zeros(actualMeasureLength-length(signalToPush)))
    push!(m.samples, signalToPush)
end
function renderMeasure(m::Measure)
    length(m.samples) > 0 || throw(DomainError(length(m.samples),"samples must not be empty"))
    if(length(m.samples)==1)
        return m.samples[1]
    else
        return (sum(m.samples))./maximum(sum(m.samples))
    end
end
