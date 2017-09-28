============================================== README ===================================================

----------------------------------------------PURPOSE----------------------------------------------------

- To collect Twitter data through Julia's Twitter API and format it as input to MATLAB Code
	for Classification and Association Rule Mining problem.

----------------------------------------------CONTEXT ---------------------------------------------------

- All instructions in this README will be collecting Twitter data from two regions,
	San Diego and Los Angeles. San Diego data will be collected from the Twitter account
	"KPBS" and Los Angeles data will be collected from the Twitter account "FOXLA".

-----------------------------------------------FILES-----------------------------------------------------

README.txt				- This file.
Tools/					- Folder that contains cleanIDS.jl, collectIDS.jl, get_packages.jl and
							google-10000-english-usa.txt.
DRIVER.jl					- Julia file used to run all Julia files listed below.
1_collect_IDS_SD_LA.jl		- Julia file used to collect Twitter account IDs.
2_cleanIDS_SD_LA.jl			- Julia file used to remove non-"San Diego" and non-"Los Angeles" IDs.
3_get_Tweet_Data_SD_LA.jl	- Julia file used Tweets from IDs.
4_parse_tweets.jl			- Julia file used to generate bag of words
5_data_processing.jl		- Julia file used to generate profile 

-------------------------------------------PRE-REQUISITE-------------------------------------------------

- Install Julia v0.5.0 or higher 
- Get 1) Access_token 2) Access_secret 3) Consumer_key 4) Consumer_secret 
	from the following steps:
	a) Create an account in https://apps.twitter.com/
	b) Create a Twitter App
	c) Retrieve the four OAuth items mentioned above from the Twitter App
		(This will be used to collect Twitter data from the Twitter API)
- (Optional) Install latest JUNO, Julia's IDE. After installing IDE, go to command terminal and execute
	"julia". Once julia is up with prompt "julia> ", enter "julia> Pkg.add("IJulia")".

Support Links:
http://julialang.org/
http://junolab.org/
https://dev.twitter.com/overview/api

--------------------------------------------WORKFLOW----------------------------------------------------

The following julia files needs to be executed sequentially in Julia's terminal/IDE. 

get_packages.jl		- Get needed Julia packages used in program.
1_collectIDS_SD_LA.jl 	- Collect follower Twitter IDs from account "KBPS" and "FOXLA"
2_cleanIDS_SD_LA.jl		- Remove Twitter IDs that are not from "San Diego" or "Los Angeles"
3_get_Tweet_Data_SD_LA.jl	- Gather Tweets from the collected Twitter IDs
4_parse_tweets.jl		- Parse Tweet text and generate a bag of words table for MATLAB to use.
						( Used in the Classification problem )
5_data_processing.jl		- Extract Tweet metadata and generate features for MATLAB to use.
						( Used in the Association Rule Mining problem )

---------------------------------------------TO RUN-----------------------------------------------------

If executing in command line terminal, "cd" to the directory of where the DRIVER.jl file is located.
If executing in Julia IDE, "open" the DRIVER.jl and ensure that it has set your working directory as the
	directory where the DRIVER.jl is located.  

The Workflow can be execute in either of the two ways:

1) Run the DRIVER.jl file in Julia terminal/IDE. This will run all mentioned .jl files above.

2) Run each .jl file in Julia terminal/IDE sequentially as mentioned above in WORKFLOW.

---------------------------------------------OUTPUT-----------------------------------------------------

In the "Output" folder, there are two .csv files used for MATLAB's input.

combine_list_bag_of_word_remove_aux_normalized.csv	( Used for Classification problem )
profile.csv									( Used for Association Rule Mining )
