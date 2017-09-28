workspace();
using Twitter
using DataFrames

# Create a temporary and output folder
if ~isdir("temp"); mkdir("temp"); end
if ~isdir("Output"); mkdir("Output"); end

GET_FOLLOWERS_LIMIT = 15
# NOTE: This is where you will enter your own access token/secret and consumer
# key/secret from your Twitter App you have created.
access_token = "786644044008988673-ZoxtvT9CUVgUKRQF8pheoeIrDaFvif8";
access_secret = "2vXAqehb4WITv3Jz7SQop4T73CQ6hCKgYzeF3dBWGeGlC";
consumer_key = "ZljUwi4O6zXmGTtOnClV60INn";
consumer_secret = "yqwfkrPv92QsP8AG6oNzo2uYIzXx9l26aWTlHxv4zHClt9DiQA";
twitterauth(consumer_key, consumer_secret, access_token, access_secret);

function build_get_followers_ids_query(screen_name::AbstractString, cursor::Int64)
  cursor_str = string(cursor)
  Dict{Any,Any}("screen_name" => screen_name,"cursor" => cursor_str)
end

# Apply the collectIDS program on Twitter Account "FOXLA"
screen_name = "FOXLA"
include("Tools/collectIDS.jl")
writetable("temp/FOXLA_ids_list.csv",df)
# Apply the collectIDS program on Twitter Account "KPBS"
screen_name = "KPBS"
include("Tools/collectIDS.jl")
writetable("temp/KPBS_ids_list.csv",df)
