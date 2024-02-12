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
function DetectAnomalies_Trace_Rule_MassStorage(   
                            TraceRuleLength::Int, 
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

    NBits = ceil(Int, log(LN)/log(2))
    #The lowest number of bits able to represent all the addresses.

    

    if TraceRuleLength == 1

        LowTraceSet = sort(union([UInt32(2^n) for n=0:NBits-1]))
    
    elseif TraceRuleLength == 2

        LowTraceSet = sort(union([UInt32(2^n+2^m) for n=0:NBits-1, m=0:NBits-1 if m!=n]))

    elseif TraceRuleLength == 3

        LowTraceSet = sort(union([UInt32(2^n+2^m+2^p) for n=0:NBits-1, m=0:NBits-1, p=0:NBits-1 if (m!=n) & (m!=p) & (n!=p)]))

    else

        println("Nonsense value for trace.")
        return zeros(UInt32,  0, 2)

    end

    DVSET = Create_DV_Set(ADDRESSES[:,1],  ADDRESSES[:,2], Operation)
    # In computers with very small RAM this set and the following Histogram 
    # should be built only if there are New Candidates not belonging to PrevCandidates.
    # However, even in medium computers, the historgram calculation is very fast, 
    # so we decided to keep it as it is, following the principle of not improving nothing
    # if it works fine.

    Histogram = CreateDVSetHistogram_MassStorage(DVSET, LN)

    NThreshold = MaxExpectedRepetitions(length(DVSET), LN, Operation, ϵ)

    PossibleCandidates = UInt32[]

    for NewCandidate in LowTraceSet

        if NewCandidate < LN
            # 2023-02-07: Bug fixed. See https://github.com/fjfrancopelaez/LELAPE/issues/2
            if (NewCandidate in Histogram[:,1])
                if (Histogram[findfirst(Histogram[:,1].==NewCandidate),2]>NThreshold) & !(NewCandidate in PrevCandidates)
                    append!(PossibleCandidates, NewCandidate)
                end
            end
        end
    end

    
    Matrix4SMCURULE = convert.(UInt32, reshape([PossibleCandidates; Histogram[PossibleCandidates.+1]], :, 2))

    return Matrix4SMCURULE

end
