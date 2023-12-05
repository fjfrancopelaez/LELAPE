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
function MaxExpectedRepetitions(NDV::Int, LN::Int, Operation::String, ϵ::AbstractFloat=0.01)::Int
    # The purpose of this funcion is to determina the maximum number of expected
    # repetitions. in a DV set taken from a memory with size equal to LN.
    # In general, it is the first integer such that its theoretical abundance is
    # lower than ϵ.
    #
    if Operation == "XOR"

        TestValue = 0
        Expectation = TheoAbundance_XOR(TestValue, NDV, LN, true)

        while (Expectation > ϵ)

            Expectation = TheoAbundance_XOR(TestValue, NDV, LN, true)
            TestValue += 1

        end

    elseif Operation == "POS"

         TestValue = 0

         Expectation = TheoAbundance_POS(TestValue, NDV, LN, true)

         while (Expectation > ϵ)

             Expectation = TheoAbundance_POS(TestValue, NDV, LN, true)
             TestValue += 1

         end

    else

        error("Uknown operation. Use POS or XOR.")

    end

    return TestValue

end
