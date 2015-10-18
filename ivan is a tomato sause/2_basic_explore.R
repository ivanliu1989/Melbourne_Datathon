setwd('/Users/ivanliu/Google Drive/Melbourne Datathon/Melbourne_Datathon')
rm(list=ls()); gc()
load('../Datathon_Full_Dataset/Datathon_WC_Data_Complete.RData')

#############
### Check ###
#############
head(dt); attach(dt)

# 1. Profit & Loss
sum(PROFIT_LOSS[PROFIT_LOSS>0], na.rm = T)
sum(PROFIT_LOSS[PROFIT_LOSS<0], na.rm = T)

hist(log10(BET_SIZE), breaks = 100, col = 'red')
hist(log10(BET_PRICE), breaks = 100, col = 'red')
hist(log10(PRICE_TAKEN), breaks = 100, col = 'red')

b <- dt[BET_ID == '4755948997',]
l <- dt[MATCH_BET_ID == '4755948997',]
sum(l$PROFIT_LOSS, na.rm=T)
sum(b$PROFIT_LOSS, na.rm=T)


##############
### Points ###
##############
mean(is.na(SETTLED_DATE))
hist(EVENT_OFF_SEC, breaks = 100, col = 'red')
hist(EVENT_SETTLED_MIN, breaks = 100, col = 'red')
hist(OFF_SETTLED_MIN, breaks = 100, col = 'red')

require(ggplot2)
ggplot(data=dt, aes(dt$PLACED_WKD)) + 
    geom_histogram(breaks=seq(20, 50, by =2), 
                   col="red", 
                   aes(fill=..count..))



