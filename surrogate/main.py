# Libraries
import random
from tabulate import tabulate
from converter import *
from surrogate import Surrogate

def main():
    
    # Read data
    input_list  = ["D0", "QD", "FN0", "QFN", "T0", "gamma", "Nc", "temperature", "stress"]
    output_list = ["time_to_tertiary"]
    reader = Reader("gb_data.csv", input_list, output_list)
    
    # Train
    surrogate = Surrogate()
    input_dict, output_dict = reader.get_data(400)
    surrogate.train(input_dict, output_dict, 100, 16)
    
    # Predict
    input_dict, output_dict = reader.get_data(100)
    prd_output_dict = surrogate.predict(input_dict)
    
    # Assess
    print_table(output_list[0], output_dict, prd_output_dict)
    
# Prints a table given the experimental and predicted values
def print_table(header:str, exp_dict:dict, prd_dict:dict):
    print(f"Summary for {header}")
    error_list = []
    summary_grid = [["index", "exp", "prd", "RE"]]
    for i in range(len(exp_dict[header])):
        exp_value = exp_dict[header][i]
        prd_value = prd_dict[header][i]
        error = round(100 * abs(exp_value - prd_value) / exp_value, 2)
        error_list.append(error)
        summary_grid.append([i+1, "{:0.3}".format(exp_value), "{:0.3}".format(prd_value), f"{error}%"])
    print(tabulate(summary_grid, headers="firstrow", tablefmt="grid"))
    avg_error = round(np.average(error_list), 2)
    print(f"Average error for {header} = {avg_error}%")

# Reader class
class Reader:
    
    def __init__(self, data_path:str, input_names:list, output_names:list):
        """
        Reads experimental data from CSV files
        
        Parameters:
        * `data_path`:    The path to the CSV file storing the experimental data
        * `input_names`:  The list of the input names
        * `output_names`: The list of the output names
        """
        
        # Gets the data
        data_dict = csv_to_dict(data_path)
        self.total_data = len(data_dict[list(data_dict.keys())[0]])
        
        # Extract inputs
        self.input_dict = {}
        for input_name in input_names:
            self.input_dict[input_name] = data_dict[input_name]
        
        # Extract outputs
        self.output_dict = {}
        for output_name in output_names:
            self.output_dict[output_name] = data_dict[output_name]
            
    def get_total_data(self) -> int:
        """
        Gets the total number of data points read in
        """
        return self.total_data

    def get_data(self, num_data:int) -> tuple:
        """
        Gets a number of input-output pairs specified by the user
        
        Parameters:
        * `num_data`: The number of input-output pairs
        
        Returns the a list of the inputs and a list of the outputs
        """
        
        # Check that the number of points requested is appropriate and get indexes
        if num_data > self.total_data:
            raise ValueError("The number of data points requested is greater than read in!")
        random_indexes = random.sample(range(self.total_data), num_data)
        
        # Get inputs
        input_dict = {}
        for header in self.input_dict.keys():
            input_dict[header] = [self.input_dict[header][i] for i in random_indexes]
        
        # Get outputs
        output_dict = {}
        for header in self.output_dict.keys():
            output_dict[header] = [self.output_dict[header][i] for i in random_indexes]
        
        # Return the data
        return input_dict, output_dict



if __name__ == "__main__":
    main()