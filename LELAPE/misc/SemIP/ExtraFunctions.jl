using Dates

function NumberOfLines(sx::String)::Int

    line = 0::Int;

    a = " "::String;

    open(sx, "r") do io

        while ! eof(io) 

            a = readline(io);

            line+=1;        
        end

    end

    return line;

end

#############################

function ExtractCycleLabel(s::String, ON_OFF_OFFSET::Int)

    SIGNATURE = "TS"

    IsCorrect = true::Bool;

    Cycle = 0::Int;

    if s[1:2]==SIGNATURE

        Cycle = parse(Int, s[4:end], base=16)+ON_OFF_OFFSET;

        return Cycle, true;
    else

        return -1, false;

    end

end

#############################

function ExtractPFA(s::String)

    SIGNATURE = "PA"

    if s[1:2]==SIGNATURE

        return parse(Int, s[4:end], base=16), true;
    else
        return -1, false;
    end
end

#############################

function ExtractLFA(s::String)

    SIGNATURE = "LA"

    if s[1:2]==SIGNATURE

        return parse(Int, s[4:end], base=16), true;
    else
        return -1, false;
    end
end

#############################

function ExtractWordAddress_BitPosition(s::String)

    SIGNATURE1 ="WD";
    SIGNATURE2 ="BT";
    Integrity = false::Bool;

    WordAddress_in_frame = -1;
    Flipped_bit = -1;

    if ((s[1:2]==SIGNATURE1)&&(s[7:8]==SIGNATURE2))
        WordAddress_in_frame = parse(Int, s[4:5], base=16);
        Flipped_bit = parse(Int, s[10:11], base = 16);
        Integrity = true;
    end        

    return WordAddress_in_frame, Flipped_bit, Integrity

end

##############################

function CreateTreatmentFiles(s1::String, s2::String)

    open(s1, "w") do io
        println(io, "Creating "*s1*" file on $(now())...\n");
    end

    open(s2, "w") do io
        println(io, "Creating "*s2*" file on $(now())...\n");
    end
    
end

################################
function PrintlnScreenFile(FILE::String, s::String)

    println(s)
    open(FILE, "a") do io
        println(io, s)
    end
end

function PrintScreenFile(FILE::String, s::String)

    print(s)
    open(FILE, "a") do io
        print(io, s)
    end
end