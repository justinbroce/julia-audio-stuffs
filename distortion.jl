using  LinearAlgebra #
using  WAV 
using  FFTW 
using  DSP
using Statistics

function hardClip(signal::AbstractVector{T}, limit::T) where 
    {T<:Real}
       0.0 <= limit <= 1.0 || throw(DomainError(limit, "limit must be between 0 and 1"))
       clip(i) = (abs(i[1]) < limit && return i[1])  || return limit > 0 ? limit : -limit
        return clip.(signal)
end    

function softClip(signal::AbstractVector{T}, limit)where
    {T<:Real}
      -1300.0 < limit < 13300.0 || throw(DomainError(limit, "limit must be between 0 and 10"))
      soft(i) = tanh(limit * i)
      return soft.(signal)
end
function chebby(signal::AbstractVector{T}, limit)where
    {T<:Real}
    0.0 <= limit <= 4.0 || throw(DomainError(limit, "limit must be between 0 and 4"))
    cheb(x)=limit*x[1]^3+(1-limit)x[1]
    return cheb.(signal)
end
function poly(weights)
  scale = sum(weights[2])
  nomials = AbstractString["(1)", "(x[1])", "(2x[1]^2-1)",
                              "(4x[1]^3-3x[1])",
                              "(8x[1]^4[1]-8x[1]^2+1)",
                              "(16x[1]^5-20x[1]^3+5x[1])",
                             "(32x[1]^6-48x[1]^4+18x[1]^2-1))",
                             "(64x[1]^7-112x[1]^5+56x[1]^3-7x[1])"]
    
    func = "x-> "           
    for i in 1:length(weights[1]) func *= nomials[i]  *= "*$(weights[2][i])/$scale + " 
    end
    func = func[1:length(func)-2]
    return func
    
    
end

function cheb(signal::AbstractVector)
  ch(val)= ((4 * val^3 - 3 * val) + (2 * val^2 - 1) + val + 1)/4
  return ch.(signal)
end

function fakebitcrush(signal::AbstractVector{T}, rate::Integer) where 
    {T<:Real}
      1 < rate <= length(signal)/rate || 
      throw(DomainError(rate, "rate must be between 0 and length(signal)/100"))
        bit(block) = mean(block)*ones(length(block))
      return applyDistortion(signal, rate, bit)
end

function linear(block)#linear regression
    linreg(x,y) = hcat(ones(size(y, 1)), y) \ x 
    timeVector = range(0.0, step=inv(41000), length=length(block))
    return linreg(block,timeVector)
end

function linearDistortion(signal::AbstractVector{T}, partition::Integer) where
    {T<:Real}
      0 < partition || throw(DomainError(iterations, "partition must be greater than or equal to 1"))
    #applies best fit apprx
    f(y,x) = y[2] .* x .+ y[1]
    line(block) = f(linear(block),range(0.0, step=inv(41000), length=length(block)))
    applyDistortion(signal, partition,line)
end

function sortDistortion(signal::AbstractVector{T}, partition::Integer) where
    {T<:Real}
      0 < partition || throw(DomainError(iterations, "partition must be greater than or equal to 1"))
    sorting(block) =  linear(block)[2] > 0 ? sort(block) : sort(block,rev=true)            
    return applyDistortion(signal, partition, sorting)
end

function applyDistortion(signal::AbstractVector{T}, increment::Integer, distortion::Function)where
    {T<:Real}
      0 < increment || throw(DomainError(increment, "increment must be greater than or equal to 1"))
    #signal to return
    newSignal = T[]  
    signalLength = length(signal)
    for index in 1:increment:signalLength
        if index + increment  > signalLength
            increment = signalLength - index +1
        end
        block = signal[index:index+increment-1]
        append!(newSignal, distortion(block))
        if index == signalLength  && length(newSignal) < signalLength  
            push!(newSignal, 80)
        end
      end
      return newSignal
end

function main()
    
    
    files = wavread.(["loudSinJingle.wav", "percussion.wav", "summerSin.wav", "violinThing.wav"])
    filesF64 = [] # the float array vector
    for i in files
        push!(filesF64, i[1][:,2])
    end
    f = filesF64[2]
    
    f = softClip(f,12.1)
   wavplay(f,41000)
    
end
