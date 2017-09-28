# Initialize file read in
input_file = split(path_to_file,"/")[end]
folder = path_to_file[1:end-length(input_file)]

list_df = readtable(path_to_file)

# Delete any rows whose "location" is NA
deleterows!(list_df,find(isna(list_df[:,symbol("location")])))

# Returns the index of users with the desired location
function find_users_in_location(d,location)
  location_index = reduce(Int64[],1:length(d)) do a,i
  if match(Regex("\W*($location)\W*"), d[i]) != nothing
      append!(a,i)
    end
    a
  end
end

location_index = find_users_in_location(list_df[:location],location)

new_df = list_df[location_index,:]
writetable(folder*input_file[1:end-4]*"_"*replace(location," ","_")*".csv",new_df)
