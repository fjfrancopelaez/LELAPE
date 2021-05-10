module Lelape

    #using OnlySBUsModel

    export  DetectAnomalies_SelfConsis, DetectAnomalies_Shuffle_Rule, DetectAnomalies_Trace_Rule, 
            DetectAnomalies_MCU_Rule, DetectAnomalies_FullCheck, ExtractFlippedBits, CheckMBUs,
            TheoAbundausince_XOR, TheoAbundance_POS, TheoAbundance, MaxExpectedRepetitions


    include("OnlySBUsModel/TheoAbundance_POS.jl")
    include("OnlySBUsModel/TheoAbundance_XOR.jl")
    include("OnlySBUsModel/TheoAbundance.jl")
    include("OnlySBUsModel/MaxExpectedRepetitions.jl")
    
    ##############################################

    include("DataTreatCheck/PosSubst.jl")
    include("DataTreatCheck/ExtractFlippedBits.jl")
    include("DataTreatCheck/CheckMBUs.jl")
    include("DataTreatCheck/DataMatrixIntegrity.jl")
    include("DataTreatCheck/ConvertToPseudoADD.jl")
    include("DataTreatCheck/Create_DV_Set.jl")
    include("DataTreatCheck/CreateHistogram.jl")
    include("DataTreatCheck/AddressesInExcess.jl")
    include("DataTreatCheck/XOR_MCU_Indexes.jl")
    include("DataTreatCheck/POS_MCU_Indexes.jl")
    include("DataTreatCheck/SelfConsistency.jl")
    include("DataTreatCheck/XOR_values.jl")
    include("DataTreatCheck/DetectAnomalies_SelfConsis.jl")
    include("DataTreatCheck/DetectAnomalies_Shuffle_Rule.jl")
    include("DataTreatCheck/DetectAnomalies_Trace_Rule.jl")
    include("DataTreatCheck/DetectAnomalies_MCU_Rule.jl")
    include("DataTreatCheck/DetectAnomalies_FullCheck.jl")

end
