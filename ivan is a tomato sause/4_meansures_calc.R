setwd('/Users/ivanliu/Google Drive/Melbourne Datathon/Melbourne_Datathon')
rm(list=ls()); gc()
load('../Datathon_Full_Dataset/Datathon_WC_Data_Complete.RData')

################
### Measures ###
################
# 1. Rate of loss | count(distinct BET_ID) group by ACCOUNT_ID, PROFIT_LOSS (-)
loss_profit <- aggregate(PROFIT_LOSS ~ ACCOUNT_ID, data=dt, sum, na.action = na.omit)
range(loss_profit[,2]); median(loss_profit[,2]); mean(loss_profit[,2])
length(unique(dt$ACCOUNT_ID)); dim(loss_profit)

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