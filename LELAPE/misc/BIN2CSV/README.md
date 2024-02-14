# BIN2CSV
Many times, the experiment consists in downloading the content of an FPGA and performing a bit-to-bit comparison with the initial one, usually called _GOLDEN_. 

This script compares two files in binary format and creates a CSV with the word address as well as the content and the initial pattern. This file can be used as an input for LELAPE. 

You will find inside the zip file an actual golden file from an Artix-7 FPGA along with a couple of files got after irradiating the device.