const frequencies = Dict("c"=>16.3516,"c#"=>17.32391, "d"=>18.35405, "d#"=>19.44544, "e"=>20.60172, 
"f"=>21.82676, "f#"=>23.12465, "g"=>24.49971, "g#" => 25.95654, "a"=>27.5, "a#"=>29.13524,
"b"=>30.86771
)
#check input string to see if it matches convention
function checkInput(input::AbstractString)
    if (length(input) >3 || length(input) < 2 ) return false end
    return !isnothing(match(r"([a-g]#?[\d])"i, input))
end
#returns to correct frequency for the given note  and octave
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

