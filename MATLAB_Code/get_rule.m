function rule_table = get_rule(Table,freq_item,thres)
    names = {'left_rule';'right_rule';'confidence';'interest'};
    left_rule = cell2mat(freq_item);
    right_rule = '';
    rule_table = table(cellstr(left_rule),cellstr(right_rule),1,0,'VariableNames',names);
    
    left_att = str2num(left_rule);
    right_att = str2num(right_rule);

    rule_table = generate_rule(rule_table,Table,left_att,right_att,thres);
end