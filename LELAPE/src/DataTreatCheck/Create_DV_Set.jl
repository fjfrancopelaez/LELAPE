function Create_XOR_DV_Set(ADDRESSES::Array{UInt32, 1})::Array{UInt32, 1}
    # A matrix with all after making and xoring all the possible pairs is returned.
    # This version does not require the presence of cycle. It is defined so to increase speed.
    NBF = length(ADDRESSES)
    NDV = div(NBF*(NBF-1), 2)
    # Transparent definitions.

    DVSET = zeros(UInt32, NDV)

    index = 1

    for add1 = 1:NBF-1
        for add2 = add1+1:NBF
            DVSET[index] = xor(ADDRESSES[add1], ADDRESSES[add2])
            index+=1
        end
    end

    return DVSET

end

function Create_POS_DV_Set(ADDRESSES::Array{UInt32, 1})::Array{UInt32, 1}
    # A matrix with all after making and xoring all the possible pairs is returned.
    # This version does not require the presence of cycle. It is defined so to increase speed.
    NBF = length(ADDRESSES)
    NDV = div(NBF*(NBF-1), 2)

    DVSET = zeros(UInt32, NDV)
    # Transparent definitions

    index = 1

    for add1 = 1:NBF-1
        for add2 = add1+1:NBF

            ADDRESSES[add2]>ADDRESSES[add1] ?
                DVSET[index] = ADDRESSES[add2]-ADDRESSES[add1] :
                DVSET[index] = ADDRESSES[add1]-ADDRESSES[add2]
                # Simple: Choose the largest one and calculates the positive subtraction.
            index+=1
        end
    end

    return DVSET

end

function Create_DV_Set(ADDRESSES::Array{UInt32, 1}, Operation::String)::Array{UInt32, 1}

    # Depending on the operation, one operation or  the other is used.
    # Alias for the two functions above.

    if Operation=="XOR"
        return Create_XOR_DV_Set(ADDRESSES)
    elseif Operation=="POS"
        return Create_POS_DV_Set(ADDRESSES)
    else
        error("Operation not understood. Use POS or XOR instead.")
    end

end

function Create_XOR_DV_Set(ADDRESSES::Array{UInt32, 1}, CYCLES::Array{UInt32,1})
    # A matrix with all after making and xoring all the possible pairs is returned.
    # However, it previously checks if the two addresses were observed during the same
    # Read & Write cycle.

    NBF = length(ADDRESSES)

    if length(CYCLES) != NBF
        error("Uuups, the CYCLE array has not the same size as the ADDRESSES vector.")
    end

    DVSET = UInt32[]

    CycleIdentifiers = union(CYCLES)
    # Thus, we get all the possible labels for the Cycles.

    for CycleName ∈ CycleIdentifiers

        CycleADDRESSES = ADDRESSES[findall(CYCLES.== CycleName)]
        # Thus, only the flipped addresses in a single cycle are used.

        append!(DVSET, Create_XOR_DV_Set(CycleADDRESSES))

    end

    return DVSET

end

function Create_POS_DV_Set(ADDRESSES::Array{UInt32, 1}, CYCLES::Array{UInt32,1})
    # A matrix with all after making and positive subtraction all the possible pairs is returned.
    # However, it previously checks if the two addresses were observed during the same
    # Read & Write cycle.

    NBF = length(ADDRESSES)

    if length(CYCLES) != NBF
        error("Uuups, the CYCLE array has not the same size as the ADDRESSES vector.")
    end

    DVSET = UInt32[]

    CycleIdentifiers = union(CYCLES)
    # Thus, we get all the possible labels for the Cycles.

    for CycleName ∈ CycleIdentifiers

        CycleADDRESSES = ADDRESSES[findall(CYCLES.== CycleName)]
        # Thus, only the flipped addresses in a single cycle are used.

        append!(DVSET, Create_POS_DV_Set(CycleADDRESSES))

    end

    return DVSET

end


function Create_DV_Set(ADDRESSES::Array{UInt32, 1},  CYCLES::Array{UInt32,1}, Operation::String)::Array{UInt32, 1}

    # Depending on the operation, one operation or  the other is used.
    # Alias for the two functions above.

    if Operation=="XOR"
        return Create_XOR_DV_Set(ADDRESSES, CYCLES)
    elseif Operation=="POS"
        return Create_POS_DV_Set(ADDRESSES, CYCLES)
    else
        error("Operation not understood. Use POS or XOR instead.")
    end

end
