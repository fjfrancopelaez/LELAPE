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
function DetectAnomalies_Shuffle_Rule_MassStorage(   
                            PrevCandidates::Array{UInt32,1},
                            DATA::Array{UInt32, 2},
                            WordWidth::Int,
                            LN0::Int,
                            Operation::String,
                            UsePseudoADD::Bool,
                            KeepCycle::Bool,
                            ϵ::AbstractFloat=0.001
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

    Histogram = CreateDVSetHistogram_MassStorage(DVSET, LN)

    NThreshold = MaxExpectedRepetitions(length(DVSET), LN, Operation, ϵ)

    ConfirmedCandidates = UInt32[]

    for k1 = 1:length(PrevCandidates)-1, k2 = k1+1:length(PrevCandidates)
        if Operation =="XOR"
            NewCandidate = xor(PrevCandidates[k1], PrevCandidates[k2])
        elseif Operation == "POS"
            NewCandidate = PosSubst(PrevCandidates[k1], PrevCandidates[k2])
        else
            error("Operation not recognisable.")
        end
        if (NewCandidate in Histogram[:,1])
            if (Histogram[findfirst(Histogram[:,1].==NewCandidate), 2]>NThreshold) & !(NewCandidate in PrevCandidates)
                append!(ConfirmedCandidates, NewCandidate)           
            end
        end
    end
    
    if length(ConfirmedCandidates)>0

        Matrix4SMCURULE = convert.(UInt32, reshape([ConfirmedCandidates; [Histogram[x,2] for x in eachindex(Histogram[:,1]) if Histogram[x, 1] in ConfirmedCandidates]], :, 2))
  
    else

        Matrix4SMCURULE = zeros(UInt32, 0, 2)

    end
    
    return Matrix4SMCURULE

end

###################################################################
#######                                                     #######
#######      VERSION OF THE PREVIOUS FUNCTION FOR 64-bits   #######
#######                                                     #######
###################################################################

function DetectAnomalies_Shuffle_Rule_MassStorage(   
                            PrevCandidates::Array{UInt64,1},
                            DATA::Array{UInt64, 2},
                            WordWidth::Int,
                            LN0::Int,
                            Operation::String,
                            UsePseudoADD::Bool,
                            KeepCycle::Bool,
                            ϵ::AbstractFloat=0.001
                        )::Array{UInt64, 2}

    if UsePseudoADD

        ADDRESSES = ConvertToPseudoADD(DATA, WordWidth, KeepCycle)
        LN = LN0*WordWidth;

    else

        ADDRESSES = ones(UInt64, length(DATA[:,1]), 2)
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

    Histogram = CreateDVSetHistogram_MassStorage(DVSET, LN)

    NThreshold = MaxExpectedRepetitions(length(DVSET), LN, Operation, ϵ)

    ConfirmedCandidates = UInt64[]

    for k1 = 1:length(PrevCandidates)-1, k2 = k1+1:length(PrevCandidates)
        if Operation =="XOR"
            NewCandidate = xor(PrevCandidates[k1], PrevCandidates[k2])
        elseif Operation == "POS"
            NewCandidate = PosSubst(PrevCandidates[k1], PrevCandidates[k2])
        else
            error("Operation not recognisable.")
        end
        if (NewCandidate in Histogram[:,1])
            if (Histogram[findfirst(Histogram[:,1].==NewCandidate), 2]>NThreshold) & !(NewCandidate in PrevCandidates)
                append!(ConfirmedCandidates, NewCandidate)           
            end
        end
    end
    
    if length(ConfirmedCandidates)>0

        Matrix4SMCURULE = convert.(UInt64, reshape([ConfirmedCandidates; [Histogram[x,2] for x in eachindex(Histogram[:,1]) if Histogram[x, 1] in ConfirmedCandidates]], :, 2))
  
    else

        Matrix4SMCURULE = zeros(UInt64, 0, 2)

    end
    
    return Matrix4SMCURULE

end
