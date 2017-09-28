function freq_item_set_table = generate_freq_item(cur_freq_item_set_table, Table, cur_attributes, thres)
    %support = find_support(Table,attributes);
    %freq_item = cur_freq_item_set;
    freq_item_set_table = cur_freq_item_set_table;
    num_att = size(Table,2);

    if size(cur_attributes,2) == 0
        min_att_to_add = 1;
    else
        min_att_to_add = max(cur_attributes) + 1;
    end

    %add to frequent item set table
    for att = min_att_to_add:num_att
        new_attributes = [cur_attributes att];
        new_support = find_support(Table,new_attributes);
        new_attributes_str = num2str(new_attributes);
        
        if new_support > thres
           %this is for table
           freq_item_set_table(end+1,:) = {cellstr(new_attributes_str),new_support};
           freq_item_set_table = generate_freq_item(freq_item_set_table,Table,new_attributes,thres);
        end
    end    
end