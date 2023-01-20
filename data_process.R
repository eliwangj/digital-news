### Group 5 Final Project ###
## Data pre-processing

library(tidyverse)
library("dplyr")


### Data processing ###

# Define summarize_numeric function from homework 2 
summarize_numeric = function(dataset) {
  
  dataset = select_if(dataset, is.numeric)
  summary.table = data.frame(Attribute = names(dataset))
  
  summary.table = summary.table %>% 
    mutate('Missing Values' = apply(dataset, 2, function (x) sum(is.na(x))),
           'Unique Values' = apply(dataset, 2, function (x) length(unique(x))),
           # 'Total Values' = apply(dataset, 2, function(x) length(x)),
           'Mean' = colMeans(dataset, na.rm = TRUE),
           'Min' = apply(dataset, 2, function (x) min(x, na.rm = TRUE)),
           'Max' = apply(dataset, 2, function (x) max(x, na.rm = TRUE)),
           'SD' = apply(dataset, 2, function (x) sd(x, na.rm = TRUE))
    )
  summary.table
}

#  Define summarize_character function
summarize_factor = function(dataset) {
  
  dataset = select_if(dataset, is.factor)
  summary.table = data.frame(Attribute = names(dataset))
  
  summary.table = summary.table %>% 
    mutate('Missing Values' = apply(dataset, 2, function (x) sum(is.na(x))),
           'Unique Values' = apply(dataset, 2, function (x) length(unique(x))),
           'Mode' = apply(dataset, 2, function (x) mode(x))
    )
  summary.table
}

# Read the dataset
full_df = read_tsv("processed_data_46.csv")  # Delimiter: "\t"
# head(full_df)

# Set a threshold
line = 1400

# Add popular; Factor conversion
full_df = full_df %>% mutate(popular = ifelse(shares > line, "yes", "no")) %>%
  mutate(popular = as.factor(popular)) %>%
  mutate(channel = as.factor(channel)) %>%
  mutate(is_weekend = as.factor(is_weekend)) %>%
  rename(self_reference_avg_shares = self_reference_avg_sharess) %>% # correct the name
  select(-...1)

colnames(full_df)

# Select our interested attributes
selected_df = full_df %>% select(kw_avg_avg, num_hrefs,
                                 self_reference_avg_shares,
                                 n_tokens_content,
                                 num_keywords,
                                 num_self_hrefs,
                                 average_token_length,
                                 global_subjectivity,
                                 num_imgs,
                                 title_sentiment_polarity,
                                 global_rate_positive_words,
                                 channel,
                                 is_weekend,
                                 shares,
                                 popular)
                                 
# colnames(selected_df)
# length(colnames(selected_df))

# Summary of the selected attributes
summarize_numeric(selected_df)

# Remove those with n_tokens_content == 0
selected_df %>% filter(n_tokens_content == 0) %>% summarize(count = n()) # see how many are there
selected_df = selected_df %>% filter(n_tokens_content > 0)

# Final summaries
summarize_numeric(selected_df)
summarize_factor(selected_df)

# Take log value
selected_df = selected_df %>% mutate(shares = log(shares))


# train/test split
split = sort(sample(nrow(selected_df), nrow(selected_df)*.7))
train = selected_df[split, ]
test = selected_df[-split, ]
train_num = select_if(train, is.numeric)
test_num = select_if(test, is.numeric)

# Random Forest
train_tree = train %>% select(-shares) # shares cannot be an attribute in tree-based models
test_tree = test %>% select(-shares)

library(randomForest)
library(caret)

rf = randomForest(popular ~., data = train_tree, importance = TRUE)
rf
pred <- predict(rf, test_tree)
confusionMatrix(pred, test_tree$popular)

# t <- tuneRF(train[ ,-18], train[ ,18],
#             stepFactor = 0.5,
#             plot = TRUE,
#             ntreeTry = 150,
#             trace = TRUE,
#             improve = 0.05)

varImpPlot(rf,
           sort = T,
           n.var = 10,
           main = "Top 10 - Variable Importance")
importance(rf)