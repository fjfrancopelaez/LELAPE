# Distributed under the 
#
#          European Union Public Licence v. 1.2
# 
# See 
#
#          https://github.com/fjfrancopelaez/LELAPE/blob/main/LICENSE.md 
# 
# for further details.
function AddressesInExcess(Histogram::Vector{Int}, Threshold::Int)::Vector{UInt32}
    # This is a simple function that looks for all of the elements in a vector called Histogram
    # and select those valuues above Threshold. As this Histogram is related to addresses and 
    # given that the vector index starts at 1 but is related to 0x0000 address, the returned
    # vector is the index minus one.

    DetectedValues = findall(Histogram.>Threshold)

    return convert.(UInt32, DetectedValues.-1)

end
