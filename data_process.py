import pandas as pd
import numpy as np

infile_path = "FinalProject/OnlineNewsPopularity/OnlineNewsPopularity.csv"
outfile_path = "FinalProject/processed_data_16.csv"

# df_full = pd.read_csv(infile_path, sep = r'\s*,\s*', nrows = 100)
df_full = pd.read_csv(infile_path, sep = r'\s*,\s*')
# print(df_full.head())
# see what the headers look like
print(df_full.columns.tolist())

# new_df = df_full[['num_hrefs', 'num_imgs', 'num_videos', 'num_keywords', 'is_weekend', 
#                   'global_rate_positive_words', 'title_subjectivity', 'shares']] # 8 attributes

new_df = df_full[['url', 'n_tokens_title', 'n_tokens_content', 'num_hrefs', 'num_self_hrefs', 'num_imgs', 
                'num_videos', 'num_keywords', 'kw_max_avg', 'kw_avg_avg', 'self_reference_min_shares', 
                'is_weekend', 'global_subjectivity', 'global_rate_positive_words', 'title_subjectivity', 
                'title_sentiment_polarity', 'shares']] # 16 attributes

# new_df = df_full[['url', 'n_tokens_title', 'n_tokens_content', 'n_unique_tokens', 'n_non_stop_words', 
#                 'n_non_stop_unique_tokens', 'num_hrefs', 'num_self_hrefs', 'num_imgs', 'num_videos', 
#                 'average_token_length', 'num_keywords', 'kw_min_min', 'kw_max_min', 'kw_avg_min', 
#                 'kw_min_max', 'kw_max_max', 'kw_avg_max', 'kw_min_avg', 'kw_max_avg', 'kw_avg_avg', 
#                 'self_reference_min_shares', 'self_reference_max_shares', 'self_reference_avg_sharess', 
#                 'is_weekend', 'LDA_00', 'LDA_01', 'LDA_02', 'LDA_03', 'LDA_04', 'global_subjectivity', 
#                 'global_sentiment_polarity', 'global_rate_positive_words', 'global_rate_negative_words', 
#                 'rate_positive_words', 'rate_negative_words', 'avg_positive_polarity', 'min_positive_polarity', 
#                 'max_positive_polarity', 'avg_negative_polarity', 'min_negative_polarity', 'max_negative_polarity',
#                  'title_subjectivity', 'title_sentiment_polarity', 'abs_title_subjectivity', 
#                  'abs_title_sentiment_polarity', 'shares']] # 46 attributes; amost all attributes

# Convert one-hot encoding back to categorical entries
channel_df = df_full[['data_channel_is_lifestyle', 
                      'data_channel_is_entertainment', 
                      'data_channel_is_bus', 
                      'data_channel_is_socmed', 
                      'data_channel_is_tech', 
                      'data_channel_is_world']]
# print(channel_df.head())
channel_df.columns = ['lifestyle', 'entertainment', 'business', 'social_media', 'tech', 'world']
# channels = pd.Series(['lifestyle', 'entertainment', 'business', 'social_media', 'tech', 'world'])
channel_col = channel_df.idxmax(axis = 1)
print(channel_col)
# print(type(channel_col))

new_df = new_df.assign(channel = channel_col)
new_df.insert(7, 'channel', new_df.pop('channel')) # change the order of column 'channel'
print(new_df.head())

# Check if there's any missing value
print(new_df.isnull().sum())

# From dataframe to csv
new_df.to_csv(outfile_path, sep = '\t')