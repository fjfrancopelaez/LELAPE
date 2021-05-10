function DetectAnomalies_Shuffle_Rule(   
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

    Histogram = CreateDVSetHistogram(DVSET, LN)

    NThreshold = MaxExpectedRepetitions(length(DVSET), LN, Operation, ϵ)

    PossibleCandidates = UInt32[]

    for k1 = 1:length(PrevCandidates)-1, k2 = k1+1:length(PrevCandidates)
        if Operation =="XOR"
            NewCandidate = xor(PrevCandidates[k1], PrevCandidates[k2])
        elseif Operation == "POS"
            NewCandidate = PosSubst(PrevCandidates[k1], PrevCandidates[k2])
        else
            error("Operation not recognisable.")
        end
        if Histogram[NewCandidate+1]>NThreshold
            append!(PossibleCandidates)
        end
    end
    
    Matrix4SMCURULE = convert.(UInt32, reshape([PossibleCandidates; Histogram[PossibleCandidates.+1]], :, 2))

    return Matrix4SMCURULE

end
