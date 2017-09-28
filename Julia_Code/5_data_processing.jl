workspace()
using DataFrames

NUMBER_OF_DAYS_PER_FILE = 9
IDS_LIST_FILE_NAME_SD = "temp/KPBS_ids_list_San_Diego.csv"
IDS_LIST_FILE_NAME_LA = "temp/FOXLA_ids_list_Los_Angeles.csv"
DATA_DIR= "Data/"
PROFILE_DIR = "Output/"
PROFILE_FILE_NAME = PROFILE_DIR*"profile.csv"

SD_list_df = readtable(IDS_LIST_FILE_NAME_SD)
LA_list_df = readtable(IDS_LIST_FILE_NAME_LA)
list_df = append!(SD_list_df,LA_list_df)

function parse_user_mentions(str)
  if str == "" return [] end
  str_arr = split(str,",")
  map(x -> parse(Int,x), str_arr)
end


fileArr = readdir(DATA_DIR)
filename_string = map(x -> DATA_DIR*x,fileArr)

#return 1 for weekend, 0 for weekday
function weekend_or_weekday(created_at_str)
  date = created_at_str[1:3]
  date=="Sat" || date == "Sun" ? 1:0
end

function assignTime(text,work_index)
  t=parse(Int64,text[12:13])
  if work_index == 0
    return 8<=t<=17 ? 1:0
  elseif work_index == 1
    return 18<=t<=23 ? 1:0
  else
    return 0<=t<=7 ? 1:0
  end
end

function isRT(str)
  length(str) <= 2? 0: str[1:2] == "RT"? 1:0
end


profile_df = DataFrame(user_id = [],
  count = [],
  rt = [],
  weekend = [],
  weekday = [],
  hours_work = [],
  hours_off_work = [],
  hours_sleep = [],
  hashtag = [],
  favorites_count = [],
  media = [],
  user_mentions = [] )

new_df = DataFrame()
#data processing
for file in filename_string
  df = readtable(file)
  count = ones(Int,nrow(df)) #all value is 1

  weekend_or_weekday_col = map(x ->weekend_or_weekday(x), df[:created_at])
  weekend_or_weekday_col = map(x ->weekend_or_weekday(x), df[:created_at])
  weekend = map(x -> x == 0? 1:0, weekend_or_weekday_col)
  weekday = map(x -> x == 1? 1:0, weekend_or_weekday_col)

  hours_work = map(x->assignTime(x,0),df[:created_at])
  hours_off_work = map(x->assignTime(x,1),df[:created_at])
  hours_sleep = map(x->assignTime(x,2),df[:created_at])

  rt = map(x -> isRT(x), df[:text])

  user_mentions = map(x -> length(parse_user_mentions(x)), df[:user_mention])

  #new dataframe to put to aggregate
  new_df = DataFrame(user_id = df[:user_id],
    count = count,
    rt = rt,
    weekend = weekend,
    weekday = weekday,
    hours_work = hours_work,
    hours_off_work = hours_off_work,
    hours_sleep = hours_sleep,
    hashtag = df[:hashtag],
    favorites_count = df[:favorites_count],
    media = df[:media],
    user_mentions = user_mentions)
  #CURRENT profile_df
  cur_profile_df = aggregate(new_df, :user_id, sum)
  #rename
  profile_df_name = names(profile_df)
  names!(cur_profile_df,profile_df_name)

  #cur profile + profile
  profile_df = vcat(profile_df,cur_profile_df)
end

#generate raw profile data
raw_profile_df = aggregate(profile_df, :user_id, sum)
profile_df_name = names(profile_df)
names!(raw_profile_df,profile_df_name)


#data processing to final profile DataFrame, write to csv
number_of_days = NUMBER_OF_DAYS_PER_FILE * length(filename_string)
number_of_weeks = number_of_days/7
function attributes_per_tweets(number_of_tweets, attributes)
  num_tweets = map(x -> max(x, 1), number_of_tweets)
  convert(Array{Float64},attributes ./ num_tweets)
