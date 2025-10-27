import numpy as np
import matplotlib.pyplot as plt

#-----------------------------------------------------------
# Function: read_file
# Purpose: Reads numerical data from a text file.
# Input: filename (string) — path to the text file
# Output: data (numpy array) — loaded numerical data
#-----------------------------------------------------------
def read_file(filename):
    with open(filename, 'r') as f:
        data = np.loadtxt(f)
    return data


#-----------------------------------------------------------
# Function: calculate_avg_and_sem
# Purpose: Computes the mean and standard error of the mean (SEM)
#          across multiple datasets for the 2nd column (index 1).
# Input: data_list (list of numpy arrays)
# Output: avg_col2 (numpy array) — average of column 2
#         sem_col2 (numpy array) — SEM of column 2
#-----------------------------------------------------------
def calculate_avg_and_sem(data_list):
    avg_col2 = np.mean([data[:, 1] for data in data_list], axis=0)
    sem_col2 = np.std([data[:, 1] for data in data_list], axis=0) / np.sqrt(len(data_list))
    return avg_col2, sem_col2


#-----------------------------------------------------------
# Function: plot_data
# Purpose: Plots averaged training error with error bars.
# Input: x (array) — x-values (e.g., time)
#        y (array) — average error values
#        yerr (array) — SEM of error values
# Output: Displays a matplotlib plot
#-----------------------------------------------------------
def plot_data(x, y, yerr):
    plt.errorbar(x, y, yerr=yerr, fmt='o-', capsize=5)
    plt.xlabel('Training time')
    plt.ylabel('Avg training error')
    plt.title('Average training error')
    plt.grid(False)
    plt.show()


#-----------------------------------------------------------
# Main execution block
#-----------------------------------------------------------
if __name__ == '__main__':
    # Base filename for data files
    base_filename = 'data/te_'  # Files expected: te_1.txt, te_2.txt, ...
    num_files = 10              # Number of files to read (adjust as needed)

    # Read all data files into a list
    data_list = []
    for i in range(1, num_files + 1):
        filename = base_filename + str(i) + '.txt'
        data = read_file(filename)
        data_list.append(data)

    # Compute average and SEM of the 2nd column across files
    avg_col2, sem_col2 = calculate_avg_and_sem(data_list)

    # Extract x-values (1st column) from the first dataset
    # Assumes all datasets have identical x-values
    x_values = data_list[0][:, 0]

    # Plot average training error with SEM
    plot_data(x_values, avg_col2, sem_col2)

    #-----------------------------------------------------------
    # Save the computed averages and SEM values to an output file
    #-----------------------------------------------------------
    with open('output.txt', 'w') as f:
        f.write("x_values\tavg_col2\tsem_col2\n")  # Header line
        for x, avg, sem in zip(x_values, avg_col2, sem_col2):
            f.write(f"{x}\t{avg}\t{sem}\n")

