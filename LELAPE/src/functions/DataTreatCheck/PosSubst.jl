function PosSubst(x::UInt32, y::UInt32)::UInt32
    x > y ? a = x-y : a = y - x
    return a
end