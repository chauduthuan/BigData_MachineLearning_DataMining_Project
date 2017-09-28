clc; clear; close all hidden;

load('pca_score.mat');

thres = 0.5;
C_arr = 1:5:100;

num_user = size(score,1);
num_word = size(score,2);

total = 0;
total_explained = sum(explained);
for K=1:num_word
    total = total + explained(K);
    if total >= thres*total_explained
        display(K);
        break;
    end
end


%-----------------
%generate trainm validate and test data 
Xtrain = score(train_index,1:K);
Ytrain = Y(train_index,:);

Xvalidate = score(validate_index,1:K);
Yvalidate = Y(validate_index,:);

Xtest = score(test_index,1:K);
Ytest = Y(test_index,:);

%----------------
%% TRAINING SVM MODEL
%linear metrics
linear_accuracy_arr = zeros(size(C_arr));
linear_precision_arr = zeros(size(C_arr,2),2);
linear_recall_arr = zeros(size(C_arr,2),2);
linear_best_accuracy = 0;
linear_best_C = 0;

%rbf metrics
rbf_accuracy_arr = zeros(size(C_arr));
rbf_precision_arr = zeros(size(C_arr,2),2);
rbf_recall_arr = zeros(size(C_arr,2),2);
rbf_best_accuracy = 0;
rbf_best_C = 0;

%training svm
index = 1;
for C = C_arr
    %linear svm
    Mdl = fitcsvm(Xtrain,Ytrain,'KernelFunction','linear','BoxConstraint',C);
    YvalHat = predict(Mdl,Xvalidate);
    [~,ave_accuracy,precision_rate,recall_rate] = evaluation(Yvalidate,YvalHat);
    linear_accuracy_arr(index) = ave_accuracy;
    linear_precision_arr(index,:) = precision_rate;
    linear_recall_arr(index,:) = recall_rate;
    %save best accuracy
    if ave_accuracy > linear_best_accuracy
        linear_best_accuracy = ave_accuracy;
        linear_best_C = C;
        linear_best_Mdl = Mdl;
    end
    
    %rbf svm
    Mdl = fitcsvm(Xtrain,Ytrain,'KernelFunction','rbf','BoxConstraint',C,'KernelScale','auto');
    YvalHat = predict(Mdl,Xvalidate);
    [~,ave_accuracy,precision_rate,recall_rate] = evaluation(Yvalidate,YvalHat);
    rbf_accuracy_arr(index) = ave_accuracy;
    rbf_precision_arr(index,:) = precision_rate;
    rbf_recall_arr(index,:) = recall_rate;
    %save best accuracy
    if ave_accuracy > rbf_best_accuracy
        rbf_best_accuracy = ave_accuracy;
        rbf_best_C = C;
        rbf_best_Mdl = Mdl;    
    end
    index = index + 1;
end
display('done svm');

%plot accuracy for svm
figure;
plot(C_arr, linear_accuracy_arr,'r','DisplayName','linear'); hold on;
plot(C_arr, rbf_accuracy_arr,'b','DisplayName','rbf'); hold on;
xlabel('C');
ylabel('accuracy');
title(sprintf('linear vs rbf SVM with K = %i',K));
legend('show');

%plot precision for svm
figure;
plot(C_arr, linear_precision_arr(:,1),'r','DisplayName','linear SD'); hold on;
plot(C_arr, linear_precision_arr(:,2),'b','DisplayName','linear LA'); hold on;
plot(C_arr, rbf_precision_arr(:,1),'k','DisplayName','rbf SD'); hold on;
plot(C_arr, rbf_precision_arr(:,2),'g','DisplayName','rbf LA'); hold on;
xlabel('C');
ylabel('precision rate');
title(sprintf('linear vs rbf SVM with K = %i',K));
legend('show');

