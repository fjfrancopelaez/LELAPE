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
function NF2BitMCUs(NSBU::Int, LA::Int, METHOD::String, D::Int, WordWidth::Int, UsePseudoAddress::Bool=false)::Float64
    # indicates the expected number of false 2-bit MCUs that will occur 
    # in a memory with LA words with WORDWIDTH bits each in which NSBU SBUs have occurred. In this analysis,
    # MCUS are sought using some grouping method (METHOD) with a generalized distance D.HD
    #
    # Admitted values for METHOD and D are the following:
    #   
    #   1) METHOD: "MBU" --> Only MBUs are sought. In this case, D is the Wordwidth.
    #   2) METHOD: "MHD" --> Only possible if the user has been able to place the ExtractFlippedBits
    #                        cell in the XY plane. Two cells are related if |x1-x2|+|y1-y2| <= D. This 
    #                        is the Manhattan distance.
    #   3) METHOD: "IND" --> Only possible if the user has been able to place the ExtractFlippedBits
    #                        cell in the XY mplane. Two cells are related if max(|x1-x2|,|y1-y2|) <= D.
    #                        In mathematics, this is the "infinite distance".
    #   4) METHOD: "THD" --> Only valid if pairs of bitflips are located in a linear bitstream and if the
    #                        distace between cells is smaller than D: |x1-x2| <= D.
    #   5) METHOD: "XOR" --> Related pairs are got by means of statistical deviations. Addresses are XORed 
    #                        and only if the value is one of the D possible critical values. If the WORD Addresses  
    #                        is used instead of PSEUDOADDRESS, the memory size must be expressed in WORDs, 
    #                        LA = LN/WordWidth.
    #                        IF SO, THE WORDWIDTH MUST BE PROVIDED.
    #   6) METHOD: "POS" --> Identical to the previous one but with positive subtraction instead of XOR.
    # 
    #   Everything can be found in Eq. 11 of F. J. Franco, J. A. Clemente, G. Korkian, 
    #   J. C. Fabero, H. Mecha and R. Velazco, "Inherent Uncertainty in the Determination of Multiple 
    #   Event Cross Sections in Radiation Tests," IEEE Transactions on Nuclear Science, vol. 67, no. 7, 
    #   pp. 1547-1554, July 2020, doi: 10.1109/TNS.2020.2977698.
    #
    #
    #   First, the memory size if corrected in case WORD ADDRESS is used in XOR or POS.  


    (METHOD in ["XOR", "POS"]) & !UsePseudoAddress ? LN = LA : LN = LA*WordWidth

    # Now, the size of the influence area.
    if METHOD == "MBU" 
        S1 = (D-1)
    elseif METHOD == "MHD"
        S1 = 2*D*(D+1)
    elseif METHOD == "IND"
        S1 = 4*D*(D+1)
    elseif METHOD == "THD"
        S1 = 2*(D-1)
    elseif METHOD == "XOR"
        S1 = D
    elseif METHOD == "POS"
        S1 = 2D
    else
        error("Unknown operation!!!!")

    end

    return NPairs(NSBU)*S1/LN

end

function NF2BitMCUs(DATA::Array{UInt32}, LA::Int, METHOD::String, D::Int, 
    WordWidth::Int, KeepCycle::Bool=false, UsePseudoADD::Bool=false)::Float64

    
    NDV = NPairs(DATA, UsePseudoADD, WordWidth, KeepCycle)
    
    (METHOD in ["XOR", "POS"]) & !UsePseudoADD ? LN = LA : LN = LA*WordWidth

    # Now, the size of the influence area.
    if METHOD == "MBU" 
        S1 = (D-1)
    elseif METHOD == "MHD"
        S1 = 2*D*(D+1)
    elseif METHOD == "IND"
        S1 = 4*D*(D+1)
    elseif METHOD == "THD"
        S1 = 2*(D-1)
    elseif METHOD == "XOR"
        S1 = D
    elseif METHOD == "POS"
        S1 = 2D
    else
        error("Unknown operation!!!!")

    end

    return NDV*S1/LN

end
