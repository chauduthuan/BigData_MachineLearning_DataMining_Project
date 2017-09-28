workspace()
using TextAnalysis
using DataFrames
using JLD

VOCAB_FILE = "Tools/google-10000-english-usa.txt"

list_df = readtable("temp/KPBS_ids_list_San_Diego.csv")
LA_df = readtable("temp/FOXLA_ids_list_Los_Angeles.csv")
append!(list_df,LA_df)

# build a user id dictionary, key = user id , value = row index in bag of words
user_id_lookup_index_dict = Dict{Int,Int}()
for i = 1:nrow(list_df)
  user_id_lookup_index_dict[list_df[i,:user_id]] = i
end
user_id_lookup_index_dict

#create vocabulary array used as header in bag of words
f = open(VOCAB_FILE);
s = readstring(f)
vocab_arr = unique(split(s))
close(f)

# build a vocab dict, key = word, value = column index in bag of words
vocab_dict = Dict{String,Int}()
index = 1;
for str = vocab_arr
  vocab_dict[str] = index;
  index += 1
end
vocab_dict

DATA_DIR="Data"
fileArr = readdir(DATA_DIR)
filename_string = map(x -> DATA_DIR*x,fileArr)

function text_rebuild(str)
  reduce("",str) do new_str,x
    new_str *= (isascii(x))? string(x):" "
  end
end

SIZE_USER = nrow(list_df)
SIZE_VOCAB = length(vocab_arr)

# For each word in tweet text, increment counter in bag of word
bag_of_word = zeros(Int16,SIZE_USER,SIZE_VOCAB)
for file in filename_string
  df = readtable(file)
  for i = 1:nrow(df)
    user_id = df[i,:user_id]
    user_index = user_id_lookup_index_dict[user_id]
    text = text_rebuild(df[i,:text])
    print(i,"\n")

    sd = StringDocument(text)
    remove_case!(sd)
    remove_articles!(sd)
    remove_indefinite_articles!(sd)
    remove_definite_articles!(sd)
    remove_prepositions!(sd)
    remove_pronouns!(sd)
    remove_stop_words!(sd)
    remove_words!(sd,["a","the","these","those","this","and","in","of","to"])
    str_arr = tokens(sd)

    for str in str_arr
      if haskey(vocab_dict,str)
         vocab_index = vocab_dict[str]
         bag_of_word[user_index, vocab_index] += 1
      end
    end
  end

end

# Create header for bag of words
vocab_arr_name = map(x -> symbol(x),vocab_arr)

# Standarize all "San Diego" labels to "SD" and "Los Angeles" to "LA"
user_id = list_df[:user_id]
location = list_df[:location]
location[find(x-> match(Regex("\W*(San Diego)\W*"),x) != nothing, location)] = "SD"
location[find(x-> match(Regex("\W*(Los Angeles)\W*"),x) != nothing, location)] = "LA"

# find active user
sumrow = map(x -> sum(bag_of_word[x,:]), 1:size(bag_of_word,1))
indexrow = find(sumrow .!= 0)
# find active words
sumcol = map(x -> sum(bag_of_word[:,x]), 1:size(bag_of_word,2))
indexcol = find(sumcol .!= 0)
bag_of_word = bag_of_word[:,indexcol]
vocab_arr_name = vocab_arr_name[indexcol]

column_name = vcat([:user_id;:user_location], vocab_arr_name)

combine_list_bag_of_word_df =  DataFrame()
combine_list_bag_of_word_df[:user_id] = user_id[indexrow]
combine_list_bag_of_word_df[:user_location] = location[indexrow]
for i = 1:size(bag_of_word,2)
  combine_list_bag_of_word_df[vocab_arr_name[i]] = bag_of_word[indexrow,i]
end

sumrow = zeros(Int16,nrow(combine_list_bag_of_word_df))
data = convert(Array{Int16}, combine_list_bag_of_word_df[:,3:end])

# Calculate total word counts for Normalization
for i = 1:nrow(combine_list_bag_of_word_df)
  sumrow[i] = sum(data[i,:])
  print(i , "\n")
end

# Normalize the word counts by the total word counts
for i = 3:ncol(combine_list_bag_of_word_df)
  combine_list_bag_of_word_df[i] = data[:,i-2] ./ sumrow
end

if ~isdir("Output") mkdir("Output"); end
writetable("Output/combine_list_bag_of_word_remove_aux_normalized.csv",combine_list_bag_of_word_df)
