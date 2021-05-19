function Classify_Addresses_in_MCU(DATA::Matrix{UInt32}, 
    Indexes::Matrix{Int}, 
    UsePseudoADD::Bool=false, 
    WordWidth::Int=8)::Vector{Any}

    ## The purpose of this function is to classify the addresses (or pseudoaddresses) with bitflips
    ## transform the matrix of INDEXES got from MCU_Indexes() into a Vector of matrices, called
    ## SOLUTION, which is eventually returned.
    ##  
    ## The length of SOLUTION is the size of the largest observed MCU(s), NLMCU. Thus, SOLUTION[1] is
    ## a N x NLMCU matrix in which every row contains the addresses or pseudoaddresses of the NLMCU
    ## bitflips involved in this MCU. N is the number of observdd NLMCU-bit MCUs.
    ## 
    ## SOLUTION[2] is devoted to events with M = NLMCU-1 bits. As before, it is a matrix with NLMCU-1 
    ## rows and an undetermined number of rows.
    ##
    ## Finally, SOLUTION[NLMCU] is just a simple vector with the addresses not involved in MCUs. Obviously,
    ## these are the SBUs.
    ## 

    ADDRESSES = ones(UInt32, length(DATA[:,1]), 2)    
    
    ### Typical procedure to treat DATA and extract the addresses. The second column is not necessary.

    if UsePseudoADD

        ADDRESSES = ConvertToPseudoADD(DATA, WordWidth, true)
        # The size of the matrix is changed if there are MBUs.

    else

        ADDRESSES[:,1] = DATA[:,1]

        if length(DATA[1,:]) == 4
        
            ADDRESSES[:,2] = DATA[:,4]
    
        end

    end
    
    ## NMCUs: Number of MCUS.
    ## LargestMCUsize: Size of the Largest MCU. Called NLMCU above but changed for clarity.

    NMCUs, LargestMCUsize = size(Indexes)

    ### Initially, the solution is a void matrix.
    Solution = []

    Rows_to_treat = collect(Int, 1:NMCUs)
    ### Elements in this vector will be removed after every step in the next loop.

    for MCUSize = LargestMCUsize:-1:2

        MCURows = [n for n in findall(Indexes[:, MCUSize].!=0) if n in Rows_to_treat]

        setdiff!(Rows_to_treat, MCURows)
        ### This instruction removes from the rows to treat those already collected.

        push!(Solution, ADDRESSES[Indexes[MCURows, 1:MCUSize]])
        # The matrix is added to Solution as an element.

    end

    SBU_indexes = setdiff(collect(Int, 1:length(ADDRESSES[:, 1])), union(Indexes))
    ## ADDRESSES the indexes of which are not present in Indexes are SBUs.

    push!(Solution, ADDRESSES[SBU_indexes])
    ### Added as the last element.

    return Solution

end