%plot recall for svm
figure;
plot(C_arr, linear_recall_arr(:,1),'r','DisplayName','linear SD'); hold on;
plot(C_arr, linear_recall_arr(:,2),'b','DisplayName','linear LA'); hold on;
plot(C_arr, rbf_recall_arr(:,1),'k','DisplayName','rbf SD'); hold on;
plot(C_arr, rbf_recall_arr(:,2),'g','DisplayName','rbf LA'); hold on;
xlabel('C');
ylabel('recall rate');
title(sprintf('linear vs rbf SVM with K = %i',K));
legend('show');




%-------------------------
%% TRAINING NEURAL NETWORK
act = {'sigm','tanh_opt'};
out = {'sigm','linear','softmax'};

%create nnY data (label in neural network)
nnYtrain = zeros(size(Ytrain,1),2);
nnYtrain(find(Ytrain == 1),1) = 1;
nnYtrain(find(Ytrain == -1),2) = 1;


% Create NN Model
%metrics
counter = 0;
nn_accuracy_arr = zeros(length(act)*length(out),1) ;
nn_precision_arr = zeros(length(act)*length(out),2);
nn_recall_arr = zeros(length(act)*length(out),2);
nn_best_accuracy = 0;
best_config = [act(1) out(1)];

%training
for j = 1:size(act,2)
    for k = 1:size(out,2)
        half_K = round(K/2);
        nn = nnsetup([K half_K 2]);
        nn.activation_function= cell2mat(act(j)); 
        nn.output  = cell2mat(out(k));  
        nn.learningRate  = 0.5;  		% learning rates
        nn.scaling_learningRate= 1.5; 	
        
        clear opts;
        opts.numepochs =  1;   %  Number of full sweeps through data
        opts.batchsize = 100;  %  Take a mean gradient step over this many samples
        [nn, L] = nntrain(nn, Xtrain, nnYtrain, opts);
        nnYhat = nnpredict(nn, Xvalidate);
        %make LA -> -1
        nnYhat(find(nnYhat == 2)) = -1;
        %evaluation
        [~,ave_accuracy,precision_rate,recall_rate] = evaluation(Yvalidate,nnYhat);

        % Store metric values
        counter = counter + 1;
        nn_accuracy_arr(counter) = ave_accuracy;
        nn_precision_arr(counter,:) = precision_rate;
        nn_recall_arr(counter,:) = recall_rate;
        names(counter) = strcat(act(j),'-',out(k));
        %store best accuracy
        if ave_accuracy > nn_best_accuracy
            nn_best_accuracy = ave_accuracy;
            best_config = [ act(j) out(k) ];
            nn_best_Mdl = nn;
        end

    end 
end
display('done neural network');

%plot accuracy all nn
figure;
bar(nn_accuracy_arr);
set(gca,'xticklabel',names);
xlabel('configuration (activation and out function)');ylabel('Accuracy');
title(sprintf('Neural Network with K=%d',K));

%plot precision SD for nn
figure;
bar(nn_precision_arr(:,1));
set(gca,'xticklabel',names);
xlabel('configuration (activation and out function)');ylabel('precision');
title(sprintf('Neural Network precision for SD with K=%d',K));

%plot precision LA for nn
figure;
bar(nn_precision_arr(:,2));
set(gca,'xticklabel',names);
xlabel('configuration (activation and out function)');ylabel('precision');
title(sprintf('Neural Network precision for LA with K=%d',K));

%plot recall SD for nn
figure;
bar(nn_recall_arr(:,1));
set(gca,'xticklabel',names);
xlabel('configuration (activation and out function)');ylabel('recall');
title(sprintf('Neural Network recall for SD with K=%d',K));

%plot recall LA for nn
figure;
bar(nn_recall_arr(:,2));
set(gca,'xticklabel',names);
xlabel('configuration (activation and out function)');ylabel('recall');
title(sprintf('Neural Network recall for LA with K=%d',K));





