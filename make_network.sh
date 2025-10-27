#!/bin/bash

# Create a directory called 'data' if it doesn't already exist.
mkdir -p data

#****************************************************

# Print confirmation message
echo 'ok'

# Initialize a counter to track simulation runs
count=1

# Read each line from stdata.txt (each line defines a new source-target pair)
cat stdata.txt | while read line
do
  # Notify user that compilation is starting
  echo 'running the makefile and executable'
  echo 'entering /code'

  # Change directory to 'code' where the Fortran program and Makefile reside
  cd code

  # Clean old object files and executables
  make clean
  make         # Build the executable (typically result.exe)
  make clean   # Clean again to avoid residual object clutter

  # Show the current source-target line being used
  echo $line

  # Save current line to a temporary input file
  echo $line > parameter.txt

  # Run the compiled program with input redirection from parameter.txt
  time ./result.exe < parameter.txt

  # Go back to the parent directory
  cd ..

  # Archive the output data files with unique names using the counter
  cat data/time_error.txt > data/te_${count}.txt
  cat data/trained_network_k.txt > data/tr_k_${count}.txt
  cat data/trained_network_l0.txt > data/tr_l0_${count}.txt
  cat data/trained_network_xy.txt > data/tr_net_${count}.txt

  # Increment counter for next run
  count=$((count + 1))

# End of loop reading source-target lines
done

#---------------------------------------
# Extra utilities (currently commented out):

# Loop alternative to test input formatting
# cat stdata.txt | while read line; do echo $line > newfile; cat newfile; done

# Remove duplicate lines in source-target file
# awk -F"\t" '!seen[$1, $2, $3, $4]++' data/source_target_nodes.txt

# Save deduplicated entries into stdata.txt
# awk -F"\t" '!seen[$1, $2, $3, $4]++' data/source_target_nodes.txt > stdata.txt

