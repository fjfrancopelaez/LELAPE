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
# The decision is taken using the method presented by Perez-Celis et al. in:
#
# A. Pérez-Celis, C. Thurlow and M. Wirthlin, 
# "Identifying Radiation-Induced Micro-SEFIs in SRAM FPGAs," 
# IEEE Transactions on Nuclear Science, vol. 68, no. 10, pp. 2480-2487, Oct. 2021, 
# doi: 10.1109/TNS.2021.3108572.
# Full text found on https://doi.org/10.1109/TNS.2021.3108572. Reference it if you use this function.
#
# The idea is the following:
# 1.- Calculate the average number of bitflips per reading cycle, μ.
# 2.- The probability of occurrence follows a Poisson distribution, where P(k) = exp(-μ)·μ^k/k!
# 3.- Determine the C, C > μ, such that P(k) > 1E-10 for any k < C, but P(k) < 1E-10 for any k >= C.
# 4.- Remove the cycles with C bitflips or more.
#

function SEFI_Detection_Poisson( DATA::Matrix{UInt32},
                                    WordWidth::Int,
                                    verbose::Bool=false)
    
    NCorruptedWords, NColumns = size(DATA);

    ERROR_MESSAGE = "Apparently, no information about reading cycles in provided data."

    if (NColumns <4) 
        verbose ? println(ERROR_MESSAGE*"\t Only 3 columns.") : nothing
        return DATA, UInt32[];
    elseif (length(union(DATA[:,4]))==1)
        verbose ? println(ERROR_MESSAGE*"\t Only one cycle in 4th column.") : nothing
        return DATA, UInt32[];
    else
        FlippedBits = ConvertToPseudoADD(DATA, WordWidth, true)

        CycleLabels = union(FlippedBits[:,2])

        CycleLabels = reshape([CycleLabels; zeros(UInt32, length(CycleLabels))], :,2)

        for k = 1:length(CycleLabels[:,1])

            CycleLabels[k,2] = sum(FlippedBits[:,2].==CycleLabels[k,1])

        end

        μ = sum(CycleLabels[:,2])/length(CycleLabels[:,2])

        ExpectedUpperBound = floor(Int, μ); # C in the preamble.

        while(true)

            ExpectedOccurrences = exp(-μ)*(μ^ExpectedUpperBound)/factorial(big(ExpectedUpperBound));

            if (ExpectedOccurrences < 1E-10) # This threshold value was chosen by Perez-Celis et al.
                break;
            else
                ExpectedUpperBound += 1;
            end
        end

        FreakCycles = CycleLabels[findall(CycleLabels[:,2].>=ExpectedUpperBound), 1] 

        if length(FreakCycles)>=1
            if (verbose)
                println("Warning!!!\n---------\nAnomalous cycles:\n")
                for element in FreakCycles
                    println("\t0x"*string(element, base=16, pad=5))
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

###################################################################
#######                                                     #######
#######      VERSION OF THE PREVIOUS FUNCTION FOR 64-bits   #######
#######                                                     #######
###################################################################

function SEFI_Detection_Poisson( DATA::Matrix{UInt64},
                                    WordWidth::Int,
                                    verbose::Bool=false)
    
    NCorruptedWords, NColumns = size(DATA);

    ERROR_MESSAGE = "Apparently, no information about reading cycles in provided data."

    if (NColumns <4) 
        verbose ? println(ERROR_MESSAGE*"\t Only 3 columns.") : nothing
        return DATA, UInt64[];
    elseif (length(union(DATA[:,4]))==1)
        verbose ? println(ERROR_MESSAGE*"\t Only one cycle in 4th column.") : nothing
        return DATA, UInt64[];
    else
        FlippedBits = ConvertToPseudoADD(DATA, WordWidth, true)

        CycleLabels = union(FlippedBits[:,2])

        CycleLabels = reshape([CycleLabels; zeros(UInt64, length(CycleLabels))], :,2)

        for k = 1:length(CycleLabels[:,1])

            CycleLabels[k,2] = sum(FlippedBits[:,2].==CycleLabels[k,1])

        end

        μ = sum(CycleLabels[:,2])/length(CycleLabels[:,2])

        ExpectedUpperBound = floor(Int, μ); # C in the preamble.

        while(true)

            ExpectedOccurrences = exp(-μ)*(μ^ExpectedUpperBound)/factorial(big(ExpectedUpperBound));

            if (ExpectedOccurrences < 1E-10) # This threshold value was chosen by Perez-Celis et al.
                break;
            else
                ExpectedUpperBound += 1;
            end
        end

        FreakCycles = CycleLabels[findall(CycleLabels[:,2].>=ExpectedUpperBound), 1] 

        if length(FreakCycles)>=1
            if (verbose)
                println("Warning!!!\n---------\nAnomalous cycles:\n")
                for element in FreakCycles
                    println("\t0x"*string(element, base=16, pad=5))
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
