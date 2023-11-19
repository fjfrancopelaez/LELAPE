function DetectAnomalies_FullCheck_MassStorage(   DATA::Array{UInt32, 2},
                            WordWidth::Int,
                            LN0::Int,
                            Operation::String,
                            TraceRuleLength::Int, 
                            UsePseudoADD::Bool,
                            KeepCycle::Bool,
                            ϵ::AbstractFloat=0.05,
                            LargestMCUSize::Int=200
                        )::Tuple{Array{UInt32, 2}, Array{UInt32, 2},Array{UInt32, 2},Array{UInt32, 2}}

# This function will calculate the anomalies in the set of addresses using the all of the available strategies for
# a given operation. 
#
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
#   TraceLength: Used to look for candidates with low number of 1s in binary format. Restricted
#       to 1, 2, 3. It is a top value. Therefore, if you type 2, trace values of 1 and 2 are checked.
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
# The funcion returns several Nx2 UInt32 matrix. The first column contains the anomalously repeated values of the 
# DV SET compatible with the SelfConsistency test. The second one contains the number of times they appear
# in the DV set. Due to format integrity reasons, this column is expressed in unnatural UInt32 format. 
# A latter conversion into Int will make this column more readable.
#
# The order in which matrix are returned are:
#
# 1) Candidates from SelfConsistency.
# 2) Candidates from the MCU rule.
# 3) Candidates after XORing elements got from the SelfConsistency rule.
# 4) Candidates from the Trace rule.


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

    PropoCandidatesFromSC = SelfConsistency_index( ADDRESSES[:,1],
                                                ADDRESSES[:,2],
                                                Operation,
                                                Candidates[:,1],
                                                convert.(Int, Candidates[:,2]),
                                                LargestMCUSize)

    # Removed from old version
    # Matrix4SelfConsistency = convert.(UInt32, reshape([PropoCandidatesFromSC; Histogram[PropoCandidatesFromSC.+1]], :, 2))
    #
    Matrix4SelfConsistency = convert.(UInt32, reshape([PropoCandidatesFromSC; Histogram[[findfirst(Histogram[:,1].==x) for x in PropoCandidatesFromSC], 2]] , :, 2))
    # Now, the MCU Rule:

    PrevCandidates = Matrix4SelfConsistency[:,1]

    if length(PrevCandidates) > 1
            
        if Operation == "XOR"

            MCU_Index = XOR_MCU_Indexes(ADDRESSES[:, 1], ADDRESSES[:, 2], PrevCandidates, LargestMCUSize)

        elseif Operation == "POS"

            MCU_Index = POS_MCU_Indexes(ADDRESSES[:, 1], ADDRESSES[:, 2], PrevCandidates,  LargestMCUSize)

        else

            error("Operation not allowed.")

        end
            
        length(MCU_Index) != 0 && length(MCU_Index[1, :]) > 2 ?
            LargeMCUIndexes = findall(MCU_Index[:,3].!=0) :
            LargeMCUIndexes = UInt32[]
        # These are the rows where there are more than 2 SBUs.

        PossibleCandidates = UInt32[]

        for index in LargeMCUIndexes

            MCU_size = findlast(MCU_Index[index,:].!=0)

            for k1 = 1:MCU_size-1, k2 = k1+1:MCU_size

                if Operation == "XOR"
                            
                    append!(PossibleCandidates, xor(ADDRESSES[MCU_Index[index, k1]],ADDRESSES[MCU_Index[index, k2]] ))
                        
                elseif Operation =="POS"

                    append!(PossibleCandidates, PosSubst(ADDRESSES[MCU_Index[index, k1]],ADDRESSES[MCU_Index[index, k2]] ))
                    
                else

                    error("Provided operation is not understood. Exiting...")
                    
                end
                    
                    
            end

        end

        PossibleCandidates = union(PossibleCandidates)

        ConfirmPossibleCandidates = union(PossibleCandidates)

        PossibleCandidates_Indexes = [findfirst(Histogram[:,1].==x) for x in PossibleCandidates]

        ConfirmedCandidates = UInt32[];

        for NewCandidate in PossibleCandidates_Indexes

            if (Histogram[NewCandidate, 2]>NThreshold) & !(Histogram[NewCandidate,1] in PrevCandidates) & !(Histogram[NewCandidate,1] in ConfirmedCandidates[:,1])
                append!(ConfirmedCandidates, Histogram[NewCandidate,:]')
            end

        end
        
        Matrix4SMCURULE = convert.(UInt32, reshape(ConfirmedCandidates', :, 2))

    else

        Matrix4SMCURULE = zeros(UInt32, 0, 2)

    end 

    ### Now, let us shuffle the possible values got during the first iteration.

    PossibleCandidates = UInt32[]

    for k1 = 1:length(PrevCandidates)-1, k2 = k1+1:length(PrevCandidates)

        if Operation =="XOR"
            NewCandidate = xor(PrevCandidates[k1], PrevCandidates[k2])
        elseif Operation == "POS"
            NewCandidate = PosSubst(PrevCandidates[k1], PrevCandidates[k2])
        else
            error("Operation not recognisable.")
        end

        if (NewCandidate in Histogram[:,1]) 
            if (Histogram[findfirst(Histogram[:,1].==NewCandidate),2]>NThreshold) & !(NewCandidate in PrevCandidates) & !(Histogram[NewCandidate,1] in ConfirmedCandidates[:,1])
                append!(PossibleCandidates, NewCandidate)
            end
        end
    end
    
    #Matrix4SMCURULE = convert.(UInt32, reshape([PossibleCandidates; [Histo]], :, 2))

    if length(PossibleCandidates)>0

        Matrix4SHUFFLERULE = convert.(UInt32, reshape([PossibleCandidates; [Histogram[x,2] for x in 1:length(Histogram[:,1]) if Histogram[x, 1] in PossibleCandidates]], :, 2))
  
    else

        Matrix4SHUFFLERULE = zeros(UInt32, 0, 2)

    end
    
    # Finally, the TraceLength rule.

    NBits = ceil(Int, log(LN)/log(2))
    #The lowest number of bits able to represent all the addresses.    

    if TraceRuleLength == 1

        LowTraceSet = sort(union([UInt32(2^n) for n=0:NBits-1]))
    
    elseif TraceRuleLength == 2

        LowTraceSet = sort(append!(
                                    union([UInt32(2^n) for n=0:NBits-1]), 
                                    union([UInt32(2^n+2^m) for n=0:NBits-1, m=0:NBits-1 if m!=n]) 
                            )   )

    elseif TraceRuleLength == 3

        LowTraceSet = sort(append!(
                                    union([UInt32(2^n) for n=0:NBits-1]), 
                                    union([UInt32(2^n+2^m) for n=0:NBits-1, m=0:NBits-1 if m!=n]),
                                    union([UInt32(2^n+2^m+2^p) for n=0:NBits-1, m=0:NBits-1, p=0:NBits-1 if (m!=n) & (m!=p) & (n!=p)]) 
                            )   )
    else

        println("Nonsense value for trace.")
        return zeros(UInt32,  0, 2)

    end

    PossibleCandidates = UInt32[]

    for NewCandidate in LowTraceSet

        if (NewCandidate in Histogram[:,1])
            if (Histogram[findfirst(Histogram[:,1].==NewCandidate),2]>NThreshold) & !(NewCandidate in PrevCandidates)  & !(Histogram[NewCandidate,1] in ConfirmedCandidates[:,1])
                append!(PossibleCandidates, NewCandidate)
            end
        end

    end

    
    Matrix4TRACERULE = convert.(UInt32, reshape([PossibleCandidates; Histogram[PossibleCandidates.+1]], :, 2))

    #### Nothing else to do. Returning to the main program.

    return Matrix4SelfConsistency, Matrix4SMCURULE, Matrix4SHUFFLERULE, Matrix4TRACERULE

end
