# Distributed under the 
#
#          European Union Public Licence v. 1.2
# 
# See 
#
#          https://github.com/fjfrancopelaez/LELAPE/blob/main/LICENSE.md 
# 
# for further details.
function AddPatternColumn(DATA::Matrix{UInt32}, PATTERN::UInt32)::Matrix{UInt32}

    # Sometimes, DATA are just a matrix with only two columns: Word Address + Content,
    # assuming that the PATTERN is constant. This function just expands the matrix
    # to include a column in the third position with the used PATTERN. 
    #
    # Sometimes, in pseudostatic tests, there is a third column with cycle information.
    # In this case, the third column is shifted to the fourth position, and the void
    # third column is filled with the PATTERN. 

    nrows, ncolumns = size(DATA)

    NewDATA = ones(UInt32, nrows, ncolumns+1)

    if ncolumns == 2  

        NewDATA[:, 1:2] = DATA;
        
        NewDATA[:, 3] = PATTERN*NewDATA[:,3]

        return NewDATA

    elseif ncolumns == 3

        NewDATA[:, 1:2] = DATA[:, 1:2];
        
        NewDATA[:, 3] = PATTERN*NewDATA[:,3]

        NewDATA[:, 4] = DATA[:,3]

        return NewDATA

    else

        error("Input matrix must have 2 or 3 columns!!!!")

    end

end

# function AddPatternColumn(DATA::Matrix{UInt32}, PATTERN::UInt8)::Matrix{UInt32}

#     return AddPatternColumn(DATA, convert(UInt32, PATTERN))


# end

# function AddPatternColumn(DATA::Matrix{UInt32}, PATTERN::UInt16)::Matrix{UInt32}

#     return AddPatternColumn(DATA, convert(UInt32, PATTERN))

# end

function AddPatternColumn(DATA::Matrix{UInt32}, PATTERN::Integer)::Matrix{UInt32}

    return AddPatternColumn(DATA, convert(UInt32, PATTERN))

end

###################################################################
#######                                                     #######
#######      VERSION OF THE PREVIOUS FUNCTION FOR 64-bits   #######
#######                                                     #######
###################################################################


function AddPatternColumn(DATA::Matrix{UInt64}, PATTERN::UInt64)::Matrix{UInt64}

    # Sometimes, DATA are just a matrix with only two columns: Word Address + Content,
    # assuming that the PATTERN is constant. This function just expands the matrix
    # to include a column in the third position with the used PATTERN. 
    #
    # Sometimes, in pseudostatic tests, there is a third column with cycle information.
    # In this case, the third column is shifted to the fourth position, and the void
    # third column is filled with the PATTERN. 

    nrows, ncolumns = size(DATA)

    NewDATA = ones(UInt64, nrows, ncolumns+1)

    if ncolumns == 2  

        NewDATA[:, 1:2] = DATA;
        
        NewDATA[:, 3] = PATTERN*NewDATA[:,3]

        return NewDATA

    elseif ncolumns == 3

        NewDATA[:, 1:2] = DATA[:, 1:2];
        
        NewDATA[:, 3] = PATTERN*NewDATA[:,3]

        NewDATA[:, 4] = DATA[:,3]

        return NewDATA

    else

        error("Input matrix must have 2 or 3 columns!!!!")

    end

end

function AddPatternColumn(DATA::Matrix{UInt64}, PATTERN::Integer)::Matrix{UInt64}
    return AddPatternColumn(DATA, convert(UInt64, PATTERN))
end
