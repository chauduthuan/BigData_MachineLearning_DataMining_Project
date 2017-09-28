function [conf_matrix,ave_accuracy,precision_rate,recall_rate] = evaluation(Ytest,Yhat)
    num_label = 2;
    num_sample = max(size(Ytest,2),size(Ytest,1));
    %confusion matrix
    conf_matrix = zeros(2,2);

    for i = 1:num_sample
        row = Ytest(i);
        col = Yhat(i);
        
        if (row ~= 1)
            row = 2;
        end
        
        if (col ~= 1)
            col = 2;
        end
        
        conf_matrix(row,col) = conf_matrix(row,col)+1;
 
    end
    
    
    %average accuracy
    total_right = 0;
    for i=1:num_label
       total_right = total_right + conf_matrix(i,i);
    end
    ave_accuracy = total_right/num_sample;

    %precision rate per class
    precision_rate = zeros(1,num_label);
    for i=1:num_label
       precision_rate(i) = conf_matrix(i,i)/sum(conf_matrix(:,i)); 
    end

    %recall rate per class
    recall_rate = zeros(1,num_label);
    for i=1:2
       recall_rate(i) = conf_matrix(i,i)/sum(conf_matrix(i,:)); 
    end
end
