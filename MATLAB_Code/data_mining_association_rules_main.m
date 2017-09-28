clc; clear; close all hidden;
%threshold for support, confidence and interest
min_sup_arr = 0.1:0.05:0.45;
min_conf = 0.9;
min_interest = 1.5;

%load table
profile_table = readtable('profile.csv');

%GENERATE SD and LA TABLES
location = profile_table.location;
loc = ones(size(location,1),1);
%find LA => -1
for i = 1:size(location,1)
   if strcmp(cell2mat(location(i)),'LA')
       loc(i) = -1;
   end
end

%create indexes for train, validate and test data
sd_index = find(loc == 1);
la_index = find(loc == -1);

sd_sample_index = randperm(size(sd_index,1));
la_sample_index = randperm(size(la_index,1));

%SD and LA profile table
sample_size = min(size(sd_index,1), size(la_index,1));
sd_profile_table = profile_table(sd_index(sd_sample_index(1:sample_size)),:);
la_profile_table = profile_table(la_index(la_sample_index(1:sample_size)),:);

sd_table = quantize_columns(sd_profile_table);
la_table = quantize_columns(la_profile_table);
combine_table = vertcat(sd_table,la_table);
names = sd_table.Properties.VariableNames';
clearvars -except names combine_table sd_table la_table...
    min_sup_arr min_conf min_interest;
%-------------------------------------
%% METRICS
%number of freq and rule for sd and la
sd_freq_item_num = zeros(size(min_sup_arr));
sd_rule_num = zeros(size(min_sup_arr));
la_freq_item_num = zeros(size(min_sup_arr));
la_rule_num = zeros(size(min_sup_arr));
%frequent item set
freq_shared_num_arr = zeros(size(min_sup_arr));
freq_shared_ratio_arr = zeros(size(min_sup_arr));
freq_ratio_sd_arr = zeros(size(min_sup_arr));
freq_ratio_la_arr = zeros(size(min_sup_arr));
%association rules
rule_shared_num_arr = zeros(size(min_sup_arr));
rule_shared_ratio_arr = zeros(size(min_sup_arr));
rule_ratio_sd_arr = zeros(size(min_sup_arr));
rule_ratio_la_arr = zeros(size(min_sup_arr));

%start mining
counter = 1;
for min_sup = min_sup_arr
    %find sd rules
    [sd_freq_item_set_table, sd_rule_table ] = get_association_rule_table(sd_table, min_sup, min_conf);
    %find la rules
    [la_freq_item_set_table, la_rule_table ] = get_association_rule_table(la_table, min_sup, min_conf);
    
    %pick most interesting rules
    %SD
    sd_sorted_rules = sortrows(sd_rule_table,{'interest','confidence'},{'descend','descend'});
    sd_sorted_rules = sd_sorted_rules(find(sd_sorted_rules.interest > min_interest),:);
    %LA
    la_sorted_rules = sortrows(la_rule_table,{'interest','interest'},{'descend','descend'});
    la_sorted_rules = la_sorted_rules(find(la_sorted_rules.interest > min_interest),:);
    
    %comparision or find share things
    %freq
    [freq_shared_num, freq_shared_ratio, freq_ratio_sd, freq_ratio_la]...
        = find_shared_freq_or_rules(sd_freq_item_set_table, la_freq_item_set_table);
    %rule
    [rule_shared_num, rule_shared_ratio, rule_ratio_sd, rule_ratio_la]...
        = find_shared_freq_or_rules(sd_sorted_rules, la_sorted_rules);
    
    %save evaluation metrics
    %number of freq and rule
    sd_freq_item_num(counter) = size(sd_freq_item_set_table,1);
    sd_rule_num(counter) = size(sd_sorted_rules,1);
    la_freq_item_num(counter) = size(la_freq_item_set_table,1);
    la_rule_num(counter) = size(la_sorted_rules,1);
    %shared frequent item set
    freq_shared_num_arr(counter) = freq_shared_num;
    freq_shared_ratio_arr(counter) = freq_shared_ratio;
    freq_ratio_sd_arr(counter) = freq_ratio_sd;
    freq_ratio_la_arr(counter) = freq_ratio_la;
    %shared association rules
    rule_shared_num_arr(counter) = rule_shared_num;
    rule_shared_ratio_arr(counter) = rule_shared_ratio;
    rule_ratio_sd_arr(counter) = rule_ratio_sd;
    rule_ratio_la_arr(counter) = rule_ratio_la;

    %increase counter
    counter = counter + 1;
end

%---------------------
%plot number of frequent item set
figure;
plot(min_sup_arr,sd_freq_item_num,'r','DisplayName','SD'); hold on;
plot(min_sup_arr,la_freq_item_num,'g','DisplayName','LA'); hold on;
plot(min_sup_arr,freq_shared_num_arr,'b','DisplayName','shared'); hold on;
xlabel('min support');
ylabel('frequent number');
title(sprintf('Number of frequent item set\n with min confidence = %3.1f and min interest = %3.1f',min_conf, min_interest));
legend('show');

%plot number of rules
figure;
plot(min_sup_arr,sd_rule_num,'r','DisplayName','SD'); hold on;
plot(min_sup_arr,la_rule_num,'g','DisplayName','LA'); hold on;
plot(min_sup_arr,rule_shared_num_arr,'b','DisplayName','shared'); hold on;
xlabel('min support');
ylabel('rule number');
title(sprintf('Number of rules\n with min confidence = %3.1f and min interest = %3.1f',min_conf, min_interest));
legend('show');