end

#length(find(raw_profile_df[:count] .== 0))
tweets_per_day = raw_profile_df[:count] ./ number_of_days
# rt_per_tweet = attributes_per_tweets(raw_profile_df[:count], raw_profile_df[:rt])
rt_per_day = raw_profile_df[:rt] ./ number_of_days
# weekend_per_tweet = attributes_per_tweets(raw_profile_df[:count], raw_profile_df[:weekend])
tweets_during_weekend_per_week = raw_profile_df[:weekend] ./ number_of_weeks
# weekday_per_tweet = attributes_per_tweets(raw_profile_df[:count], raw_profile_df[:weekday])\
tweets_during_weekday_per_week = raw_profile_df[:weekday] ./ number_of_weeks
# work_per_tweet = attributes_per_tweets(raw_profile_df[:count], raw_profile_df[:hours_work])
tweets_during_work_per_week = raw_profile_df[:hours_work] ./ number_of_weeks
# off_work_per_tweet = attributes_per_tweets(raw_profile_df[:count], raw_profile_df[:hours_off_work])
tweets_during_off_work_per_week = raw_profile_df[:hours_off_work] ./ number_of_weeks
# sleep_per_tweet = attributes_per_tweets(raw_profile_df[:count], raw_profile_df[:hours_sleep])
tweets_during_hours_sleep_per_week = raw_profile_df[:hours_sleep] ./ number_of_weeks

hashtag_per_tweet = attributes_per_tweets(raw_profile_df[:count], raw_profile_df[:hashtag])
favorites_per_tweet = attributes_per_tweets(raw_profile_df[:count], raw_profile_df[:favorites_count])
media_per_tweet = attributes_per_tweets(raw_profile_df[:count], raw_profile_df[:media])
mentions_per_tweet = attributes_per_tweets(raw_profile_df[:count], raw_profile_df[:user_mentions])

final_profile_df = DataFrame(
  user_id = raw_profile_df[:user_id],
  tweets_per_day = tweets_per_day,
  rt_per_day = rt_per_day,
  tweets_during_weekday_per_week = tweets_during_weekday_per_week,
  tweets_during_weekend_per_week = tweets_during_weekend_per_week,
  tweets_during_work_per_week = tweets_during_work_per_week,
  tweets_during_off_work_per_week = tweets_during_off_work_per_week,
  tweets_during_hours_sleep_per_week = tweets_during_hours_sleep_per_week,
  hashtag_per_tweet = hashtag_per_tweet,
  favorites_per_tweet = favorites_per_tweet,
  media_per_tweet = media_per_tweet,
  mentions_per_tweet = mentions_per_tweet
  )


lookup_user_id_index_dict = reduce(Dict{Int,Int}(), 1:nrow(list_df)) do df, x
  df[list_df[x,:user_id]] = x
  df
end


#process screen_name and other
screen_name = map(x -> list_df[lookup_user_id_index_dict[x],:screen_name], raw_profile_df[:user_id])
location = map(x -> list_df[lookup_user_id_index_dict[x],:location], raw_profile_df[:user_id])
followers_count = map(x -> list_df[lookup_user_id_index_dict[x],:followers_count], raw_profile_df[:user_id])
followers_count = convert(Array{Int},followers_count)
friends_count = map(x -> list_df[lookup_user_id_index_dict[x],:friends_count], raw_profile_df[:user_id])
friends_count = convert(Array{Int},friends_count)

#add screen_name, followers_count and friends_count
final_profile_df[:friends_count] = friends_count
final_profile_df[:followers_count] = followers_count
final_profile_df[:screen_name] = screen_name
#add location
location[find(x-> match(Regex("\W*(San Diego)\W*"),x) != nothing, location)] = "SD"
location[find(x-> match(Regex("\W*(Los Angeles)\W*"),x) != nothing, location)] = "LA"
final_profile_df[:location] = location

if ~isdir("Output") mkdir("Output"); end
writetable(PROFILE_FILE_NAME,final_profile_df)
