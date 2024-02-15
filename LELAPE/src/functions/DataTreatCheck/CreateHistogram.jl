# Distributed under the 
#
#          European Union Public Licence v. 1.2
# 
# See 
#
#          https://github.com/fjfrancopelaez/LELAPE/blob/main/LICENSE.md 
# 
# for further details.
#
function CreateDVSetHistogram(SET::Array{UInt32, 1}, LN::Int)::Array{Int, 1}

    # It checks the number of elements present in the DV Histogram and returns the
    # number of times that every possible element appear.
    #
    # LN is the memory size.
    #
    # Only are possible elements from 0 to LN-1. Besides, the value at positon X
    # is associated with the the value unsigned N-bit X-1. Thus, the first element
    # is related to 0x00000.
    #

    if maximum(SET) > (LN-1)
        error("Something wrong... an element of the DV set is larger than the memory size.")
    else

        Histogram = zeros(Int, LN)

        for element ∈ SET

            Histogram[element + 1] += 1
            # Address 0x000 --> Index 1. Clear?

        end

        return Histogram

    end

end

function CreateDVSetHistogram(SET::Array{UInt64, 1}, LN::Int)::Array{Int, 1}

    # It checks the number of elements present in the DV Histogram and returns the
    # number of times that every possible element appear.
    #
    # LN is the memory size.
    #
    # Only are possible elements from 0 to LN-1. Besides, the value at positon X
    # is associated with the the value unsigned N-bit X-1. Thus, the first element
    # is related to 0x00000.
    #

    if maximum(SET) > (LN-1)
        error("Something wrong... an element of the DV set is larger than the memory size.")
    else

        Histogram = zeros(Int, LN)

        for element ∈ SET

            Histogram[element + 1] += 1
            # Address 0x000 --> Index 1. Clear?

        end

        return Histogram

    end

end
