workspace()
using DataFrames
using Twitter
using Dates

curr_date = string(Dates.today())

SEARCH_RATE_LIMIT = 180
GET_FOLLOWERS_LIMIT = 15

# NOTE: This is where you will enter your own access token/secret and consumer
# key/secret from your Twitter App you have created.
access_token = "786644044008988673-ZoxtvT9CUVgUKRQF8pheoeIrDaFvif8";
access_secret = "2vXAqehb4WITv3Jz7SQop4T73CQ6hCKgYzeF3dBWGeGlC";
consumer_key = "ZljUwi4O6zXmGTtOnClV60INn";
consumer_secret = "yqwfkrPv92QsP8AG6oNzo2uYIzXx9l26aWTlHxv4zHClt9DiQA";
twitterauth(consumer_key, consumer_secret, access_token, access_secret);

# build query for all screen names in ID list
function  build_screen_names_string(array)
  ids_str = reduce("",array[1:end-1]) do ids_str,x
    ids_str = ids_str*"from:"*string(x)*"+OR+"
  end
  ids_str*"from:"*string(array[end])
end

df = readtable("temp/KPBS_ids_list_San_Diego.csv")
LA_df = readtable("temp/FOXLA_ids_list_Los_Angeles.csv")
append!(df,LA_df)
screen_names = convert(Array,df[2])

# EXAMPLE: tweets = get_search_tweets("from:thuanchau1805+OR+from:dnvnCS653";options = Dict{Any,Any}("count" => "100"))
# The number of tweets to return per page, up to a maximum of 100. Defaults to 15.
texts = []; curr_texts = [];
RTS = []; curr_RTS = [];
retweet_counts = []; curr_retweet_counts = [];
user_ids = []; curr_user_ids = [];
user_mentions = [];curr_user_mentions = [];
in_reply_to_user_ids = []; curr_in_reply_to_user_ids = [];
hashtags = [];curr_hashtags = [];
favorite_counts = [];curr_favorite_counts = [];
created_ats = [];curr_created_ats = [];
urls = [];curr_urls = [];
medias = [];curr_medias = [];

function parse_info(array)
  str = reduce("",array[1:end-1]) do str, x
    str*x["id_str"]*","
  end
  if length(array) > 1
    str = str*array[end]["id_str"]
  elseif length(array) == 1
    str = array[end]["id_str"]
  end
  str
end

# For every 20 screen names in list, we make a request to get their tweets.
# For every batch of tweets, we get from the 20 screen names, we extract the
# tweets attributes.
counter = 0;
for i = 1:20:length(screen_names)
  length_arr = length(screen_names)-i>=19? 19:length(screen_names)-i
  curr_screen_names = screen_names[i:i+length_arr]
  query_string = build_screen_names_string(curr_screen_names)
  print(i,"   ",i+length_arr,"\n")

  max_id = string(typemax(Int64))
  while (max_id != "0" )
    tweets = get_search_tweets(query_string;options = Dict{Any,Any}("count" => "100","lang" =>"en","until" => curr_date,"max_id"=>max_id))
    # Extract attributes
    curr_texts = map(x->x.text, tweets); texts = vcat(texts,curr_texts);
    # 1 if "RT" in messsage
    curr_retweet_counts = map(x->x.retweet_count, tweets); retweet_counts = vcat(retweet_counts,curr_retweet_counts);
    curr_user_ids = map(x->x.user["id"], tweets); user_ids = vcat(user_ids,curr_user_ids);
    curr_user_mentions = map(x->parse_info(x.entities["user_mentions"]), tweets); user_mentions = vcat(user_mentions,curr_user_mentions);
    curr_in_reply_to_user_ids = map(x->x.in_reply_to_user_id_str,tweets); in_reply_to_user_ids = vcat(in_reply_to_user_ids ,curr_in_reply_to_user_ids );
    curr_hashtags = map(x->length(x.entities["hashtags"]), tweets); hashtags = vcat(hashtags,curr_hashtags);
    curr_favorite_counts = map(x->x.favorite_count, tweets); favorite_counts = vcat(favorite_counts,curr_favorite_counts);
    curr_created_ats = map(x->x.created_at, tweets); created_ats = vcat(created_ats,curr_created_ats);
    #curr_urls = map(x->parse_info(x.entities["urls"]), tweets); urls = vcat(urls,curr_urls);
    curr_medias = map(x->try length(x.entities["media"]) catch 0 end, tweets); medias = vcat(medias,curr_medias);
    # Exit condition
    if length(tweets)!= 100 || length(tweets) == 0
      max_id = "0"
    else
      max_id = string(tweets[length(tweets)].id - 1)
    end
    sleep(5)
  end   # while
end   # for

# Store collected attributes of each tweet as a data frame
new_df = DataFrame(user_id = user_ids, text = texts,
  retweet_count = retweet_counts, user_mention = user_mentions, in_reply_to_user_id = in_reply_to_user_ids,
  hashtag = hashtags, favorites_count = favorite_counts, created_at = created_ats, media = medias)

# Save data frame to .csv file
if ~isdir("Data"); mkdir("Data"); end
writetable("Data/"*curr_date*".csv",new_df)
