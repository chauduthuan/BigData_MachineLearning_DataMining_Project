============================================== README ===================================================

----------------------------------------------PURPOSE----------------------------------------------------

- To process the data generated from the Julia Code. The data processing will include Classif

----------------------------------------------CONTEXT ---------------------------------------------------

- All instructions in this README will be processing Twitter data from two regions,
	San Diego and Los Angeles. San Diego data will be collected from the Twitter account
	"KPBS" and Los Angeles data will be collected from the Twitter account "FOXLA".

-----------------------------------------------FILES-----------------------------------------------------

README.txt							- This file.

data_mining_association_rules_main.m		- This file takes "profile.csv" as input, and applies
										association rule mining on the data.

pca_generate_score.m					- This file takes "combine_list_bag_of_word_remove_aux_normalized.csv"
										as input, and calculates and stores the pca score in "pca_score.mat"
machine_learning_main.m					- This file takes the "pca_score.mat" and performs various classification
										methods and plots their performance. 


-------------------------------------------PRE-REQUISITE-------------------------------------------------

- Install MATLAB 2016b or higher. 

--------------------------------------------WORKFLOW----------------------------------------------------

The following MATLAB code contains two processes (Classification and Association Rule Mining) that 
can be executed separately. The code for Classification must be ran sequentially, first starting
with "pca_generate_score.m", followed by "machine_learning_main.m". 

pca_generate_score.m				- Generates pca score and stores it in "pca_score.mat"
machine_learning_main.m				- Performs Classification

data_mining_association_rules_main.m	- Performs Assoication Rule Mining

---------------------------------------------OUTPUT-----------------------------------------------------

The output from Classification and Association Rule Mining Code are graphs/plots and numerical values 
that reflects the performance or results. The output of all MATLAB code are not saved automatically, 
they are saved manually for future review. 














