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
    # In computers with very small RAM this set and the following Histogram 
    # should be built only if there are New Candidates not belonging to PrevCandidates.
    # However, even in medium computers, the historgram calculation is very fast, 
    # so we decided to keep it as it is, following the principle of not improving nothing
    # if it works fine.

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
            append!(PossibleCandidates, NewCandidate)
            #2022-05-06: Fixed a bug here. Strangely, the original sentence was append!(PossibleCandidates), 
            # so nothing was added to the set of PossibleCandidates. However, as this rule is not very useful
            # to detect anomalies, the bug was accidentally discovered.
        end
    end
    
    Matrix4SMCURULE = convert.(UInt32, reshape([PossibleCandidates; Histogram[PossibleCandidates.+1]], :, 2))

    return Matrix4SMCURULE

end
