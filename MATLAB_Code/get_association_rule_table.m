function [freq_item_set_table, rule_table] = get_association_rule_table(Table, min_sup, min_conf)
    %this function will return frequent item set and assiociation rules 

    %generating frequent item set
    freq_item_set_table = get_frequent_item_set(Table,min_sup);
    freq_item_set = freq_item_set_table.freq_item_set;  %cell

    %generating association rules
    num_freq_items = size(freq_item_set,1);
    rule_table = get_rule(Table,freq_item_set(1),min_conf);
    for i = 2:num_freq_items
        freq_item = freq_item_set(i);
        cur_rule_table = get_rule(Table,freq_item,min_conf);
        rule_table = vertcat(rule_table,cur_rule_table);
    end



end