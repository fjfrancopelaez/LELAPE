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
function SelfConsistency_index(     ADDRESSES::Vector{UInt32},  
                                    CYCLES::Vector{UInt32},
                                    Operation::String,          
                                    Candidates::Vector{UInt32},
                                    AbundCandidates::Vector{Int},
                                    LargestMCUSize::Int=200)::Vector{UInt32}

    ## it selects the anomalies in the DV set created from ADDRESSES and CYCLES. These anomalies
    # appear in CANDIDATES and are selected earlier the higher the presence in the DV set, presented
    # in ABUNDCANDIDATES. As explained in the main papers, the principle of selfconsistency establishes
    # that the abundance of the selected elements must be higher than the size of the largest MCU obtained
    # from the ADDRESSES with the selected candidates.
    #
    # To escape from unfinishable loops, a LargestMCUSize is defined to finish the program as well as to manage
    # memory.


    function SelectNotPresent(Set::Vector{UInt32}, Subset::Vector{UInt32})::Vector{Int}

    #This function returns the indexes in SET of the elements not present in SUBSET. 
    # BEWARE! I have said INDEXES, NOT THE ELEMENTS THEMSELVES.

        Selection = Int[]

        for k = 1:length(Set)

            if !(Set[k] in Subset)

                push!(Selection, k)

            end

        end

        return Selection

    end

    NCandidates = length(Candidates)

    SelectedCandidates = UInt32[]

    while true

        # INFINITE LOOP, one can escape from only if the selfconsistency is violated.

        if Operation == "XOR"

            SelectedCandidates_backup = SelectedCandidates

            UnSelectedCandidates = Candidates[SelectNotPresent(Candidates, SelectedCandidates)]

            if length(UnSelectedCandidates) == 0
                break;
                # If there are no more candidates, the program quits the loop.
            end

            UnSelectAbundances = AbundCandidates[SelectNotPresent(Candidates, SelectedCandidates)]

            LargestRepetition = maximum(UnSelectAbundances)

            NewCandidates = UnSelectedCandidates[findall(UnSelectAbundances.==LargestRepetition)]

            append!(SelectedCandidates, NewCandidates)

            MCU_Matrix = XOR_MCU_Indexes(ADDRESSES, CYCLES, SelectedCandidates, LargestMCUSize)

            NMCUs, MCUSize = size(MCU_Matrix)

            if (MCUSize > LargestRepetition)
                # Self consistency is violated. The, tht program brings back the previous set 
                # of selected candidates and quits the loop.
                # 
                SelectedCandidates = SelectedCandidates_backup
                break;

            end

        elseif Operation == "POS"
            # This block is similar to the previous one, including comments, with the excepcion
            # of the mathematical operation, which is the postive subtraction instead of xor. 
            # See comments above.
            SelectedCandidates_backup = SelectedCandidates

            UnSelectedCandidates = Candidates[SelectNotPresent(Candidates, SelectedCandidates)]

            if length(UnSelectedCandidates) == 0
                break;
            end

            UnSelectAbundances = AbundCandidates[SelectNotPresent(Candidates, SelectedCandidates)]

            LargestRepetition = maximum(UnSelectAbundances)

            NewCandidates = UnSelectedCandidates[findall(UnSelectAbundances.==LargestRepetition)]

            append!(SelectedCandidates, NewCandidates)

            MCU_Matrix = POS_MCU_Indexes(ADDRESSES, CYCLES, SelectedCandidates, LargestMCUSize)

            NMCUs, MCUSize = size(MCU_Matrix)

            if (MCUSize > LargestRepetition)

                SelectedCandidates = SelectedCandidates_backup
                break;

            end

        else
            
            error("Unknown operation. Use XOR or POS instead.")

        end

    end

    return SelectedCandidates

end
