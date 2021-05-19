function TheoAbundance(NR::Int, NB::Int, LN::Int, Operation::String, UsingDV::Bool = false)
    #This is an Alias for TheoAbundance_POS() or TheoAbundance_XOR().
    #
    # NR must be an integer number higher or equeal than 0
    # NB is an integer number supposed to be higher than 1.
    # LN is an integer number, and indicates the size of the elements in the set
    # where elements are chosen.
    # Operation is "XOR" or "POS"
    #
    if Operation == "POS"
        return  TheoAbundance_POS(NR, NB, LN, UsingDV)
    elseif Operation == "XOR"
        return  TheoAbundance_POS(NR, NB, LN, UsingDV)
    else
        error("You are trying an unknown operation. Use POS or XOR.")
    end

end