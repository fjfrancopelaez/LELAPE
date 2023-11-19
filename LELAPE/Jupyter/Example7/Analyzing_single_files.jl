### Defining the path to LELAPE
### If you have included this in the Julia configuration file, comment it.
push!(LOAD_PATH, "/home/francisco/UCM/LELAPE/LELAPE-git/LELAPE/LELAPE/src"); # <-- ADAPT THIS INSTRUCTION TO YOUR COMPUTER!
# If you are a Windows user, remember that subfolders are indicated with \\ or /, NEVER with a simple backslash.

using DelimitedFiles, LELAPE, Printf

#################################################### 
###
###     Loading analysis setup parameters
###
####################################################
include("Analysis.conf")
####################################################

DATA = readdlm(File, ',', UInt32, '\n', skipstart=1); # This instructions reads csv files.

println("--------------------------------------")
println("This is the analysis of $File file.")
println("--------------------------------------")
println("\nFirst of all, let us investigate the presence of MBUs.")

MBUSize, MBU_bit_pos = CheckMBUs(DATA[:,2], DATA[:,3], WordWidth)

#### Now, let us calculate the number of bitflips.

NBitFlips = sum(MBUSize); # MBUSize is a vector the length of which is the number of corrupted words, and its content the number of affected bits.
println("\n**********************************");
println("--> Number of bitflips: $NBitFlips");
println("**********************************");

####################################################

println("\nNumber of MBUs with different sizes \n")
println("Size\tOccurrences")
println("----\t-----------")
for size = 1: WordWidth
    NMBUs = length(findall(MBUSize.==size))
    NMBUs!=0 ? println("$size   \t", NMBUs) : nothing
end

NFalse2BitMCUs = NF2BitMCUs(NBitFlips, LA, "MBU", WordWidth, WordWidth);

@printf("\nExpected number of false 2-bit MBUs: %.3f\n", NFalse2BitMCUs)

###############################

println("\n**********************************\n");
println("Now, we will study the occurrence of MCUs with statistical methods.\n")

C1_SCY, C1_MCU, C1_SHF, C1_TRC = DetectAnomalies_FullCheck(DATA, WordWidth, LA, Operation, TraceRuleLength, UsePseudoAddress, KeepCycles, ϵ, LargestMCUSize)


println("Elements appearing more than expected and passing the Self-Consistency test:\n")
    for index in 1:length(C1_SCY[:, 1])
        println("\tValue: 0x", string(C1_SCY[index, 1], base=16, pad = 6), "  (", Int(C1_SCY[index, 1]), ") --> ", Int(C1_SCY[index, 2]),".")
    end
 
    println("\nOnly up to ", MaxExpectedRepetitions(NPairs(DATA, UsePseudoAddress, WordWidth, KeepCycles), LA, Operation, ϵ)-1, " repetitions are explained by randomness.\n")

    println("New anomalies issued from:\n")
    if length(C1_MCU[:,1])>1
        println("\tMCU rule:\n")
        for index in 1:length(C1_MCU[:, 1])
            if C1_MCU[index, 1] ∉ C1_SCY[:,1]
                println("\t  Value: 0x", string(C1_MCU[index, 1], base=16, pad = 6), "  (", Int(C1_MCU[index, 1]), ") --> ", Int(C1_MCU[index, 2]),".")
            end
        end
    else
        println("\tMCU rule issued no candidates!!!\n")

    end

    if length(C1_TRC[:,1])>1
        println("\tTrace rule:\n")
        for index in 1:length(C1_TRC[:, 1])
            if C1_TRC[index, 1] ∉ C1_SCY[:,1]
                println("\t  Value: 0x", string(C1_TRC[index, 1], base=16, pad = 6), "  (", Int(C1_TRC[index, 1]), ") --> ", Int(C1_TRC[index, 2]),".")
            end
        end
    else
        println("\n\tTrace rule issued no candidates!!!\n")

    end

    if length(C1_SHF[:,1])>1
        println("\tShuffle rule:\n")
        for index in 1:length(C1_SHF[:, 1])
            if C1_SHF[index, 1] ∉ C1_SCY[:,1]
                println("\t  Value: 0x", string(C1_SHF[index, 1], base=16, pad = 6), "  (", Int(C1_SHF[index, 1]), ") --> ", Int(C1_SHF[index, 2]),".")
            end
        end
    else
        println("\n\tShuffle rule issued no candidates!!!\n")

    end

    Anomalies = union(C1_SCY[:,1], C1_MCU[:,1], C1_TRC[:,1], C1_MCU[:,1])

    UsePseudoAddress ? L = LA*WordWidth : L = LA

    println("\n**********************************\n");
    println("Number of detected MCUs according to their multiplicity:\n")
    println("\tSize\tOccurrences")
    println("\t----\t-----------")

    if length(Anomalies) > 0
        Labeled_addresses = MCU_Indexes(DATA, Operation, Anomalies, UsePseudoAddress, WordWidth)
        Events = Classify_Addresses_in_MCU(DATA, Labeled_addresses, UsePseudoAddress, WordWidth)
        

        for k = 1:length(Events) 
            NMCUs = length(Events[k][:, 1])
            println("\t$(length(Events)-k+1)\t$NMCUs ")
        end
        println();
    else
        
        println("\t$NBitFlips\t 1")
    end

    NF2BIT = NF2BitMCUs(DATA, LA, Operation, length(Anomalies), WordWidth, KeepCycles, UsePseudoAddress)

    @printf("\nExpected number of false 2-bit MCUs: %.3f\n", NF2BIT)

    println("\n****************************************************************");
    println("Now, for tracking purposes, the multiple events will be depicted. ")
    println("In this analysis, pseudoaddress is ADDRESS x WordWith + Position. ")
    println("It is easily reversed.")
    println("--------------------------------------------\n");

    if length(Anomalies)>0
        for k = 1:length(Events) 
            NMCUs = length(Events[k][:, 1])
            println("Pseudoaddresses involved in $(length(Events)-k+1)-bit MCUs ($NMCUs events):")
            if NMCUs != 0
                for row = 1:NMCUs
                    for bit = 1:length(Events)-k+1
                        print("0x", string(Events[k][row, bit], base=16, pad = 6),)
                        #print(Events[k][row, bit])
                        bit != length(Events)-k+1 ? print(", ") : print("\n")

                    end
                end
            end
            println()
        end
    else
        println("Pseudoaddresses involved in SBUs ($NBitFlips events):")
                    
        for k = 1:length(DATA[:,1])
            print("0x", string(DATA[k,1]*WordWidth+MBU_bit_pos[k][1], base=16, pad = 6),"\n")
            #print(Events[k][row, bit])
        end
    end

