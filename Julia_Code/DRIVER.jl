print("Started Program\n");

# Install Required Packages
print("Installing Required Packages...\n");
include("Tools/get_packages.jl");
print("Done Installing Packages\n");

# Excute All Julia files in Sequence
include("1_collectIDS_SD_LA.jl");
include("2_cleanIDS_SD_LA.jl");
include("3_get_Tweet_Data_SD_LA.jl");
include("4_parse_tweet.jl");
include("5_data_processing.jl");

print("End of Program\n");
