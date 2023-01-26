function DetectAnomalies_MCU_Rule_MassStorage(   
                            PrevCandidates::Array{UInt32,1},
                            DATA::Array{UInt32, 2},
                            WordWidth::Int,
                            LN0::Int,
                            Operation::String,
                            UsePseudoADD::Bool,
                            KeepCycle::Bool,
                            ϵ::AbstractFloat=0.05,
                            LargestMCUSize::Int=200
                        )::Array{UInt32, 2}

    if length(PrevCandidates) > 1
    # This only makes sense if there is, at least, a couple of PrevCandidates.

        if UsePseudoADD

            ADDRESSES = ConvertToPseudoADD(DATA, WordWidth, KeepCycle)
            LN = LN0*WordWidth;

        else

            ADDRESSES = ones(UInt32, length(DATA[:,1]), 2)
            LN = LN0

            if length(DATA[1,:]) == 4

                ADDRESSES[:,1] = DATA[:,1]
                ADDRESSES[:,2] = DATA[:,4]

            end

        end
        
        DVSET = Create_DV_Set(ADDRESSES[:,1],  ADDRESSES[:,2], Operation)

        Histogram = CreateDVSetHistogram_MassStorage(DVSET, LN)

        NThreshold = MaxExpectedRepetitions(length(DVSET), LN, Operation, ϵ)

        if Operation == "XOR"

            MCU_Index = XOR_MCU_Indexes(ADDRESSES[:, 1], ADDRESSES[:, 2], PrevCandidates)

        elseif Operation == "POS"

            MCU_Index = POS_MCU_Indexes(ADDRESSES[:, 1], ADDRESSES[:, 2], PrevCandidates)

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

        ConfirmedCandidates = UInt32[]

        PossibleCandidates_Indexes = [findfirst(Histogram[:,1].==x) for x in PossibleCandidates]

        for NewCandidate in PossibleCandidates_Indexes

            if (Histogram[NewCandidate, 2]>NThreshold) & !(Histogram[NewCandidate,1] in PrevCandidates)
                append!(ConfirmedCandidates, Histogram[NewCandidate,1])
            end

        end

        if length(ConfirmedCandidates)>0

            Matrix4SMCURULE = convert.(UInt32, reshape([ConfirmedCandidates; [Histogram[x,2] for x in 1:length(Histogram[:,1]) if Histogram[x, 1] in ConfirmedCandidates]], :, 2))
      
        else

            Matrix4SMCURULE = zeros(UInt32, 0, 2)

        end

    else

        Matrix4SMCURULE = zeros(UInt32, 0, 2)

    end

    return Matrix4SMCURULE

end
