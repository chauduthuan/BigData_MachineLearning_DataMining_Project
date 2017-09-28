function binary_table = quantize_columns(profile_table)
    %reading each column
    tweets_per_day = profile_table.tweets_per_day;
    rt_per_day = profile_table.rt_per_day;
    tweets_during_weekday_per_week = profile_table.tweets_during_weekday_per_week;
    tweets_during_weekend_per_week = profile_table.tweets_during_weekend_per_week;
    tweets_during_work_per_week = profile_table.tweets_during_work_per_week;
    tweets_during_off_work_per_week = profile_table.tweets_during_off_work_per_week;
    tweets_during_hours_sleep_per_week = profile_table.tweets_during_hours_sleep_per_week;
    hashtag_per_tweet = profile_table.hashtag_per_tweet;
    favorites_per_tweet = profile_table.favorites_per_tweet;
    mentions_per_tweet = profile_table.mentions_per_tweet;
    friends_count = profile_table.friends_count;
    followers_count = profile_table.followers_count;


    %DEFINE ALL THRESHOLD
    tweets_per_day_thres = median(tweets_per_day);
    rt_per_day_thres = median(rt_per_day);
    tweets_during_weekday_per_week_thres = median(tweets_during_weekday_per_week);
    tweets_during_weekend_per_week_thres = median(tweets_during_weekend_per_week);
    tweets_during_work_per_week_thres = median(tweets_during_work_per_week);
    tweets_during_off_work_per_week_thres = median(tweets_during_off_work_per_week);
    tweets_during_hours_sleep_per_week_thres = median(tweets_during_hours_sleep_per_week);
    hashtag_per_tweet_thres = median(hashtag_per_tweet);
    favorites_per_tweet_thres = median(favorites_per_tweet);
    mentions_per_tweet_thres = median(mentions_per_tweet);
    friends_count_thres = median(friends_count);
    followers_count_thres = median(followers_count);

    %binary column
    tweets_per_day_low = tweets_per_day < tweets_per_day_thres;
    tweets_per_day_high = 1-tweets_per_day_low;

    rt_per_day_low = rt_per_day < rt_per_day_thres;
    rt_per_day_high = 1 - rt_per_day_low;

    tweets_during_weekday_per_week_low = tweets_during_weekday_per_week < tweets_during_weekday_per_week_thres;
    tweets_during_weekday_per_week_high = 1 - tweets_during_weekday_per_week_low;

    tweets_during_weekend_per_week_low = tweets_during_weekend_per_week < tweets_during_weekend_per_week_thres;
    tweets_during_weekend_per_week_high = 1 - tweets_during_weekend_per_week_low;

    tweets_during_work_per_week_low = tweets_during_work_per_week < tweets_during_work_per_week_thres;
    tweets_during_work_per_week_high = 1 - tweets_during_work_per_week_low;

    tweets_during_off_work_per_week_low = tweets_during_off_work_per_week < tweets_during_off_work_per_week_thres;
    tweets_during_off_work_per_week_high = 1 - tweets_during_off_work_per_week_low;

    tweets_during_hours_sleep_per_week_low = tweets_during_hours_sleep_per_week < tweets_during_hours_sleep_per_week_thres;
    tweets_during_hours_sleep_per_week_high = 1 - tweets_during_hours_sleep_per_week_low;

    hashtag_per_tweet_low = hashtag_per_tweet < hashtag_per_tweet_thres;
    hashtag_per_tweet_high = 1 - hashtag_per_tweet_low;

    favorites_per_tweet_low = favorites_per_tweet < favorites_per_tweet_thres;
    favorites_per_tweet_high = 1 - favorites_per_tweet_low;

    mentions_per_tweet_low = mentions_per_tweet < mentions_per_tweet_thres;
    mentions_per_tweet_high = 1 - mentions_per_tweet_low;

    friends_count_low = friends_count < friends_count_thres;
    friends_count_high = 1 - friends_count_low;

    followers_count_low = followers_count < followers_count_thres;
    followers_count_high = 1 - followers_count_low;


    %create tables
    binary_table = table(tweets_per_day_low,tweets_per_day_high,...
        rt_per_day_low,rt_per_day_high,...
        tweets_during_weekday_per_week_low, tweets_during_weekday_per_week_high,...
        tweets_during_weekend_per_week_low, tweets_during_weekend_per_week_high,...
        tweets_during_work_per_week_low, tweets_during_work_per_week_high,...
        tweets_during_off_work_per_week_low, tweets_during_off_work_per_week_high,...
        tweets_during_hours_sleep_per_week_low, tweets_during_hours_sleep_per_week_high,...
        hashtag_per_tweet_low, hashtag_per_tweet_high,...
        favorites_per_tweet_low, favorites_per_tweet_high,...
        mentions_per_tweet_low, mentions_per_tweet_high,...
        friends_count_low, friends_count_high,...
        followers_count_low, followers_count_high);
    

end