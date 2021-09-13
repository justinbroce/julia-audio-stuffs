include("envelope.jl")
include("distortion.jl")
include("measure.jl")
include("synth.jl")
using  WAV 
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
#wavReadTest()
#disco()
 main()
 #otherMain()