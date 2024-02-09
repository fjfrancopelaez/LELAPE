# Distributed under the 
#
#          European Union Public Licence v. 1.2
# 
# See 
#
#          https://github.com/fjfrancopelaez/LELAPE/blob/main/LICENSE.md 
# 
# for further details.

# This function used the original set of DATA, supposed to include 4 columns, the last of which containing
# the labels of the reading cycles, and detect the cycles where potential SEFIs have occurred.  
# 
#  The idea of this method is quite simple. Accepting that the cross section for any MCU is constant throughout the 
#  whole device and that the flux is homogeneous, the probability of a cell being fflipped is constant and extremely low.
#  Therefere, it is quite strange that a cell appears many times in the recorded DATA. It does not matter if the
#  cell is affected following an SBU or an MCU, since both phenomena are random, and differences appear only in the
#  difference-of-addresses set. 
#
# However, if there are SEFI, microlatchup, stuck bits, etc., a cell will many times more than expected. Hence, we will calculate
# the probability of occurrence with the function CombinedProbability, select the value CUTOFF for which
# this probability is lower than 0.001 (just line in SEFI_Detection_Binomial), and mark the addresses that too often appeared.

function CombinedProbability(   n::Int, 
                                L::Int, 
                                ADDRESS::Matrix{UInt32})
    ## See the end of the file for understanding.
   
    CycleLabels = union(ADDRESS[:,2])
    CycleLabels = reshape([CycleLabels; zeros(UInt32, length(CycleLabels))], :,2)

    NC = length(CycleLabels[:,1]);

    NBitFlips = length(ADDRESS[:,1]);

    μ = NBitFlips/NC; # Number of average bitflips per cycle.

    p = μ/L; # experimental avergage probability of being flipped.

    P = p^n*(1-p)^(NC-n)

    for k = 1:n
            
        P*= (NC-k+1);

    end

    return P

end

    
function SEFI_Detection_Binomial(   DATA::Matrix{UInt32},
                                    WordWidth::Int,
                                    LA::Int,
                                    UsePseudoAddress::Bool = true,
                                    ReturnCleanSetAddresses::Bool=true,
                                    verbose::Bool=false)
    
    ϵ = 0.001
    
    NCorruptedWords, NColumns = size(DATA);

    ERROR_MESSAGE = "Apparently, no information about reading cycles in provided data."

    if (NColumns <4) 
        verbose ? println(ERROR_MESSAGE*"\t Only 3 columns.") : nothing
        return DATA, UInt32[];
    elseif (length(union(DATA[:,4]))==1)
        verbose ? println(ERROR_MESSAGE*"\t Only one cycle in 4th column.") : nothing
        return DATA, UInt32[];
    else

        if (UsePseudoAddress)

            FlippedBits = ConvertToPseudoADD(DATA, WordWidth, true)

        else

            FlippedBits = reshape([DATA[:, 1];DATA[:,4]], :,2) # A new matrix with Word ADDRESS + Cycles            #FlippedBits = DATA[:, 1]

        end
        
        AffectedAddresses = reshape([union(FlippedBits[:,1]); zeros(UInt32, length(union(FlippedBits[:,1])))],:,2)

        for k = 1:length(union(AffectedAddresses[:,1]))

            AffectedAddresses[k,2] = sum(FlippedBits[:,1].==AffectedAddresses[k,1])
        end

        ncutoff = 1;

        UsePseudoAddress ? L = LA*WordWidth : L = LA;

        while (true)

            ncutoff +=1;

            if CombinedProbability(ncutoff, L, FlippedBits)*L<ϵ
                break;
            end
        end

        FreakAddresses = AffectedAddresses[findall(AffectedAddresses[:,2].>=ncutoff), :]

        if (ReturnCleanSetAddresses)

            
            FreakAddressIndex=[];

            for element  in FreakAddresses[:,1]

                FreakAddressIndex = [FreakAddressIndex;findall(FlippedBits[:, 1].==element) ]
            
            end

            FreakAddressIndex = union(FreakAddressIndex)

            if length(FreakAddresses)>=1
                if (verbose)
                    println("Warning!!!\n---------\nAnomalous Addresses:\n")
                    for element in FreakAddresses[:,1]
                        println("\t0x"*string(element, base=16, pad=7))
                    end
                    println();
                end

            else

                verbose ? println("No hints of SEFIs.") : nothing

            end
            
            goodAddressIndexes = setdiff(collect(1:length(FlippedBits[:,1])), FreakAddressIndex)

            return FlippedBits[goodAddressIndexes, :], FreakAddresses

        else


            FreakCycles = [];

            for element in FreakAddresses[:, 1]

                FreakCycles=[FreakCycles; FlippedBits[findall(FlippedBits[:,1].==element), 2]]

            end

            FreakCycles = union(FreakCycles);

            if length(FreakCycles)>=1
                if (verbose)
                    println("Warning!!!\n---------\nAnomalous cycles:\n")
                    for element in FreakCycles
                        println("\t0x"*string(element, base=16, pad=6))
                    end
                    println();

                    print("Affected Addresses\n-------------------\n")
                    for element in FreakAddresses[:,1]
                        println("\t0x"*string(element, base=16, pad=8))
                    end
                    println();
                end

            else
                verbose ? println("No hints of SEFIs.") : nothing
            end

            FreakIndexes =Int[]

            for freakcycle in FreakCycles
                FreakIndexes=[FreakIndexes; findall(DATA[:,4].==freakcycle)];
            end

            goodcycle_indexes = setdiff(collect(Int, 1:NCorruptedWords), FreakIndexes)

            return DATA[goodcycle_indexes, :], FreakCycles;
        end

    end
end

# Appendix:
# Let suppose that we have done an irradiation test in which there have being NC cycles and getting Nk bitflips in the cycle Sk.
# The probability of an address appearing several times is equivalent to those explaining the binomial distribution. The expressions
# are easy to obtain just multipliying the probability of a value being present in M especific values and absent in NC-M, and
# adding all the possible case. 
#
# However, this expressions are really hard to calculate. For simplicity, we suppose that all the cycles are equivalent with the 
# average probability p=NBitFlips/NC/L and making calculations. In this case, the probability of an element appearing M tiems being:

# P(0) = (1-p)^NC
# P(M) = NC*(NC-1)*...*(NC-M+1)*p^M*(1-p)^(NC-M)
#
