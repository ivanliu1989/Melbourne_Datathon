setwd('/Users/ivanliu/Google Drive/Melbourne Datathon/Melbourne_Datathon')
rm(list=ls()); gc()
load('../Datathon_Full_Dataset/Datathon_WC_Data_Complete.RData')
library(dplyr)

################
### Measures ###
################
# Exclude dates 
dt2 <- tbl_df(dt[, -c(8,9,12:15)])
glimpse(dt2)
distinct(dt2)
# 1. Rate of loss | count(distinct BET_ID) group by ACCOUNT_ID, PROFIT_LOSS (-)
dt2 %>% group_by(ACCOUNT_ID) %>% 
    summarise(bet_num=length(unique(BET_ID)),
              win_num=length(unique(BET_ID[PROFIT_LOSS>0])),
              loss_num=length(unique(BET_ID[PROFIT_LOSS<0])))
# loss_profit <- aggregate(PROFIT_LOSS ~ ACCOUNT_ID, data=dt, sum, na.action = na.omit)

# 2. Prob of profit | count(distinct BET_ID) group by ACCOUNT_ID, PROFIT_LOSS (+)

# 3. Net profit	| sum(PROFIT_LOSS) group by ACCOUNT_ID

# 4. Recency | lastest TRANSACTION_DATE - LAST_DATE

# 5. Frequency | count(distinct TRANSACTION_ID) group by ACCOUNT_ID

# 6. Monetary | average(BET_SIZE * PRICE_TAKEN/BET_PRICE) group by ACCOUNT_ID

# 7. Bet Prices | BET_PRICE / PRICE_TAKEN

# 8. Buy inverval | TAKEN_DATE - PLACED_DATE


##################
### Dimensions ###
##################
# 1. Location
# 2. Event
# 3. Status -> cancel -> reason of cancel (too large bet_size, cstr segments)
# 4. Inplay
# 5. Hour, Month, Weekdays


################
### Segments ###
################
# 1. RFM
# 2. Clustering
# 3. PCA/2-dim scatter plot


#############
### Plots ###
#############