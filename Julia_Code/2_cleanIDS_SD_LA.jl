workspace();
using DataFrames

# Apply the cleanIDS program on the location "San Diego"
location = "San Diego"
path_to_file = "temp/KPBS_ids_list.csv";
include("Tools/cleanIDS.jl")
# Apply the cleanIDS program on the location "Los Angeles"
location = "Los Angeles"
path_to_file = "temp/FOXLA_ids_list.csv";
include("Tools/cleanIDS.jl")
