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
function DetectAnomalies_SelfConsis_MassStorage(   DATA::Array{UInt32, 2},
                            WordWidth::Int,
                            LN0::Int,
                            Operation::String,
                            UsePseudoADD::Bool=true,
                            KeepCycle::Bool=true,
                            ϵ::AbstractFloat=0.001,
                            LargestMCUSize::Int=200
                        )::Array{UInt32, 2}

# This function will calculate the anomalies in the set of addresses using the SelfConsistency principle.
# First of all, let us know the inputs:
#
#   DATA: A matrix with 3 or 4 columns. 
#       -- The first one contains the word addresses in UInt32 formata.
#       -- The second one shows the content read in the memory after the irradiation.
#       -- The third one, the pattern that should be inside.
#       -- The fourth one is optional and shows the namber of the read cycle if the 
#       -- memory was read and corrected several times during the irradiation.
# 
#   WordWidth: The size of each word in bits, usually 8, 16. 32, etc.
#   LN0: The memory size in words (not in bits!!!). In many cases, 2^N
#   Operation: A string variable to indicate the preferred operation to calculate
#       the DVSET. Only two operations are allowed: 
#           -- "XOR": XORing bit to bit.
#           -- "POS": abs(a-b)
#   UsePseudoADD: A boolean variable. It allows to indicate that the user wants to user
#       word addresses (false). If true, a pseudoaddress is assigned to each bit and calculated
#       as WORADDRESS*WordWidth + BitPosition. Full of sense in FPGA since it is just the position
#       of the bit in the bitstream, it has not physical interpretation in memories BUT works!!!!
#   KeepCycle: If true, the function looks for the fourth column and uses it to calculate the DVSet.
#   ϵ: A small positive integer number to determine the threshold that defines when a number of 
#       repetitions are impossible to occur. Set by default to 0.05.
#   LargestMCUSize: This value indicates the largest possible size for MCUs. It has not physical sense
#       and is only used to stop the program if unreallistic events occur. Initially set to 200.
#
# The funcion return an Nx2 UInt32 matrix. The first column contains the anomalously repeated values of the 
# DV SET compatible with the SelfConsistency test. The second one contains the number of times they appear
# in the DV set. Due to format integrity reasons, this column is expressed in unnatural UInt32 format. 
# A latter conversion into Int will make this column more readable.
#

    ADDRESSES = ones(UInt32, length(DATA[:,1]), 2)    

    
    if UsePseudoADD

        ADDRESSES = ConvertToPseudoADD(DATA, WordWidth, KeepCycle)
        # The size of the matrix is changed if there are MBUs.
        LN = LN0*WordWidth;
        # This is the size in bits.

    else

        ADDRESSES[:,1] = DATA[:,1]
        LN = LN0

        if KeepCycle & length(DATA[1,:]) == 4
            
            ADDRESSES[:,2] = DATA[:,4]
    
        end

    end

    DVSET = Create_DV_Set(ADDRESSES[:,1],  ADDRESSES[:,2], Operation)

    Histogram = CreateDVSetHistogram_MassStorage(DVSET, LN)

    NThreshold = MaxExpectedRepetitions(length(DVSET), LN, Operation, ϵ)

    Candidates = AddressesInExcess_MassStorage(Histogram, NThreshold)

    PropoCandidatesFromSC = SelfConsistency_index(  ADDRESSES[:,1],
                                                    ADDRESSES[:,2],
                                                    Operation,
                                                    Candidates[:,1],
                                                    convert.(Int, Candidates[:,2]),
                                                    LargestMCUSize)

    Matrix4SelfConsistency = convert.(UInt32, reshape([
                                                    PropoCandidatesFromSC; 
                                                    Histogram[[findfirst(Histogram[:,1].==x) for x in PropoCandidatesFromSC], 2]
                                                    ],
                                                     :, 2))
    
    return Matrix4SelfConsistency

end

