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
function PosSubst(x::UInt32, y::UInt32)::UInt32
    x > y ? a = x-y : a = y - x
    return a
end