%plot frequent ratios
figure;
plot(min_sup_arr,freq_ratio_sd_arr,'r','DisplayName','shared freq/SD freq'); hold on;
plot(min_sup_arr,freq_ratio_la_arr,'g','DisplayName','shared freq/LA freq'); hold on;
plot(min_sup_arr,freq_shared_ratio_arr,'b','DisplayName','shared freq/total freq'); hold on;
xlabel('min support');
ylabel('frequent ratio');
title(sprintf('shared frequent item set ratio\n with min confidence = %3.1f and min interest = %3.1f',min_conf, min_interest));
legend('show');

%plot rules ratios
figure;
plot(min_sup_arr,rule_ratio_sd_arr,'r','DisplayName','shared rules/SD rule'); hold on;
plot(min_sup_arr,rule_ratio_la_arr,'g','DisplayName','shared rules/LA rule'); hold on;
plot(min_sup_arr,rule_shared_ratio_arr,'b','DisplayName','shared rules/total rules'); hold on;
xlabel('min support');
ylabel('rule ratio');
title(sprintf('shared rules ratio\n with min confidence = %3.1f and min interest = %3.1f',min_conf, min_interest));
legend('show');


%-------------------------------------------
%% FINAL CONFIGURATION for MINING
%define threshold
min_sup = 0.3;
min_conf = 0.8;
min_interest = 1.5;
fprintf('final configuration: min_sup = %3.1f, min_con f = %3.1f \n',min_sup, min_conf);

%start mining SD and LA
%find sd rules
[sd_freq_item_set_table, sd_rule_table ] = get_association_rule_table(sd_table, min_sup, min_conf);
%find la rules
[la_freq_item_set_table, la_rule_table ] = get_association_rule_table(la_table, min_sup, min_conf);

%pick most interesting rules with min_interest
%SD
sd_sorted_rules = sortrows(sd_rule_table,{'interest','confidence'},{'descend','descend'});
sd_sorted_rules = sd_sorted_rules(find(sd_sorted_rules.interest > min_interest),:);
%LA
la_sorted_rules = sortrows(la_rule_table,{'interest','confidence'},{'descend','descend'});
la_sorted_rules = la_sorted_rules(find(la_sorted_rules.interest > min_interest),:);

%comparision or find share things
%freq
[freq_shared_num, freq_shared_ratio, freq_ratio_sd, freq_ratio_la]...
    = find_shared_freq_or_rules(sd_freq_item_set_table, la_freq_item_set_table);
%rule
[rule_shared_num, rule_shared_ratio, rule_ratio_sd, rule_ratio_la]...
    = find_shared_freq_or_rules(sd_sorted_rules, la_sorted_rules);
%create compare table
compare_name = {'freq_shared_num'; 'freq_shared_ratio'; 'freq_ratio_sd'; 'freq_ratio_la';...
   'rule_shared_num'; 'rule_shared_ratio'; 'rule_ratio_sd'; 'rule_ratio_la';...
   'sd_freq_num';'la_freq_num';...
   'sd_rule_num';'la_rule_num'};
compare_value = [freq_shared_num; freq_shared_ratio; freq_ratio_sd; freq_ratio_la;...
   rule_shared_num; rule_shared_ratio; rule_ratio_sd; rule_ratio_la;...
   size(sd_freq_item_set_table,1);size(la_freq_item_set_table,1);...
   size(sd_sorted_rules,1);size(sd_sorted_rules,1)];
compare_table = table(compare_name,compare_value,...
    'VariableNames',{'name','value'});

%find intersection between rules
sd_rule_name = strcat(table2cell(sd_sorted_rules(:,1)),' ->  ', table2cell(sd_sorted_rules(:,2)));
la_rule_name = strcat(table2cell(la_sorted_rules(:,1)),' ->  ', table2cell(la_sorted_rules(:,2)));
[shared_rule_name,sd_shared_index,la_shared_index] = intersect(sd_rule_name,la_rule_name);

%change the format of rules: left_rule -> right_rule as 1 column
%create SD rules table with correct format
sd_shared_indicator = zeros(size(sd_rule_name));
sd_shared_indicator(sd_shared_index) = 1;
sd_rule_correct_format_table = table(sd_rule_name,sd_sorted_rules.confidence,...
    sd_sorted_rules.interest,sd_shared_indicator,...
    'VariableNames',{'rule','confidence','interest','shared_or_not'});
%create LA rules table with correct format
la_shared_indicator = zeros(size(la_rule_name));
la_shared_indicator(la_shared_index) = 1;
la_rule_correct_format_table = table(la_rule_name,la_sorted_rules.confidence,...
    la_sorted_rules.interest,la_shared_indicator,...
    'VariableNames',{'rule','confidence','interest','shared_or_not'});

%display final results
display(compare_table);
display(shared_rule_name);
display(sd_rule_correct_format_table);
display(la_rule_correct_format_table);

%% given min_sup and min_conf, change min_interest
%changing min_interset => number of rules
min_interest_arr = 1:0.1:max(max(sd_rule_table.interest),max(la_rule_table.interest));
sd_rule_num = zeros(size(min_interest_arr));
la_rule_num = zeros(size(min_interest_arr));
counter = 1;
for min_interest = min_interest_arr
    sd_rule_num(counter) = size(find(sd_rule_table.interest > min_interest),1);
    la_rule_num(counter) = size(find(la_rule_table.interest > min_interest),1);
    counter = counter + 1;
end
figure;
plot(min_interest_arr,sd_rule_num,'r','DisplayName','SD'); hold on;
plot(min_interest_arr,la_rule_num,'g','DisplayName','LA'); hold on;
xlabel('min interest');
ylabel('number of rules');
legend('show');
title(sprintf('number of rules when changing interest\n with min support = %3.1f and min confidence = %3.1f',min_sup, min_conf));
