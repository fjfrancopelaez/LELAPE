function AddressesInExcess_MassStorage(Histogram::Array{Int, 2}, Threshold::Int)::Array{UInt32, 2}
    # This is a simple function that looks for all of the elements in a MATRRX called Histogram
    # and selects those values above Threshold. 

#################################################################################
#   IMPORTANT NOTE ON 2023/01/25
#    This is the old version of the function. It has been deprecated since it is possible
#    that could not manage very large memories as massive storage devices. Differences are in treatmente
#   of data and output format
#################################################################################

    # DetectedValues = findall(Histogram.>Threshold)
    DetectedValues = Histogram[findall(Histogram[:,2].>Threshold), 1:2]

    return convert.(UInt32, DetectedValues)

end
