function CorrectNBitFlips(NBF::Int, LN::Int)::Float64

    # Tries to correct the number of bitflips to compensate cells hit twice that
    # escape from inspection. 
    #
    # NBF: Number of bitflips. Theoretically, SBUs but they are impossible to be distinguished 
    #       from other kinds of bitflips. Therefore, a simple approach is taken.
    # LN: Memory size in BITS!!!!!
    #
    # Expression is taken from Eq. 6 in F. J. Franco, J. A. Clemente, H. Mecha and R. Velazco, 
    # "Influence of Randomness During the Interpretation of Results From Single-Event Experiments 
    # on SRAMs," IEEE Transactions on Device and Materials Reliability, vol. 19, no. 1, pp. 104-111, 
    # March 2019, doi: 10.1109/TDMR.2018.2886358.
    #
    return NBF + NBF^2/LN

end
