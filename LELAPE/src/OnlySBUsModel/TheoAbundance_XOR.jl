function TheoAbundance_XOR(NR::Int, NB::Int, LN::Int, UsingDV::Bool = false)::AbstractFloat
#This function allows calculating the expected number of values repeated
# NR times after NB bitflip in a memory with LA words with W bits per word.
# with XOR operation.
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
# Eauqtions were got from Eq.12 of the Appendix.C in
#
# F. J. Franco et al., "Statistical Deviations From the Theoretical Only-SBU
# Model to Estimate MCU Rates in SRAMs," in IEEE Transactions on Nuclear
# Science, vol. 64, no. 8, pp. 2152-2160, Aug. 2017,
# doi: 10.1109/TNS.2017.2726938.
#
#
# Lawfully avalaible for free on https://eprints.ucm.es/id/eprint/43874/

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

# Now, we will calculate the number of elements expected to appear 0 times in the DV
# set. This is just binomial(NDV,0)*(LN-1)^NDV / LN^(NDV-1).
# This value will be used to calculate the final value iteratively trying to avoid
# the straigthforware definiction:
#
# NR =  binomial(NDV, m)*(LN-1)^(NDV-m)/LN^(NDV-1)
#
# which may require to cast input values to BigInt, making the problem less efficient.
# Therefore, we will use the following propoerty:
#
# NR(m,NDV) = NR(m-1, NDV)*(NDV-m+1)/LN/m
#
    NRXOR = LN*(1-1.0/LN)^NDV

    if NR == 0
        return NRXOR
    else
        for m = 1-1:NR-1
             NRXOR *= (NDV-m)/(LN-1)/(m+1)
        end

        return NRXOR
    end

end
