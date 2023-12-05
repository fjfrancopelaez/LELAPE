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
function MCU_Indexes(   DATA::Matrix{UInt32}, 
    OPERATION::String,
    Markers::Vector{UInt32}, 
    UsePseudoADD::Bool=false, 
    WordWidth::Int=8,
    LimitMCUSize::Int=200)::Array{Int, 2}

    ### This functions uses the DATA set to look for pairs of addresses that treated with 
    ### OPERATION yield one of the MARKERS. If an ADDRESS is related to other two addresses, 
    ### an 3-bit MCU appears (and so on.) The rest of parameters are used to provide necessary
    ### information to use the PSEUDOADDRESS instead of the WORD ADDRESS. 
    ### 
    ### More information about the inputs:
    ###
    ### DATA: A matrix with 3 or 4 columns. 
    #       -- The first one contains the word addresses in UInt32 formata.
    #       -- The second one shows the content read in the memory after the irradiation.
    #       -- The third one, the pattern that should be inside.
    #       -- The fourth one is optional and shows the namber of the read cycle if the 
    #       -- memory was read and corrected several times during the irradiation.
    ### 
    ###   OPERATION: A string variable to indicate the preferred operation to calculate
    ###       the DVSET. Only two operations are allowed: 
    ###           -- "XOR": XORing bit to bit.
    ###           -- "POS": abs(a-b)
    ###
    ###   UsePseudoADD: A boolean variable. It allows to indicate that the user wants to user
    ###       word addresses (false). If true, a pseudoaddress is assigned to each bit and calculated
    ###       as WORADDRESS*WordWidth + BitPosition. Full of sense in FPGA since it is just the position
    ###       of the bit in the bitstream, it has not physical interpretation in memories BUT works!!!!
    ###
    ###   WordWidth: The size of each word in bits, usually 8, 16. 32, etc.
    ###
    ###
    ###   LargestMCUSize: This value indicates the largest possible size for MCUs. It has not physical sense
    ###       and is only used to stop the program if unreallistic events occur. Initially set to 200.
    ###
    ###
    ### Concerning the OUTPUT: It provides am integer NMCU x LMCU matrix, NMCU being the number of detected MCUs and
    ### LMCU the size of the largest reconstructed MCU. Every value different than 0 must be determined as follows:
    ###     1) UsePseudoADD = false: The index indicates the row in DATA with the address in the MCU.
    ###     2) UsePseudoADD = true: It provides the index in the PSEUDOADDRESS derived SET. If the exact position of
    ###                             the bitcell is required, DATA should be treated with ConvertToPseudoADD() and
    ###                             the index used in the resulting matrix.
    ###     In both cases, if the size of the MCU is smaller than LMCU, the row will be filled with zeros until
    ###     reaching the desired length. For example, if the content of a row is [5 7 9 0 0], it must be interpreted
    ###     as a 3-bit MCU involving addresses indexed with 5, 7 & 9 in an experiment in which at least a 5-bit 
    ###     MCU (and nothing larger) was observed.
    ###     
    ### Finally, if the index of an address does not appear in the returned matrix, it should be interpreted as
    ### isolated and belonging to an SBU.

    ADDRESSES = ones(UInt32, length(DATA[:,1]), 2)    
    
    if UsePseudoADD

        ADDRESSES = ConvertToPseudoADD(DATA, WordWidth, true)
        # The size of the matrix is changed if there are MBUs.

    else

        ADDRESSES[:,1] = DATA[:,1]

        if length(DATA[1,:]) == 4
        
            ADDRESSES[:,2] = DATA[:,4]
    
        end

    end

    if OPERATION=="XOR"
        return XOR_MCU_Indexes(ADDRESSES[:,1], ADDRESSES[:,2], Markers, LimitMCUSize)
    elseif OPERATION == "POS"
        return POS_MCU_Indexes(ADDRESSES[:,1], ADDRESSES[:,2], Markers, LimitMCUSize)
    else
        error("Operation not recognized. Use XOR or POS instead.")
    end

end