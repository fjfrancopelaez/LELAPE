module LELAPE

    export  ConvertToPseudoADD, AddPatternColumn,
            ExtractFlippedBits, CheckMBUs,
            DetectAnomalies_SelfConsis, 
            DetectAnomalies_SelfConsis_MassStorage, 
            DetectAnomalies_Shuffle_Rule, 
            DetectAnomalies_Shuffle_Rule_MassStorage, 
            DetectAnomalies_Trace_Rule, 
            DetectAnomalies_Trace_Rule_MassStorage, 
            DetectAnomalies_MCU_Rule, 
            DetectAnomalies_MCU_Rule_MassStorage, 
            DetectAnomalies_FullCheck,  
            DetectAnomalies_FullCheck_MassStorage,  
            MCU_Indexes, Classify_Addresses_in_MCU, 
            TheoAbundausince_XOR, TheoAbundance_POS, TheoAbundance, MaxExpectedRepetitions,
            CorrectNBitFlips, NF2BitMCUs, NF3BitMCUs, NPairs, NTriplets

    ### Functions issued from the Only SBUs model.
    include("functions/OnlySBUsModel/TheoAbundance_POS.jl")
    include("functions/OnlySBUsModel/TheoAbundance_XOR.jl")
    include("functions/OnlySBUsModel/TheoAbundance.jl")
    include("functions/OnlySBUsModel/MaxExpectedRepetitions.jl")
    
    ##############################################
    ### Functions used to look for anomalies. Some of them do not go out of the module.

    include("functions/DataTreatCheck/PosSubst.jl")
    include("functions/DataTreatCheck/AddPatternColumn.jl")
    include("functions/DataTreatCheck/ExtractFlippedBits.jl")
    include("functions/DataTreatCheck/CheckMBUs.jl")
    include("functions/DataTreatCheck/DataMatrixIntegrity.jl")
    include("functions/DataTreatCheck/ConvertToPseudoADD.jl")
    include("functions/DataTreatCheck/NPairs.jl")
    include("functions/DataTreatCheck/NTriplets.jl")
    include("functions/DataTreatCheck/Create_DV_Set.jl")
    include("functions/DataTreatCheck/CreateHistogram.jl")
    include("functions/DataTreatCheck/CreateHistogram_MassStorage.jl")
    include("functions/DataTreatCheck/AddressesInExcess.jl")
    include("functions/DataTreatCheck/AddressesInExcess_MassStorage.jl")
    include("functions/DataTreatCheck/XOR_MCU_Indexes.jl")
    include("functions/DataTreatCheck/POS_MCU_Indexes.jl")
    include("functions/DataTreatCheck/MCU_Indexes.jl")
    include("functions/DataTreatCheck/Classify_Addresses_in_MCU.jl")
    include("functions/DataTreatCheck/SelfConsistency.jl")
    include("functions/DataTreatCheck/XOR_values.jl")
    include("functions/DataTreatCheck/DetectAnomalies_SelfConsis.jl")
    include("functions/DataTreatCheck/DetectAnomalies_SelfConsis_MassStorage.jl")
    include("functions/DataTreatCheck/DetectAnomalies_Shuffle_Rule.jl")
    include("functions/DataTreatCheck/DetectAnomalies_Shuffle_Rule_MassStorage.jl")
    include("functions/DataTreatCheck/DetectAnomalies_Trace_Rule.jl")
    include("functions/DataTreatCheck/DetectAnomalies_Trace_Rule_MassStorage.jl")
    include("functions/DataTreatCheck/DetectAnomalies_MCU_Rule.jl")
    include("functions/DataTreatCheck/DetectAnomalies_MCU_Rule_MassStorage.jl")
    include("functions/DataTreatCheck/DetectAnomalies_FullCheck.jl")
    include("functions/DataTreatCheck/DetectAnomalies_FullCheck_MassStorage.jl")

    ##############################################
    ### Functions derived from the only SBU model related to false multiple events and other issues.
    include("functions/OnlySBUsModel/CorrectNBitFlips.jl")
    include("functions/OnlySBUsModel/NF2BitMCUs.jl")
    include("functions/OnlySBUsModel/NF3BitMCUs.jl")

end
