# Include necessary packages (DelimitedFiles and Printf)
try 
  using DelimitedFiles;

catch 
  using Pkg;
  Pkg.add(DelimitedFiles);
  using DelimitedFiles;
end

try 
  using Printf

catch 
  using Pkg;
  Pkg.add(Printf);
  using Printf;
end

# Run settings file 
include("Settings.conf")
if ((modf(log(LA*WordWidth)/log(2))[1]!=0)&&(Operation=="XOR"))
      error(" --> ERROR: The memory size must be a natural power of 2 with XOR operation. Exiting LELAPE...")
end

# Set variables pointing to scripts for global and local analysis
global_script="src/Global_Analysis.jl"
local_script="src/Local_Analysis.jl"

# ATTENTION GLOBAL VARIABLE. It points to the .CSV file that is processed each time
global FILE 

# ATTENTION GLOBAL VARIABLE. It stores the anomalies that were found in each test
global ANOMALIES

# ATTENTION GLOBAL VARIABLE. It points to the anomalies file
global ANOMALIES_FILE

# Update the path so source files in src are found
push!(LOAD_PATH, "./src") 
using LELAPE_pkg

# Prepare working directory 
cd(@__DIR__)
println(" The working directory is: ", pwd())

#####################################################################################
# Function to ask to the user for the path where test data are
# It returns a valid path to .csv file or directory where 1 or several .csv files are
#####################################################################################
function get_data_path()

    try
        while true
            println("\nTYPE PATH to .csv file or directory that contains the input .csv files (including initial anomalies, if any): ")
            println("(If .csv file does not exist, path to that file will be tried)")
            println()

            data_path = string(strip(readline()))
            
            #  Replace "\" with "/" 
            data_path = replace(data_path, '\\' => '/')
            
            # Remove ""
            data_path = strip(data_path, '"')
            data_path = strip(data_path, '\'')
            
            # Check if path provided by the user exists
            # If it is a directory, return it
            # If it is a file, check if it is a .csv file. If so, return it
            # If it is a file but not .csv, return its directory
            if isdir(data_path)
                println(" --> Directory found: $data_path")
                return data_path
            else
                if endswith(data_path, ".csv")
                    println(" --> .csv file found: $data_path")
                    return data_path
                else
                    println(" --> $data_path is not a .csv file, or the directory was incorrect!")
                    data_path = dirname(data_path)
                    println(" --> Trying path $data_path")
                    return data_path
                end
            end
        end
    catch e
        println("\n --> Interrupted by user. Exiting LELAPE...")
        exit(0)
    end

end

###################################################################################
# Function to ask to the user how many lines does the header of data files contain
###################################################################################
function get_header_lines()

    try
        while true
            print("\nHow many lines does the header of your data files contain? (type 0 if your .csv just contains data): ")
            header_lines = parse(Int, strip(readline()))        
            println()

            if isa(header_lines, Integer)
                return header_lines
            else
                println(" --> $header_lines is not an integer number. Please try again...")
            end
        end
    catch e
        println("\n --> Interrupted by user. Exiting LELAPE...")    
        exit(0) 
    end

end

