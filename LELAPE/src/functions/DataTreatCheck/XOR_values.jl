function XOR_values(X::Vector{UInt32})::Vector{UInt32}

    Summary = UInt32[]

    for k1 = 1:length(X)-1, k2 = k1+1:length(X)

        Value = xor(X[k1], X[k2])

        if !(Value in X)

            append!(Summary, Value)

        end

    end

    return Summary

end
