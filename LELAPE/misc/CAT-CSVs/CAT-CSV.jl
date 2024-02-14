using DelimitedFiles;

FOLDER = "InputFiles"   # These are just the same files as in Example2
                        # You can use either absolute or relative paths.

OUTPUT_NAME = "Global_File"

if (uppercase(OUTPUT_NAME[end-3:end])!=".CSV")
    OUTPUT_NAME = OUTPUT_NAME*".csv" # I like to work with proper extensions!!
end

LIST_OF_FILES = readdir(FOLDER)

open(OUTPUT_NAME, "w") do io
    println(io, "Address, Content,Pattern,Round")
end

cycle = 1;

for element in LIST_OF_FILES

    if ((length(element)>=5) && uppercase(element[end-3:end])==".CSV") # This instruction is used to skip file not ending in .csv

        TemporalMatrix = readdlm(FOLDER*"/"*element, ',',Int,skipstart=1);
        Nrows, Ncols = size(TemporalMatrix);

        print("Treating $(element)... ");

        open(OUTPUT_NAME, "a") do io
            writedlm(io, [TemporalMatrix[:, 1:3] cycle*ones(Int, Nrows,1)], ',');
        end
        global cycle += 1;
        println("Done.");
    end

end

if cycle == 1 
    println("Ummm. Apparently, no valid CSV files. The output file is empty.");
else
    println("Saved $(cycle -1) rounds in $(OUTPUT_NAME). Bye!!!");

end
