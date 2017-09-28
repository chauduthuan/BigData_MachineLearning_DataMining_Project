clc; clear; close all hidden;
%purpose of this is to store pca score, train, validate and test index of X
%and Y or labels

%reading combine_list_bag_of_word_remove_aux_normalized
combine_list_bag_of_word = readtable('combine_list_bag_of_word_remove_aux_normalized.csv');

%create bag of word
bag_of_word = table2array( combine_list_bag_of_word(:,3:end) );

num_user = size(combine_list_bag_of_word,1);
num_word = size(combine_list_bag_of_word,2) - 2;
display('done loading');

%calculate PCA
[wcoeff,score,latent,tsquared,explained] = pca(bag_of_word);
display('done pca');

%create labels (SD or LA)
label = table2array(combine_list_bag_of_word(:,2));
%seperate scores and class to train,validate, test 
label = table2array(combine_list_bag_of_word(:,2));
Y = ones(size(label,1),1);
%find LA => -1
for i = 1:size(label,1)
   if strcmp(cell2mat(label(i)),'LA')
       Y(i) = -1;
   end
end

%create indexes for train, validate and test data
sd_index = find(Y == 1);
la_index = find(Y == -1);

sd_sample_index = randperm(size(sd_index,1));
la_sample_index = randperm(size(la_index,1));

size_train = 3000;
size_validate = 1000;

train_index = [sd_index(sd_sample_index(1:size_train))...
    la_index(la_sample_index(1:size_train))];
validate_index = [sd_index(sd_sample_index(size_train+1:size_train+size_validate))... 
    la_index(la_sample_index(size_train+1:size_train+size_validate))];
test_index = [sd_index(sd_sample_index(size_train+size_validate+1:5000))...
    la_index(la_sample_index(size_train+size_validate+1:5000))];

%save workspace to be used in machine_learning_main.m
save('pca_score.mat','score','explained',...
    'label','Y',...
    'train_index','validate_index','test_index');

disp('finish');

