# Distributed under the 
#
#          European Union Public Licence v. 1.2
# 
# See 
#
#          https://github.com/fjfrancopelaez/LELAPE/blob/main/LICENSE.md 
# 
# for further details.

function CheckMBUs(WORD::UInt32, PATTERN::UInt32, WordWidth::Int)::Tuple{Int, Vector{Int}}

    Signature = ExtractFlippedBits(WORD, PATTERN, WordWidth)

    return length(Signature), Signature

end


function CheckMBUs(WORDS::Vector{UInt32}, PATTERN::Vector{UInt32}, WordWidth::Int)::Tuple{Vector{Int}, Vector{Any}}

    if length(WORDS) != length(PATTERN)
        error("WORDS and PATTERN length not consistent.")
    end

    Bitflips_per_word = zeros(Int, length(WORDS))
    Bitflip_position = []

    for index in eachindex(WORDS)
        #Signature = ExtractFlippedBits(WORDS[index], PATTERN[index], WordWidth)
        
        Bitflips_per_word[index], Signature = CheckMBUs(WORDS[index], PATTERN[index], WordWidth)
        push!(Bitflip_position, Signature)

    end

    return Bitflips_per_word, Bitflip_position

end

function CheckMBUs(WORDS::Vector{UInt32}, PATTERN::UInt32, WordWidth::Int)::Tuple{Vector{Int}, Vector{Any}}
    return CheckMBUs(WORDS, PATTERN*ones(UInt32, length(WORDS)), WordWidth)
end


###################################################################
#######                                                     #######
#######      VERSION OF THE PREVIOUS FUNCTION FOR 64-bits   #######
#######                                                     #######
###################################################################


function CheckMBUs(WORD::UInt64, PATTERN::UInt64, WordWidth::Int)::Tuple{Int, Vector{Int}}

    Signature = ExtractFlippedBits(WORD, PATTERN, WordWidth)

    return length(Signature), Signature

end

function CheckMBUs(WORDS::Vector{UInt64}, PATTERN::Vector{UInt64}, WordWidth::Int)::Tuple{Vector{Int}, Vector{Any}}

    if length(WORDS) != length(PATTERN)
        error("WORDS and PATTERN length not consistent.")
    end

    Bitflips_per_word = zeros(Int, length(WORDS))
    Bitflip_position = []

    for index in eachindex(WORDS)
        #Signature = ExtractFlippedBits(WORDS[index], PATTERN[index], WordWidth)
        
        Bitflips_per_word[index], Signature = CheckMBUs(WORDS[index], PATTERN[index], WordWidth)
        push!(Bitflip_position, Signature)

    end

    return Bitflips_per_word, Bitflip_position

end

function CheckMBUs(WORDS::Vector{UInt64}, PATTERN::Integer, WordWidth::Int)::Tuple{Vector{Int}, Vector{Any}}
    return CheckMBUs(WORDS, convert(UInt64, PATTERN)*ones(UInt64, length(WORDS)), WordWidth)
end