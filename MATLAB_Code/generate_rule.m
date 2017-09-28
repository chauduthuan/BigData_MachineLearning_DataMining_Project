function rule_table = generate_rule(cur_rule_table, Table,left_att,right_att,thres)
    rule_table = cur_rule_table;
    
    cur_support = find_support(Table,[left_att right_att]);
    if size(right_att,2) == 0
        max_right = 0;
    else
        max_right = max(right_att);
    end
    
    if size(left_att,2) == 1
        return;
    end
    
    index_to_add = find(left_att > max_right);
    for index = index_to_add
       remove_att =  left_att(index);
       new_left_att = left_att(left_att ~= remove_att);
       new_right_att = [right_att remove_att];
       
       new_left_support = find_support(Table,new_left_att);
       confidence = cur_support/new_left_support;
       
       if confidence > thres
           %interest
           interest = confidence/find_support(Table,new_right_att);
           new_left_att_str = num2str(new_left_att);
           new_right_att_str = num2str(new_right_att);
           rule_table(end+1,:) = {cellstr(new_left_att_str),cellstr(new_right_att_str),confidence,interest};
           rule_table = generate_rule(rule_table,Table,new_left_att,new_right_att,thres);
       end
        
    end

end