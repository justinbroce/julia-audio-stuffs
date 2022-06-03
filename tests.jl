include("envelope.jl")
include("distortion.jl")
include("measure.jl")
include("synth.jl")
include("Instrument.jl")
using WAV 
function main()
    getRand(.5)
    env = Envelope(41000,.01,.03,.2,.02,.02)
    a = applyEnvelope((getSine(1,"a4").+getSine(1,"a5").+getSine(1,"e5"))./3,env)
    a2= applyEnvelope((getSine(1,"f#5").+getSine(1,"c4").+getSine(1,"e4"))./3,env)
    b=Float64[]
    c=Float64[]
    #for i in 100.0:-inv(2):1.1 append!(b,sortDistortion(softClip(a,i),Int(ceil(i)))) end
    #for i in π/12:π/12:8π append!(b,softClip(a,abs(8sin(i))+1)) end
    for i in 32π:-π/6:π append!(b,linearDistortion(softClip(a,abs(4sin(i))+1),Int(ceil(i)))) end
    for i in 32π:-π/6:π append!(c,linearDistortion(softClip(a2,abs(4sin(i))+1),Int(ceil(i)))) end
    print(getFreq("a9"))
    print(length(b), " c: ", length(c))
    d = chebby((b.+ c)./2,.5)
    wavplay(d,41000)
 end
 function otherMain()
     env = Envelope(41000,.1,.03,.01,.012,.012)
     b = Float64[]
     c = getSine(1,880)
     e = getSine(1,880.508)
     g = getSine(1,879.982)
     a=(c.+e.+g)./3
     @time a=applyEnvelope(a,Envelope(41000,.07,.03,.7,.07,.03))
     for i in 1:1:8 append!(b,a) end
     for i in 1:inv(10):4 append!(b,chebby(a,i)) end
     for i in 1:1:40 append!(b,softClip(a,i)) end
     
     @time for i in 1:1:8 append!(b, cheb(a)) end
     
     
     
     wavplay(b,41000)
     
 end
 function sortTest()
    getRand(.5)
    env = Envelope(41000,.02,.02,.2,.02,.03)
    a = applyEnvelope((getSine(1,"a4").+getSine(1,"a5").+getSine(1,"e5"))./3,env)
    a2= applyEnvelope(getRand(1),env)
    b=Float64[]
    c=Float64[]
    
    for i in 1:1:200 append!(b,sortDistortion(a,Int(ceil(i)))) end
    for i in 1:1:200 append!(c,sortDistortion(a2,Int(ceil(i)))) end
    print(getFreq("a9"))
    print(length(b), " c: ", length(c))
    #d = chebby((b.+ c)./2,.5)
    wavplay(b,41000)
    wavwrite(b,41000,"a4.wav")
 end

 function disco()
     drumVelope(signal) = applyEnvelope(signal, Envelope(41000,.04,.03,.7,.03,.03))
     bassDrum(x) = softClip(cheb(sortDistortion(drumVelope(getSine(.5,x)),100)), 10)
     cymbal() = drumVelope(getRand(.5))./5
     cym() = append!(cymbal(),cymbal())
     sawVelope(signal) = applyEnvelope(signal, Envelope(41000,.2,.1,.7,.1,.1))
     pad(freq) = sawVelope(getSaw(1, freq))./5
     measure1 = Measure(110,41000.0,4,[])
     addToMeasure!(measure1, cym(),.5)
     addToMeasure!(measure1, cym(),1.5)
     addToMeasure!(measure1, cym(),2.5)
     addToMeasure!(measure1, cymbal(),3.5)
 
     addToMeasure!(measure1, bassDrum("a2"),0)
     addToMeasure!(measure1, bassDrum("a1"),1)
     addToMeasure!(measure1, bassDrum("a2"),2)
     addToMeasure!(measure1, bassDrum("a3"),3)
     rendered1 = renderMeasure(measure1)
     append!(rendered1,linearDistortion(rendered1,10))
     for i in 0:inv(4):1 addToMeasure!(measure1, pad("a4"),i) end
     for i in 1:inv(4):2 addToMeasure!(measure1, pad("c4"),i) end
     for i in 2:inv(4):3 addToMeasure!(measure1, pad("e4"),i) end
     addToMeasure!(measure1, pad("a5"),3) 
     rendered2 = linearDistortion(renderMeasure(measure1),10)
     append!(rendered1,linearDistortion(rendered2,15))
     append!(rendered1,softClip(rendered2,100))
     measure2 = Measure(110,41000.0,4,[])
     addToMeasure!(measure2, drumVelope(pad("a5")),0)
     addToMeasure!(measure2, drumVelope(pad("b5")),.5) 
     addToMeasure!(measure2, drumVelope(pad("c5")),1) 
     addToMeasure!(measure2, drumVelope(pad("d5")),1.5) 
     addToMeasure!(measure2, drumVelope(pad("e5")),2) 
     addToMeasure!(measure2, drumVelope(pad("f5")),2.5) 
     addToMeasure!(measure2, drumVelope(pad("g5")),3) 
     addToMeasure!(measure2, drumVelope(pad("a6")),3.5)  
     for i in .5:1:3 addToMeasure!(measure2, linearDistortion(cym(),14),i) end
     addToMeasure!(measure2, bassDrum("e3"),0)
     addToMeasure!(measure2, bassDrum("a3"),1)
     addToMeasure!(measure2, bassDrum("e3"),2)
     addToMeasure!(measure2, bassDrum("a3"),3)
     rendered3 = renderMeasure(measure2)
     append!(rendered1, rendered3)
     addToMeasure!(measure2, cheb(getSine(2,"a2")),0)
     addToMeasure!(measure2, cheb(getSine(2,"c2")),0)
     addToMeasure!(measure2, cheb(getSine(2,"e2")),0)
     addToMeasure!(measure2, cheb(getSine(2,"a3")),0)
     addToMeasure!(measure2, cheb(getSine(2,"c3")),0)
     append!(rendered1, renderMeasure(measure2))
     append!(rendered1, softClip(rendered1,32),30)
     wavplay(rendered1,41000)
 
 
 end
 function wavReadTest()
    
    
    files = wavread.(["loudSinJingle.wav", "percussion.wav", "summerSin.wav", "violinThing.wav"])
    filesF64 = [] # the float array vector
    for i in files
        push!(filesF64, i[1][:,2])
    end
    f = filesF64[2]
    
    f = softClip(f,120.1)
   wavplay(f,41000)
    
 end
 function bassoon(x) 
    a = (getSine(1,(2.001*getFreq(x)),41000.0)+
        getSine(1,(.5003*getFreq(x)),41000.0)+
        getSine(1,(0.998*getFreq(x)),41000.0))/3
    
        return applyEnvelope(softClip(a,3), Envelope(41000.0,.09,.09,7,.1,.1))                                            

