library(tidyverse)

#channel F Statistic
data46 = read_tsv("processed_data_46.csv")
channel46 = data46 %>% select(channel, shares)
channel46$channel = as.factor(channel46$channel)
channel46 %>% group_by(channel) %>% summarize(Count = n(), avg_shares = mean(shares), std =sd(shares))
library(lmPerm)
summary(aov(shares ~ channel, data = channel46))

#Trouble
summary(aovp(shares ~ channel, data = channel46))


#weekend perm
weekend46 = data46 %>% select(is_weekend, shares)
weekend46 = weekend46 %>% mutate(`is_weekend` = as.factor(
  case_when(
    `is_weekend` == 1 ~ 'weekend',
    `is_weekend` == 0 ~ 'workday')
)
)
weekend_stat = weekend46 %>% group_by(is_weekend)%>% summarize(Count = n(), avg_shares = mean(shares), std =sd(shares))
ggplot(weekend46, aes(x = is_weekend, y = shares)) + geom_boxplot()
t.test(shares ~ is_weekend, data = weekend46, alternative = 'less')
perm_fun <- function(x, nA){
  n = length(x)
  nB = n - nA
  idx_b <- sample(1:n, nB)
  idx_a <- setdiff(1:n, idx_b)
  perm_diffs <- mean(x[idx_b]) - mean(x[idx_a])
  return(perm_diffs)
}
weekend_count = weekend46 %>% group_by(is_weekend)%>% summarize(Count = n())
perm_diffs = rep(0, 10000)
for(i in 1:10000){
  perm_diffs[i] = perm_fun(weekend46$shares, weekend_count$Count[1])
}
head(perm_diffs)
mean_diff = weekend_stat$avg_shares[2] - weekend_stat$avg_shares[1]
head(perm_diffs > mean_diff)
mean(perm_diffs > mean_diff)
ggplot(as_tibble(perm_diffs))+ geom_histogram(aes(x= value))+labs(title = "shares differences")+geom_vline(xintercept = mean_diff, linetype = "dashed", size = 0.8)+geom_text(aes(x=mean_diff, label = "\nobserved difference"), y =700, angle = 90)

#pca
data16 = read_tsv("processed_data_16.csv")
data16 = data16[,-1]
pca_shares_rating = prcomp(data16 %>% select(-channel, -is_weekend, -shares), center = TRUE, scale = TRUE)
summary(pca_shares_rating)
plot(pca_shares_rating, type = 'l')

#efa
library(nFactors)
nScree(as.data.frame(data16 %>% select(-channel, -is_weekend, -shares)))
factanal(data16 %>% select(-channel, -is_weekend, -shares), factors = 3)
