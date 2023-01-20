### Group 5 Final Project ###
## Modeling ##

## Library
library(tidyverse)
library("dplyr")

## Data processing
full_df = read_tsv("processed_data_16.csv")  # Delimiter: "\t"
# head(full_df)

line = 1400

full_df = full_df %>% mutate(popular = ifelse(shares > line, "yes", "no")) %>%
                      mutate(popular = as.factor(popular)) %>%
                      mutate(channel = as.factor(channel)) %>%
                      select(-c(...1, url))
# full_df = full_df[1:1000, ]
head(full_df)
num_df <- select_if(full_df, is.numeric)
# summary(full_df)
# See the distribution of popular/unpopular
full_df %>% group_by(popular) %>% summarize(count = n())

# train/test split
split = sort(sample(nrow(full_df), nrow(full_df)*.7))
train = full_df[split, ]
test = full_df[-split, ]
train_num = select_if(train, is.numeric)
test_num = select_if(test, is.numeric)

## Model 1 - Logistic Regression

# Create a logistic model
# news_logit <- glm(popular ~ ., data = train, family = "binomial")
# summary(news_logit)

# Odds
# exp(coef(news_logit))


## Model 2 - Multiple linear regression (MLR)
multi_lm <- lm(shares ~., data = num_df)
summary(multi_lm)
# sigma(multi_lm)/mean(num_df$shares)
multi_lm <- step(multi_lm, trace = FALSE)
summary(multi_lm)

# Model 3 - Decision tree
library(rpart)
library(rpart.plot)
library(caret)
train_tree = train %>% select(-shares) # shares cannot be an attribute in tree-based models
test_tree = test %>% select(-shares)

# Train the model
full_tree <- rpart(popular ~., data = train_tree, method = "class")
rpart.plot(full_tree, type = 5) # 5-Show the split variable name in the interior nodes.
full_tree$variable.importance

# Perform testing
predict_tree <- predict(full_tree, test_tree, type = "class")

# Performance
confusionMatrix(predict_tree, test_tree$popular)



## Model 4 - Random Forest
# library(randomForest)
# 
# rf = randomForest(popular ~., data = train_tree, importance = TRUE)
# rf
# pred <- predict(rf, test_tree)
# confusionMatrix(pred, test_tree$popular)
# 
# t <- tuneRF(train[ ,-18], train[ ,18],
#             stepFactor = 0.5,
#             plot = TRUE,
#             ntreeTry = 150,
#             trace = TRUE,
#             improve = 0.05)

# varImpPlot(rf,
#            sort = T,
#            n.var = 10,
#            main = "Top 10 - Variable Importance")
# importance(rf)


## Model 5 - K-means clustering
# set.seed(1)
# library(clustertend)
# # Prepare a new dataframe that only contains numeric variables
# num_df <- select_if(full_df, is.numeric) # select only numeric variables
# num_df <- num_df[1:1000, ]
# head(num_df)
# 
# # Scale data
# scaled_num <- scale(num_df)
# 
# # Hopkins statistic
# # hopkins(scaled_num)
# 
# # Find the optimal number of clusters
# library(factoextra)
# library(NbClust)
# 
# fviz_nbclust(scaled_num, kmeans, method = "wss") +
#   geom_vline(xintercept = 5, linetype = 2) + # add line for better visualisation
#   labs(subtitle = "Elbow method") # add subtitle

# Perform K-means