end
function hat()
    drumVelope(signal) = applyEnvelope(signal, Envelope(41000,.03,.02,.5,.03,.03))
    a = Float64[]
    a = drumVelope(getRand(.5))
    append!(a, drumVelope(getRand(.5)))
    return a

end
function sawBASS(x)
    drumVelope(signal) = applyEnvelope(signal, Envelope(41000,.1,.02,.5,.03,.05))
    return cheb(drumVelope(getSaw(1, x)))
    
end
function noteTest()
    bpm = 130
    m = Measure(bpm, 41000, 8,[])
    addNotes(m, ["a4", "e7", "d6", "d4","e4", "e4" , "a3","a4"],1,bassoon)
    addNotes(m, ["c5", "c4", "f5", "f4","g#5", "g#4" , "c5","c4"],.98,bassoon)
    addNotes(m, ["e5", "e3", "a5", "a6","b6", "d6" , "a6","e5"],.97,bassoon)
    addNotes(m, ["e2", "e2", "a2", "a2","b2", "d2" , "a2","e2"],1,sawBASS)
    
    
    
    a = renderMeasure(m)
    f = Float64[]
    append!(f,a)
   for i in .5:1:7.5 addToMeasure!(m,hat(),i+i*.001) end
   append!(f,renderMeasure(m))
   addNotes(m, ["e2", "e2", "a2", "a2","b2", "d2" , "a2","e2"],1,sawBASS)
   addNotes(m, ["e2", "e2", "a2", "a2","b2", "d2" , "a2","e2"],.9,sawBASS)

   for i in 0:2:7.5 addToMeasure!(m,hat(),i) end
   addNotes(m, ["e2", "e2", "a2", "a2","b2", "d2" , "a2"],1.1,sawBASS)
   addNotes(m, ["e2", "e2", "a2", "a2","b2", "d2" , "a2"],1.2,sawBASS)
   append!(f,renderMeasure(m))
  
   addNotes(m, ["a4", "e7", "d6", "d4","e4", "b4" , "a3"],1.1,bassoon)
   addNotes(m, ["c5", "c4", "f5", "f4","g#5", "g#4" ],1.2,bassoon)
   addNotes(m, ["e5", "e3", "a5", "a6","b6", "d6" , "a6"],1.05,bassoon)
   addNotes(m, ["e2", "e2", "a2", "a2","b2", "b3" , "a2"],1.12,sawBASS)
   append!(f,renderMeasure(m))
   for i in .5:1:7.5 addToMeasure!(m,hat(),i+i*.003) end
   for i in 0:2:7.5 addToMeasure!(m,hat(),i*.002) end
   addNotes(m, ["a4", "e7", "d6", "d4","e4", "b4" , "a3"],1.1,bassoon)
   addNotes(m, ["c5", "c4", "f5", "f4","g#5", "g#4" ],1.2,bassoon)
   addNotes(m, ["e5", "e3", "a5", "a6","b6", "d6" , "a6"],1.05,bassoon)
   addNotes(m, ["e2", "e2", "a2", "a2","b2", "b3" , "a2"],1.12,sawBASS)
   append!(f,renderMeasure(m))
   addNotes(m, ["a4", "e7", "d6", "d4","e4", "b4" , "a3"],.6,bassoon)
   addNotes(m, ["c5", "c4", "f5", "f4","g#5", "g#4" ],.6,bassoon)
   addNotes(m, ["e5", "e3", "a5", "a6","b6", "d6" , "a6","e5", "e3", "a5", "a6","b6"],.6,bassoon)
   addNotes(m, ["e2", "e2", "a2", "a2","b2", "b3" , "a2","a3"],.6,sawBASS)
   append!(f,renderMeasure(m))
    wavplay(f, 41000)
    #wavwrite(f,41000,"sorting.wav")
    
