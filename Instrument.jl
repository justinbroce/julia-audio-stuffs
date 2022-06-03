mutable struct Instrument
    #ADSR envelope for amplitude
    envelope 
    #a function for generating a combination of sine waves or other type of waveforms
    waveform
end
using WAV



function sine(seconds, hz, fs, vib_amp, vib_rate)
    t = 0.0 : inv(fs) : seconds
    freq_vib = hz .+ vib_amp .* sin.(t * 2π * vib_rate)
    phase_vib = zeros(length(t))
    for i in 2:length(t)
        phase_vib[i] = phase_vib[i-1] + 2π* freq_vib[i-1] / fs
    end
    sin.(phase_vib)
end

function sin_weird(amplitude,hz)
    amplitude*sine(1,hz,41000,log2(hz*(rand()+rand()))/1+2,log2(hz*(rand()+rand()))/2+4)
end
function sin_weird2(amplitude,hz)
    amplitude*sine(1,hz,41000,time()%5+3,time()%3+3)

end
function sine_source(wave_count,n, s)
    
    freqs = 0:1:(wave_count-1)

    hz ->  sum(s.(1 ./((freqs.+1) .^ n ), hz * (2 .^ freqs)))
               
end

function norm(a)
    a/maximum(a)
end
function compound(x)
    f1 = sine_source(24, 1.2, sin_weird)
    norm(f1(x))
end

function compound2(x)
    f1 = sine_source(25, 1.2, sin_weird2)
    norm(f1(x))
end
function test()
   wavplay(compound(440), 41000)
end
