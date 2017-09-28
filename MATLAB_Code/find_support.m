function support = find_support(Table, attributes)
    %attributes is an array of column index
    N = size(Table,1);
    cur_table = ones(N,1);
    for att = attributes
       cur_table = cur_table & table2array(Table(:,att)); 
    end
    support = size(find(cur_table),1)/N;

end