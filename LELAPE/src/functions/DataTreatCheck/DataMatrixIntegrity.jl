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
function DataMatrixIntegrity(DATA::Array{Integer,2}, LN::Int, WordWidth::Int)::Bool
    # This function verifies that the DATA matrix is:
    #   a) Contains only 3 columns
    #   b) No element in the first colum is higher than LN.
    #   c) No element in the second and third columns ara higher than 2^WordWidth - 1
    #   d) all the elements in the second and third column are different from
    #       each other.

    if (LN<=0)
        error("The value of the Memory size ($LN) is not allowed.")
    elseif (WordWidth<=0)
        error("WordWidth value ($WordWidth) is nonsense.")
    else

        NWords, Ncolumns = size(DATA)

        if Ncolumns != 3
            error("You have used a DATA matrix with a number of columns ($Ncolumns) not allowed!")
        elseif length(findall(DATA[:,1].>=LN))!=0
            error("One or more addresses values (first column) are above the memory size.")
        elseif length(findall(DATA[:, 2].==DATA[:,3]))!=0
            error("Somewhere in the DATA matrix, the read value is identical to the expected pattern.")
        elseif length(findall(DATA[:,2].>=2^WordWidth))!=0
            error("Values in the second column of the DATA matrix above the largest possible value calculated from the wordwidth.")
        elseif length(findall(DATA[:,3].>=2^WordWidth))!=0
            error("Values in the third column of the DATA above the largest possible value calculated from the wordwidth.")
        else
            return true
        end

    end

end
