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
# function CreateDVSetHistogram(SET::Array{UInt32, 1}, LN::Int)::Array{Int, 1}
###
#################################################################################
#   IMPORTANT NOTE ON 2023/01/25
#    This is the old version of the function. It has been deprecated since it is possible
#    that could not manage very large memories as massive storage devices. Differences are in treatmente
#   of data and output format
#################################################################################
###
#     # It checks the number of elements present in the DV Histogram and returns the
#     # number of times that every possible element appear.
#     #
#     # LN is the memory size.
#     #
#     # Only are possible elements from 0 to LN-1. Besides, the value at positon X
#     # is associated with the the value unsigned 32-bit X-1. Thus, the first element
#     # is related to 0x00000.
#     #

#     if maximum(SET) > (LN-1)
#         error("Something wrong... an element of the DV set is larger than the memory size.")
#     else

#         Histogram = zeros(Int, LN)

#         for element ∈ SET

#             Histogram[element + 1] += 1
#             # Address 0x000 --> Index 1. Clear?

#         end

#         return Histogram

#     end

# end

#################################################################################
## NEW VERSION OF THE function
#################################################################################
function CreateDVSetHistogram_MassStorage(SET::Array{Integer, 1}, LN::Int)::Array{Int, 2}
####     
# It checks the number of elements present in the DV Histogram and returns the
#     # number of times that every possible element appear. The first column saves the number, the second the number of occurrences.
#     #
#     # LN is the memory size.
#     #
#     # Only are possible elements from 0 to LN-1. Besides, the value at positon X
#     # is associated with the the value unsigned N-bit X-1. Thus, the first element
#     # is related to 0x00000.
#     #
    if maximum(SET) > (LN-1)
        error("Something wrong... an element of the DV set is larger than the memory size.")
    else



        Histogram = zeros(Int, length(union(SET)), 2);
        Histogram[:, 1] = sort(union(SET));



        for k=1:length(Histogram[:, 1])

            Histogram[k,2] = length(findall(SET.==Histogram[k,1]))

        end

        return Histogram

    end

end