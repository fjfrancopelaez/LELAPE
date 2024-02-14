using DelimitedFiles;

GOLDEN_FILE = "GOLDEN.raw"; # Change it and point to the file you wish.
RADIAT_FILE = "B01.raw"; # File after irradiation. Supposed to be identical to GOLDEN_FILE except at a small number of cells.

WordWidth = 32; # WordWidth. Typically 32 in many Xilinx FPGA. 
                # Admitted values: 8, 16, 32, 64, 128


if !(isfile(GOLDEN_FILE))
    println("ERROR. Golden File ($(GOLDEN_FILE)) not found. Exiting...")
elseif !(isfile(RADIAT_FILE))
    println("ERROR. Post irradiation Content File ($(RADIAT_FILE)) not found. Exiting...")    
elseif (filesize(GOLDEN_FILE)!=filesize(RADIAT_FILE))
    println("ERROR. Mismatch between file sizes.")
elseif (mod(filesize(GOLDEN_FILE), WordWidth)!=0)
    println("ERROR: file size in bits ($(8*filesize(GOLDEN_FILE))) is not a multiple of $(WordWidth). Exiting...")
else
    NumberOfBits = filesize(GOLDEN_FILE)*8;
    NumberOfWords = div(NumberOfBits, WordWidth);

    FlippedWords = []
    if (WordWidth == 8)
        RADIAT_ARRAY = zeros(UInt8, NumberOfWords);
        GOLDEN_ARRAY = zeros(UInt8, NumberOfWords);
        read!(RADIAT_FILE, RADIAT_ARRAY);
        read!(GOLDEN_FILE, GOLDEN_ARRAY);
    elseif(WordWidth == 16)
        RADIAT_ARRAY = zeros(UInt16, NumberOfWords);
        GOLDEN_ARRAY = zeros(UInt16, NumberOfWords);
        read!(RADIAT_FILE, RADIAT_ARRAY);
        read!(GOLDEN_FILE, GOLDEN_ARRAY);
    elseif(WordWidth == 32)
        RADIAT_ARRAY = zeros(UInt32, NumberOfWords);
        GOLDEN_ARRAY = zeros(UInt32, NumberOfWords);
        read!(RADIAT_FILE, RADIAT_ARRAY);
        read!(GOLDEN_FILE, GOLDEN_ARRAY);
    elseif(WordWidth == 64)
        RADIAT_ARRAY = zeros(UInt64, NumberOfWords);
        GOLDEN_ARRAY = zeros(UInt64, NumberOfWords);
        read!(RADIAT_FILE, RADIAT_ARRAY);
        read!(GOLDEN_FILE, GOLDEN_ARRAY);
        println("WARNING: Currently, LELAPE works with wordwidths up to 32 bits.");
    elseif(WordWidth == 128)
        RADIAT_ARRAY = zeros(UInt128, NumberOfWords);
        GOLDEN_ARRAY = zeros(UInt128, NumberOfWords);
        read!(RADIAT_FILE, RADIAT_ARRAY);
        read!(GOLDEN_FILE, GOLDEN_ARRAY);
        println("WARNING: Currently, LELAPE works with wordwidths up to 32 bits.");
    else
        error("Word width different from 8, 16, 32, 64 or 128. Exiting.")
    end
    for k = 0:NumberOfWords-1
        if (GOLDEN_ARRAY[k+1]!=RADIAT_ARRAY[k+1])
            push!(FlippedWords, k, RADIAT_ARRAY[k+1], GOLDEN_ARRAY[k+1])
        end
    end

    FlippedWords = transpose(reshape(FlippedWords, 3, :))

    OUTPUT_FILE = RADIAT_FILE[1:end-4]*"_output.csv"

    open(OUTPUT_FILE, "w") do io
        println(io, "Address,Content,Pattern") # No information of cycle included.
        writedlm(io, FlippedWords,',') # Data are saved in Int format. It does not matter at the time of reading.
    end
    println("Done. Data saved in $(OUTPUT_FILE). Goodbye!!")

end