###################################################################
#######                                                     #######
#######      VERSION OF THE PREVIOUS FUNCTION FOR 64-bits   #######
#######                                                     #######
###################################################################
function DetectAnomalies_SelfConsis_MassStorage(   DATA::Array{UInt64, 2},
                            WordWidth::Int,
                            LN0::Int,
                            Operation::String,
                            UsePseudoADD::Bool=true,
                            KeepCycle::Bool=true,
                            ϵ::AbstractFloat=0.001,
                            LargestMCUSize::Int=200
                        )::Array{UInt64, 2}

# This function will calculate the anomalies in the set of addresses using the SelfConsistency principle.
# First of all, let us know the inputs:
#
#   DATA: A matrix with 3 or 4 columns. 
#       -- The first one contains the word addresses in UInt64 formata.
#       -- The second one shows the content read in the memory after the irradiation.
#       -- The third one, the pattern that should be inside.
#       -- The fourth one is optional and shows the namber of the read cycle if the 
#       -- memory was read and corrected several times during the irradiation.
# 
#   WordWidth: The size of each word in bits, usually 8, 16. 32, etc.
#   LN0: The memory size in words (not in bits!!!). In many cases, 2^N
#   Operation: A string variable to indicate the preferred operation to calculate
#       the DVSET. Only two operations are allowed: 
#           -- "XOR": XORing bit to bit.
#           -- "POS": abs(a-b)
#   UsePseudoADD: A boolean variable. It allows to indicate that the user wants to user
#       word addresses (false). If true, a pseudoaddress is assigned to each bit and calculated
#       as WORADDRESS*WordWidth + BitPosition. Full of sense in FPGA since it is just the position
#       of the bit in the bitstream, it has not physical interpretation in memories BUT works!!!!
#   KeepCycle: If true, the function looks for the fourth column and uses it to calculate the DVSet.
#   ϵ: A small positive integer number to determine the threshold that defines when a number of 
#       repetitions are impossible to occur. Set by default to 0.05.
#   LargestMCUSize: This value indicates the largest possible size for MCUs. It has not physical sense
#       and is only used to stop the program if unreallistic events occur. Initially set to 200.
#
# The funcion return an Nx2 UInt64 matrix. The first column contains the anomalously repeated values of the 
# DV SET compatible with the SelfConsistency test. The second one contains the number of times they appear
# in the DV set. Due to format integrity reasons, this column is expressed in unnatural UInt64 format. 
# A latter conversion into Int will make this column more readable.
#

    ADDRESSES = ones(UInt64, length(DATA[:,1]), 2)    

    
    if UsePseudoADD

        ADDRESSES = ConvertToPseudoADD(DATA, WordWidth, KeepCycle)
        # The size of the matrix is changed if there are MBUs.
        LN = LN0*WordWidth;
        # This is the size in bits.

    else

        ADDRESSES[:,1] = DATA[:,1]
        LN = LN0

        if KeepCycle & length(DATA[1,:]) == 4
            
            ADDRESSES[:,2] = DATA[:,4]
    
        end

    end

    DVSET = Create_DV_Set(ADDRESSES[:,1],  ADDRESSES[:,2], Operation)

    Histogram = CreateDVSetHistogram_MassStorage(DVSET, LN)

    NThreshold = MaxExpectedRepetitions(length(DVSET), LN, Operation, ϵ)

    Candidates = AddressesInExcess_MassStorage(Histogram, NThreshold)

    PropoCandidatesFromSC = SelfConsistency_index(  ADDRESSES[:,1],
                                                    ADDRESSES[:,2],
                                                    Operation,
                                                    Candidates[:,1],
                                                    convert.(Int, Candidates[:,2]),
                                                    LargestMCUSize)

    Matrix4SelfConsistency = convert.(UInt64, reshape([
                                                    PropoCandidatesFromSC; 
                                                    Histogram[[findfirst(Histogram[:,1].==x) for x in PropoCandidatesFromSC], 2]
                                                    ],
                                                     :, 2))
    
    return Matrix4SelfConsistency

end