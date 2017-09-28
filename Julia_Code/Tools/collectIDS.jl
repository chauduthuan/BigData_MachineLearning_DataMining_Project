ids = []
cursor = -1
count = 1;
while (cursor != 0)
  #buildQuery
  query = build_get_followers_ids_query(screen_name,cursor)
  #send request
  followers = get_followers_ids(options = query)
  #check type else sleep + resend, store ids
  ids = vcat(ids,followers["ids"])
  #store cursor
  cursor = followers["next_cursor"]
  print("get followers ", count, "\n")
  count = count + 1
  sleep(60)
end

function  build_get_users_lookup_query(array)
  ids_str = reduce("",array) do ids_str,x
    ids_str = ids_str*string(x)*","
  end
  Dict{Any, Any}("user_id" => ids_str)
end

user_ids = []; screen_names = []; locations = [];
followers_counts = []; friends_counts = [];

# For every 100 ids, we build a query to lookup their metadata
for i = 1:100:length(ids)
  length_arr = length(ids)-i>=99? 99:length(ids)-i
  cur_arr_ids = ids[i:i+length_arr]
  #build  query
  try
    print("look up group: " ,i,"\n")
  	query = build_get_users_lookup_query(cur_arr_ids)
  	#request
  	multiple_user_info = get_users_lookup(options = query)
    #user_ids
    cur_user_ids = map(x -> x.id, multiple_user_info)
    user_ids = vcat(user_ids, cur_user_ids)
  	#store screen names
  	cur_screen_names = map(x->x.screen_name, multiple_user_info)
  	screen_names = vcat(screen_names, cur_screen_names)
    #locations
    cur_location = map(x -> x.location, multiple_user_info)
    locations = vcat(locations, cur_location)
    #followers_count
    cur_followers_counts = map(x -> x.followers_count, multiple_user_info)
    followers_counts = vcat(followers_counts, cur_followers_counts)
    #friends_count
    cur_friends_counts = map(x -> x.friends_count, multiple_user_info)
    friends_counts = vcat(friends_counts, cur_friends_counts)
  catch
  end
end

# Store the collected metadata into a data frame
df = DataFrame(
  user_id = user_ids,
  screen_name = screen_names,
  location = locations,
  followers_count = followers_counts,
  friends_count = friends_counts)
