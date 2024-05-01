#SemIP-DataExtraction
After testing a Xilinx FPGA with enabled SemIP, you ought to have got a log file written with a specific code. This script allows converting this file into a CSV file appropriate for LELAPE.

You only have to run on terminal the following instruction:

    julia SemIP-DataExtraction.jl YOUR_LOG_FILE

This script has not been tested many times, so it may lack some features. Feel free to change it if it does not fit your wishes.