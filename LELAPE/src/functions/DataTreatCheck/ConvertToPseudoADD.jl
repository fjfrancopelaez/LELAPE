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
function ConvertToPseudoADD(DATA::Array{UInt32}, WordWidth::Int, KeepCycle::Bool=false)::Array{UInt32, 2}
    #
    # This function looks for the flipped bits between words in the second
    # and third column. It does not matter if there are several. The pseudoaddress
    # of each, defined as WORDADDRESS*Wordwith+Bitposition is returned as a vector.
    #
    # In the case of there is information about the different cycles, it can be
    # kept in the optional second column.
    #
    #
    FlippedBitMask = xor.(DATA[:,2], DATA[:,3])
    # Flipped bits will be marked with ones, correct ones as zeros.

    length(DATA[1, :])==4 ? CyclePresence = true : CyclePresence = false
    # This simple instruction detects if DATA is Nx3 or Nx4, indicating the presence of a column
    # with information about the cycle.

    NAddresses = length(FlippedBitMask)
    #Oboviosuly, number of word addresses. 
    
    PseudoAddresses = ones(UInt32, NAddresses*WordWidth, 2)
    # Reserving memory for the worst case. The first caolumn is the pseudoaddress, the second one the cycle.
    # If there is no information about the cycle, this column will be returned as full of ones, fomrally 
    # indicating a unique cycle.
    
    PseudoAdd_index = 1

    for WordAdd_index = 1:NAddresses

        FlippedBitPositions = ExtractFlippedBits(FlippedBitMask[WordAdd_index], 0x00000, WordWidth)
        #inside every word there can be several bitflips. This function returns those bits with 1 instead of 0.
        # The index is 0 for the LSB, WordWidth-1 for the mSB. 

        for bit_index in FlippedBitPositions

            PseudoAddresses[PseudoAdd_index, 1] = convert(UInt32,
                            DATA[WordAdd_index, 1]*WordWidth + bit_index)
            # This is the definition.
            
            if KeepCycle & CyclePresence
                    PseudoAddresses[PseudoAdd_index, 2] = DATA[WordAdd_index, 4] 
                    # Only in this case the fourth column is preserved. If not, returned as 1s.
            end

            PseudoAdd_index +=1

        end

    end

    return PseudoAddresses[1:PseudoAdd_index-1, :]
    #only the relevant values are returned.

end
