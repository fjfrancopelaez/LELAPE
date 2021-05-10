function ExtractFlippedBits(WORD::UInt32, PATTERN::UInt32, Wordwidth::Int)::Array{Int,1}
    # This function allows diwcovering the position of different bits between WORD
    # and PATTERN. It also verifies that both values are coherent with the Wordwidth,
    # meaning that neither of them are higher than 2^Wordwidth-1.
    # There is a function with similar name but different arguments below that
    # provides the position along the word.
    #
    if (WORD>=2^Wordwidth) | (PATTERN>=2^Wordwidth)
        error("WORD and/or PATTERN inputs are not representable with the present wordwidth.")
        # Self Explaining.
    else

        MASK = xor(WORD, PATTERN)
        # This operation marks flipped bits as 1 and unchanged with 0.

        FlippedBitPositions = Int[]

        for position = 0:Wordwidth-1
            # Classical algortithm. Self Explaining.
            if mod(MASK, 2)==1
                push!(FlippedBitPositions, position)
            end
            MASK = MASK >> 1

        end

    end

    return FlippedBitPositions

end

### These are different versions of the function in case the user decides not to
### use UInt32 format.

function ExtractFlippedBits(WORD::UInt16, PATTERN::UInt16, Wordwidth::Int)::Array{Int,1}

    #alias version.
    return ExtractFlippedBits(convert(UInt32, WORD), convert(UInt32, PATTERN), Wordwidth)::Array{Int,1}
end

function ExtractFlippedBits(WORD::UInt8, PATTERN::UInt8, Wordwidth::Int)::Array{Int,1}

    return ExtractFlippedBits(convert(UInt32, WORD), convert(UInt32, PATTERN), Wordwidth)::Array{Int,1}
end