%------------------------
%% DECISION TREE
dt_best_Mdl = fitctree(Xtrain,Ytrain,'OptimizeHyperparameters','auto');
YvalHat = predict(dt_best_Mdl,Xvalidate);
[~,dt_best_accuracy,~,~] = evaluation(YvalHat,Yvalidate);
display('done decision tree');

%-------------------
%% ADABOOST
%metrics
iter_arr = 10:10:100;
adaboost_accuracy_arr = zeros(size(iter_arr));
adaboost_precision_arr = zeros(size(iter_arr,2),2);
adaboost_recall_arr = zeros(size(iter_arr,2),2);
adaboost_best_accuracy = 0;
counter = 1;
%training adaboost
if K < 600
    for iter = iter_arr
       [~,Mdl] = adaboost('train',Xtrain,Ytrain,iter);
       [YvalHat,~] = adaboost('apply',Xvalidate,Mdl);
       [~,ave_accuracy,precision_rate,recall_rate] = evaluation(YvalHat,Yvalidate);
       adaboost_accuracy_arr(counter) = ave_accuracy;
       adaboost_precision_arr(counter,:) = precision_rate;
       adaboost_recall_arr(counter,:) = recall_rate;
        if ave_accuracy > adaboost_best_accuracy
           adaboost_best_accuracy = ave_accuracy;
           adaboost_best_Mdl = Mdl;
        end
        counter = counter + 1;
    end
    %plot accuracy adaboost
    figure;
    plot(iter_arr, adaboost_accuracy_arr);
    xlabel('number of iteration');
    ylabel('accuracy');
    title(sprintf('adaboost accuracy with K = %i',K));
    %plot precision adaboost
    figure;
    plot(iter_arr, adaboost_precision_arr(:,1),'r','DisplayName','SD'); hold on;
    plot(iter_arr, adaboost_precision_arr(:,2),'b','DisplayName','LA'); hold on;
    xlabel('number of iteration');
    ylabel('precision rate');
    title(sprintf('adaboost precision rate with K = %i',K));
    legend('show');
    %plot recall adaboost
    figure;
    plot(iter_arr, adaboost_recall_arr(:,1),'r','DisplayName','SD'); hold on;
    plot(iter_arr, adaboost_recall_arr(:,2),'b','DisplayName','LA'); hold on;
    xlabel('number of iteration');
    ylabel('recall rate');
    title(sprintf('adaboost recall rate with K = %i',K));
    legend('show');
end
display('done adaboost');
    

%------------------------
%% plot all the best
figure;
best_accuracy_arr = [linear_best_accuracy rbf_best_accuracy...
        nn_best_accuracy dt_best_accuracy adaboost_best_accuracy];
bar(best_accuracy_arr);
names_model= {'linear svm', 'rbf svm', 'neural network', 'decision tree','adaboost'};
set(gca,'xticklabel',names_model);
xlabel('model');ylabel('Accuracy');
title(sprintf('Accuracy vs best Model (K=%d)',K));


%------------------
%% finding the best model, apply to test data
max_accuracy = max(best_accuracy_arr);
best_model_index = find(best_accuracy_arr == max_accuracy);
best_model_index = best_model_index(1);
best_model_name = names_model(best_model_index);
switch (best_model_index)
    case 1
        best_model = linear_best_Mdl;
    case 2
        best_model = rbf_best_Mdl;
    case 3
        best_model = nn_best_Mdl;
    case 4
        best_model = dt_best_Mdl;
    case 5
        best_model = adaboost_best_Mdl;
end

if best_model_index == 3
    YtestHat = nnpredict(best_model,Xtest);
elseif best_model_index == 5
    [YtestHat,~] = adaboost('apply',Xtest,adaboost_best_Mdl);
else
    YtestHat = predict(best_model,Xtest);
end

fprintf('best model is %s model \n',cell2mat(best_model_name));
[conf_matrix,ave_accuracy,precision_rate,recall_rate] = evaluation(Ytest,YtestHat);
display(conf_matrix);
display(ave_accuracy);
display(precision_rate);
display(recall_rate);


