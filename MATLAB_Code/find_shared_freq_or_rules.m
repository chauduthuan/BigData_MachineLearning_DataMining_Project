function [shared_num, shared_ratio, ratio_left, ratio_right] = find_shared_freq_or_rules(left_table, right_table)
    N = size(left_table,2);
    if N == 2
        left = left_table(:,1);
        right = right_table(:,1);
    else
        left = strcat(table2cell(left_table(:,1)),' -> ', table2cell(left_table(:,2)));
        right = strcat(table2cell(right_table(:,1)),' -> ', table2cell(right_table(:,2)));
    end
    
    shared = intersect(left,right);
    shared_num = size(shared,1);
    
    total = union(left, right);
    total_num = size(total,1);
    shared_ratio = shared_num/total_num;

    ratio_left = shared_num/size(left,1);
    ratio_right = shared_num/size(right,1);
end