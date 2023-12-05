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
function TheoAbundance_POS(NR::Int, NB::Int, LN::Int, UsingDV::Bool = false)::AbstractFloat
#This function allows calculating the expected number of values repeated
# NR times after NB bitflip in a memory with LA words with W bits per word
# supposing to have used the POSITIVE subtraction..
#
# NR must be an integer number higher or equeal than 0
# NB is an integer number supposed to be higher than 1.
# LN is an integer number, and indicates the size of the elements in the set
# where elements are chosen.
#
# Sometimes, the user provides directly the DV set so an additional boolean
# input is provided to take into account this fact. It is usually disabled. In this
# case, NB PLAYS THE ROLE OF NDV.
#
# Eauqtions were got from Eq.2 of the Appendix in
#
# J. C. Fabero et al., "Single Event Upsets Under 14-MeV Neutrons in a 28-nm
#SRAM-Based FPGA in Static Mode," in IEEE Transactions on Nuclear Science, vol.
# 67, no. 7, pp. 1461-1469, July 2020,
#doi: 10.1109/TNS.2020.2977874.
#
#
# Lawfully avalaible for free on https://eprints.ucm.es/id/eprint/59496/

# First step; Values has mathematical sense:

    if NR < 0
        error("It is nonsense to suppose that the number of repetitions, $NR, can be negatiive!")
    elseif NB < 0
        error("You're saying that there has been $NB bitflips!")
    end


# The size of the DV set. Take into account that this number may have been provided.

    !UsingDV ? NDV = div(NB*(NB-1), 2) : NDV = NB

#The following IF is Self explaining.
    if NR > NDV
        error("It is impossible to find $NR repetitions in set with $NB bitflips.")
    end

# The calculations involves using a complex summatory with a lot of calculations.
# Instado of doing so, we will calculate the first element of the summatory and
# and the rest iteratively.

    INC = (binomial(BigInt(NDV), NR)*(2/LN)^NR)*LN/(NR+1)

    SUM = INC

    for k = 1:NDV-NR

        INC *= -(NR+k)/(NR+k+1)*(NDV-NR-k+1)*2/k/LN

        SUM += INC

    end

    return SUM

end