end
function lfoTest()
    a = (getSine(4,"a4").+getRand(4,))/2
    cheb(x,limit)=limit*x[1]^3+(1-limit)x[1]
    a = lfo(a,.4,cheb,(.1,3.9))
    a = lfo(a,.9,cheb,(0,2))
    a = lfo(a,3,cheb,(3,4))
    wavplay(a,41000)
    
end
function chebTEST()
    cheb(x,limit)=limit*x[1]^3+(1-limit)x[1]
    bpm = 125
    m = Measure(bpm, 41000, 8,[])
    sawVelope(signal) = applyEnvelope(signal, Envelope(41000,.17,.1,.7,.1,.1))
    pad(freq) = softClip(lfo(sawVelope(getSine(1, freq))./5,.2,cheb,(2,3)),50)

    addNotes(m, ["b2", "b3", "d#3", "c3","c#3", "c#3" , "e3","e2"],1,pad)
    addNotes(m, ["f#4", "f#4", "d#4", "f#4","g#4", "g#4" , "b5","b5"],1,bassoon)
    a = renderMeasure(m)
    wavplay(a,41000)
end
function chebbyBrato()
    c(x,order) = cos(order*acos(x))
    a = (getSine(5,"f4")
    .+getSine(5,"a4")
    .+getSine(5,"c5")
    #.+getRand(5)/100
    .+getSine(5,"f2")
    )
    a = a/(maximum(a)+1)

    b = lfo(a,.5,c,(0,5))
    wavplay(b,41000)
end
function adaaTest()
    a = getSine(1,"c4")
    b = getSine(10,"f4")
    @time hardC(a,10)
    @time hardClipAD1(a,10)
    @time hardClipAD2(a,10)
    @time hardC(b,40)
    @time hardClipAD1(b,40)
    @time hardClipAD2(b,40)

    f(x) = (abs(x) < 1 ? x : sign(x) )
    f1(x) = (abs(x) < 1 ? x^2/2 : x*sign(x) - .5)
    f2(x) = (abs(x) < 1 ? x^3/6 : (x^2/2 + 1/6) * sign(x) - x/2) 


end
function whatever(x::Vector{Float64},c)::Vector{Float64}
    b = c^2
    a = 1-b-c
    f(t) = b*t + a*(4t^3-3t) + c*(16t^5-20t^3+5t)
    return f.(x)
end
function w()
    a = getRand(1)
    @time hardClipAD2(a,1)
    @time whatever(a,.5)
    @time cheb(a)
    @time hardC(a,123)
    println()

    b = getRand(100)
    @time hardClipAD2(b,1)
    @time whatever(b,.5)
    @time cheb(b)
    @time hardC(b,123)
end
function organ(note)
    hz = getFreq(note)
    return applyEnvelope(hardClipAD2(compound(hz),200), Envelope(41000.0,.15,.09,7,.1,.04))                                            
end
function slow_organ(note)
    hz = getFreq(note)
    
    return applyEnvelope(sortDistortion(softClipAD2(compound2(hz),5),50), Envelope(41000.0,.3,.19,7,.2,.15))                                            
end
function lacrimosa()
    bpm = 140
    m = Measure(bpm, 41000, 12,[])
    r = nothing
    addNotes(m, [r, "c#5", "d5", r,"a5","a#5", r,
    "d5" , "c#5",r,"c6","a#5"],1,organ)
    addNotes(m, ["d4","f4","e4","g4"],3,slow_organ)
    addNotes(m, ["f4","a4","g4","c#4"],3,slow_organ)
    audio = renderMeasure(m)

    m2 = Measure(bpm, 41000, 12,[])
    addNotes(m2, [r, "a5", "d6", r,"a#5","g5", r,
    "e5" , "f5",r,"a5","c#5"],1,organ)
    addNotes(m2, ["d5","e4","d4","g4"],3,slow_organ)
    addNotes(m2, ["f4","g3","a3","a3"],3,slow_organ)
    append!(audio, renderMeasure(m2))
    wavplay(audio,41000)
end
#disco()
lacrimosa()
#noteTest()
#main()
#chebbyBrato()
#wavplay(a,41000)
