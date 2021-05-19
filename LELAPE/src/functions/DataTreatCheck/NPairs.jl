function NPairs(DATA::Array{UInt32}, UsePseudoAdd::Bool=true, WordWidth::Int=1, KeepCycle::Bool=false)::Int

    if UsePseudoAdd

        ADDRESSES = ConvertToPseudoADD(DATA, WordWidth, KeepCycle)

    else 

        NAddresses, Ncol = size(DATA)

        ADDRESSES = ones(UInt32, NAddresses, 2)

        ADDRESSES[:, 1] = DATA[:, 1]

        if Ncol == 4 & KeepCycle

            ADDRESSES[:,2] = DATA[:, 4]

        end

    end

    Cycle_Labels = union(ADDRESSES[:, 2])

    NPairs = 0;

    for Cycle in Cycle_Labels

        NBF = length(findall(ADDRESSES[:, 2].== Cycle))

        NPairs += div(NBF*(NBF-1), 2)

    end

    return NPairs

end

function NPairs(NBF::Int)::Int

    return div(NBF*(NBF-1), 2)

end

            