#######################################################################################################################
# Function to analyze each file individually. 
# Studied anomalies are local, not considering the ones found in other tests, or initial ones provided in Anomalies.txt
# @data_path: Valid path to an input .csv file, or a directory where several .csv are
# @local_global: false if LOCAL, true if GLOBAL
# For each input XXX.csv file found, it generates a XXX.out file with the results
#######################################################################################################################
function analyze_data(data_path::AbstractString, local_global::Bool)

    # Set variable "files" to the list of input .csv files
    # Set variable "data_directory" to the directory where .csv file (or files) is/are
    if !isdir(data_path)
        files = Vector{String}(undef, 1)
        files[1] = data_path
        data_directory = dirname(data_path)
    else
        all_files = readdir(data_path)
        files = [joinpath(data_path, f) for f in all_files if endswith(f, ".csv")]
        data_directory = data_path
    end
    
    # This can only happen if data_path is a valid directory, but no .csv files were found there
    if isempty(files) 
        println(" --> Path correct, but no .csv files found in $data_path")
        println(" --> EXITING APPLICATION")
        exit(0)
    else 
        # Show this message only for LOCAL tests
        if local_global == false
            println(" --> $(length(files)) .csv files found in in $data_path")
        end
    end

    # Verify if the user provided an input anomalies file
    global ANOMALIES_FILE = joinpath(data_directory, "Anomalies.txt")
    global ANOMALIES_FILE = replace(ANOMALIES_FILE, "\\" => "/")

    # If previous anomalies file doesn't exist, create it. Do this only for LOCAL tests
    if local_global == false
        if isfile(ANOMALIES_FILE)
            println(" --> Existing anomalies file found: $ANOMALIES_FILE")
        else
            println(" --> No anomalies file found. Creating it under name: $ANOMALIES_FILE")
            touch(ANOMALIES_FILE)
        end
        println()
    end

    # Iterate on all files
    for (i, f) in enumerate(files)
        
        # Set global variable to the pathname of each input data file and reset anomalies file
        global FILE = f

        # If test is LOCAL
        if local_global == false
            # Reset anomalies variable each time
            global ANOMALIES = [] 

            # Create output file appending "_local.out"
            output_file = replace(f, ".csv" => "_local.out")
            # Path must be with / at all times
            output_file = replace(output_file, "\\" => "/")

            # Invoke local script
            open(output_file, "w") do file_output 
                redirect_stdout(file_output) do              
                    include(local_script)
                end
            end

            println(" --> LOCAL analysis of file $i/$(length(files)) ($output_file) finished.")

        # If test is GLOBAL
        else
            # Set anomalies variable with contents of anomalies file
            global ANOMALIES = UInt32.(parse.(UInt32, strip.(readlines(ANOMALIES_FILE))))

            # Create output file appending "_global.out"
            output_file = replace(f, ".csv" => "_global.out")
            # Path must be with / at all times
            output_file = replace(output_file, "\\" => "/")

            # Invoke global script
            open(output_file, "w") do file_output 
                redirect_stdout(file_output) do              
                    include(global_script)
                end
            end

            println(" --> GLOBAL analysis of file $i/$(length(files)) ($output_file) finished.")
        end

        # Update anomalies.txt file with new anomalies found in current test
        # 1- Read previous existing values in anomalies file
        existing_values = UInt32.(parse.(UInt32, strip.(readlines(ANOMALIES_FILE))))

        # 2- Merge with new anomalies found (avoid duplicates)
        updated_values = unique(vcat(existing_values, ANOMALIES))

        # 3- Write updated values back in anomalies file
        #    WARNING: These are all hexadecimals with 8 digits (since anomalies are Unit32)
        open(ANOMALIES_FILE, "w") do io
            for v in updated_values
                @printf(io, "0x%08X\n", v)
            end
        end
    end
end

##########################
#          MAIN          #
##########################

global ANOMALIES_FILE = []

# Get data path. The function does not finishes until the user provides a valid path to a .csv file or directory
data_path = get_data_path()

# Get number of header lines of input .csv files
header_lines = get_header_lines()

# Carry out LOCAL analyses (i.e., studying only local anomalies to each test)
analyze_data(data_path, false)

println();
println("******************************************************************************************************************************************");
println(" LOCAL analyses finished.")
println(" Results saved in files XXX_local.out in directory $data_path")
println("******************************************************************************************************************************************");
println()

# Carry out GLOBAL analyses (i.e., redoing the tests but now studying all anomalies across all tests + previous ones stored initially in Anomalies.txt)
analyze_data(data_path, true)
println();
println("******************************************************************************************************************************************");
println(" GLOBAL analyses finished.")
println(" Results saved in files XXX_global.out in directory $data_path")
println("******************************************************************************************************************************************");
