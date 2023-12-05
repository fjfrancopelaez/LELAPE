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
function NF3BitMCUs(NSBU::Int, NMU2::Int, LN::Int, METHOD::String, D::Int, WordWidth::Int=1)::Tuple{Float64, Float64}
    # indicates the expected number of false 3-bit MCUs that will occur 
    # in a memory with LN bits in which NSBU SBUs and NMU2 2-bit MCUs have occurred. 
    # In this analysis, MCUS are sought using some grouping --method (METHOD) with a generalized 
    # distance D.HD
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
    #   In this paper, it was demonstrated that it is mathematically impossible to get an exact value. Therefore, 
    #   optimistic and pessimistic results are provided.
    #
    #   First, the memory size if corrected in case WORD ADDRESS is used in XOR or POS.  
    METHOD in ["XOR", "POS"] ? L = div(LN,WordWidth) : L = LN

    # Now, the size of the SBU influence area and the 2-bit ones.
    if METHOD == "MBU" 
        S1 = (D-1)
        S2S = S1
        S2L = S1
    elseif METHOD == "MHD"
        S1 = 2*D*(D+1)
        S2S = 2D^2 + 4D
        S2L = 2D^2 + 5D -1 + 2*(D-1)*div(D,2) + 2*div(D+1,2)*(div(D+1,2)-1)
    elseif METHOD == "IND"
        S1 = 4*D*(D+1)
        S2S = 4D^2 + 6D
        S2L = 7D^2 + 6D - 1
    elseif METHOD == "THD"
        S1 = 2*(D-1)
        S2S = 2D-2
        S2L = 3D-4
    elseif METHOD == "XOR"
        S1 = D
        S2S = D-1
        S2L = 2D-2
    elseif METHOD == "POS"
        S1 = 2D
        S2S = 2D - 1
        S2L = 4D - 2
    else
        error("Unknown operation!!!!")

    end

    # Number of false 3-bit MCUs related to 3 independent SBUs.
    # Eq. 12 in the reference paper.

    NT = NTriplets(NSBU)

    NFM3A_OPT = NT*S1*(S1-1)/L^2
    NFM3A_PES = 3*NFM3A_OPT

    # Number of false 3-bit MCUs related to 2-bit MCU + 1 SBU.
    # First, the influence areas of 2-bit MCUs.

    NFM3B_OPT = NSBU*NMU2*S2S/L
    NFM3B_PES = NSBU*NMU2*S2L/L

    return NFM3A_OPT+NFM3B_OPT, NFM3A_PES+NFM3B_PES

end