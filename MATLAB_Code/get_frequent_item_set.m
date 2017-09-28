function freq_item_set_table = get_frequent_item_set(Table,thres)
    names = {'freq_item_set';'support'};
    freq_item_set_table = table(cellstr(''),1,'VariableNames',names);
    freq_item_set_table = generate_freq_item(freq_item_set_table, Table, [],thres);

end