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
using Dates;

include("ExtraFunctions.jl");

SOURCE_FILE=ARGS[1]; # the firs argument after "julia SemIP-DataExtraction FILE.log"
# The original file did not work since it was not codified as UTF-8. Just opened, saved and closed with VS Code.
# Another way to provide the file is to use include if you do not wish to work with terminal.
# SOURCE_FILE="PATH_TO_FILE" # Uncomment and comment line 5.

OUTPUT_FILE=SOURCE_FILE[1:end-4]*"_output.txt";
LOG_FILE=SOURCE_FILE[1:end-4]*"_log.txt";

CreateTreatmentFiles(OUTPUT_FILE, LOG_FILE);

ON_OFF_OFFSET = 0;

Cycle = Int(0);

PFA = 0; # short for Physical_Frame_Address

LFA = 0; # short for Logical_Frame_Address

WordAddress_in_frame = 0;

FlippedBit = Int(0);

TotalLines = NumberOfLines(SOURCE_FILE);

NBitFlips = 0;
NResets = 0;

#######
### STATE MACHINE.
### First of all, possible states are defined.

const s_START = 0;
const s_RI = 1;
const s_SC = 2;
const s_ECC = 3;
const s_TS = 4;
const s_PA = 5;
const s_LA = 6;
const s_COR = 7;
const s_WDBT = 8;

STATE = s_START;

DetectedWDafterCOR = false; # a technical flag to avoid false warnings in s_WDBT if 2 or more bitflips occur.

# Printing the heading.
open(OUTPUT_FILE, "a") do io_output
    println(io_output, "LineInFile,PhysicalAddress, LogicalAddress, WordAddress, FlippedBit, Round");
end


open(SOURCE_FILE, "r") do io_source

    line = 0;

    # The first event is not preceded by 0> and must be treated in a different way.

    for k = 1:4
        s = readline(io_source);
        line+=1;
    end

    line+=1; #println(line)# it should be 5.
    Cycle, CycleIntegrity = ExtractCycleLabel(readline(io_source), ON_OFF_OFFSET);

    line+=1; #println(line)# it should be 6.
    PFA, PFA_Integrity = ExtractPFA(readline(io_source));

    line+=1; #println(line)# it should be 7.
    LFA, LFA_Integrity = ExtractLFA(readline(io_source));

    line+=1; #println(line)# it should be 8.
    s = readline(io_source); # This line should be CORR.

    line+=1; #println(line)# it should be 9.
    WordAddress_in_frame, FlippedBit, Integrity = ExtractWordAddress_BitPosition(readline(io_source));

    open(OUTPUT_FILE, "a") do io_output
        println(io_output, "$(line),$(PFA),$(LFA),$(WordAddress_in_frame),$(FlippedBit),$(Cycle)")
    end

    STATE = s_START;

    while line < TotalLines

        line+=1; #println(line);
      
            s = readline(io_source); 

        if length(s)<3 
            global STATE = s_START;
            open(LOG_FILE, "a") do io_log
                println(io_log, "Line $(line): Content in line too short. Skipping...")
            end            

        elseif occursin("ULT", s) 

            global ON_OFF_OFFSET += 10000; # There has been a SEFI!!!!! To avoid repeated labels, we shift the label for cycles a huge value.
            global NResets +=1
            open(LOG_FILE, "a") do io_log
                println(io_log, "Line $(line): SYSTEM RESTARTS. Skipping...")
            end
            global STATE = s_START;

        else

            if (STATE == s_START)

                if s[1:3] == "O> "
                    global STATE = s_RI;
                else
                    global STATE = s_START;
                end
                             
            elseif (STATE == s_RI)

                if s[1:3] == "RI "
                    global STATE = s_SC;
                else
                    global STATE = s_START
                    open(LOG_FILE, "a") do io_log
                        println(io_log, "Line $(line): expected RI XX after O>. Skipping...")
                    end
                end
            elseif (STATE == s_SC)
                if s[1:3] == "SC "
                    global STATE = s_ECC
                else
                    global STATE = s_START
                    open(LOG_FILE, "a") do io_log
                        println(io_log, "Line $(line): expected SC XX after RI XX. Skipping...")
                    end
                end
            elseif (STATE == s_ECC)
                if s == "ECC"
                    global STATE = s_TS;
                else
                    global STATE = s_START;
                    open(LOG_FILE, "a") do io_log
                        println(io_log, "Line $(line): expected ECC after SC XX. Skipping...")
                    end
                end
            elseif (STATE == s_TS)

                if s[1:2] == "TS"
                    Cycle, CycleIntegrity = ExtractCycleLabel(s, ON_OFF_OFFSET);
                    global STATE = s_PA;
                else
                    global STATE = s_START;
                    open(LOG_FILE, "a") do io_log
                        println(io_log, "Line $(line): expected TS XXXXXX after ECC. Skipping...")
                    end
                end
            elseif (STATE == s_PA)
                if s[1:2] == "PA"
                    PFA, PFA_Integrity = ExtractPFA(s);
                    global STATE = s_LA;
                else
                    global STATE = s_START;
                    open(LOG_FILE, "a") do io_log
                        println(io_log, "Line $(line): expected PA XXXXXX after Time Stamp (TS). Skipping...")
                    end
                end
            elseif (STATE == s_LA)
                if s[1:2] == "LA"
                    LFA, LFA_Integrity = ExtractLFA(s);
                    global STATE = s_COR;
                else
                    global STATE = s_START;
                    open(LOG_FILE, "a") do io_log
                        println(io_log, "Line $(line): expected LA XXXXXX after Physical Frame Address (LA). Skipping...")
                    end

                end
            elseif (STATE == s_COR)
                global DetectedWDafterCOR = false;
                if s == "COR"
                    global STATE = s_WDBT;
                else 
                    global STATE = s_START;
                    open(LOG_FILE, "a") do io_log
                        println(io_log, "Line $(line): expected COR after Logical Frame Address (LA). Skipping...")
                    end
                end
            elseif (STATE == s_WDBT)
                if s[1:2] == "WD"
                    global DetectedWDafterCOR = true;
                    WordAddress_in_frame, FlippedBit, Integrity = ExtractWordAddress_BitPosition(s);
                    open(OUTPUT_FILE, "a") do io_output
                        println(io_output, "$(line),$(PFA),$(LFA),$(WordAddress_in_frame),$(FlippedBit),$(Cycle)");
                    end    
                    global NBitFlips+=1;
                else
                    global STATE = s_START;
                    if !(DetectedWDafterCOR)
                        open(LOG_FILE, "a") do io_log
                            println(io_log, "Line $(line): expected WD XX BT XX after COR. Skipping...");
                        end
                    end
                    global DetectedWDafterCOR = false;
                end
            else
                global STATE = s_START;
            end
        
        end
    end

end

open(LOG_FILE, "a") do io_log
    println(io_log, "--------------------------------------------");
    println(io_log, "Number of bitflips: $(NBitFlips)");
    println(io_log, "Number of restarts: $(NResets)");
end