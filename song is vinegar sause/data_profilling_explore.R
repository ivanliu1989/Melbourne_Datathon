setwd('C:/Users/InfoCentric/desktop/datathon/datathon full dataset')
library(sqldf)
library(data.table)
library(gdata)
library(rpart)
library(rpart.plot)
library(randomForest)
data1 <- read.csv('Datathon WC Data Games 1-10.csv', sep=',', header =T)
data2 <- read.csv('Datathon WC Data Games 11-20.csv', sep=',', header =T)
data3 <- read.csv('Datathon WC Data Games 21-30.csv', sep=',', header =T)
data4 <- read.csv('Datathon WC Data Games 31-40.csv', sep=',', header =T)
data_final <- read.csv('Datathon WC Data Games QTR Finals.csv', sep=',', header =T)

trans <- rbind(data1, data2,data3,data4, data_final)
names(trans)[1] <- 'BET_ID'
rm(data1)
rm(data2)
rm(data3)
rm(data4)
rm(data_final)


# trim the space for character(factor) variables
dt <- lapply(trans, function(x) { if (!is.numeric(x) )trim(x) else x })
dt <- data.frame(dt)
dt <- data.table(dt)

## list the number of distinct values for each colmns
lapply(dt, function(x) {length(unique(x))})

# construct match, unmatch column for transactions
dt[, MATCHED_BET := ifelse(!is.na(MATCH_BET_ID), 'Yes','No')]
dt$MATCHED_BET <- as.factor(dt$MATCHED_BET)
names(dt)


# Fix the Profit Loss calculations
dt$FIX_PROFI_LOSS <- 0
  
dt[!is.na(PROFIT_LOSS), FIX_PROFI_LOSS := 
       ifelse(BID_TYP == 'B', ifelse(PROFIT_LOSS >0, BET_SIZE*(PRICE_TAKEN - 1), -BET_SIZE), 
                              ifelse(PROFIT_LOSS >0, BET_SIZE, -BET_SIZE*(PRICE_TAKEN - 1 )) )] 

# investigate distribution of BET_PRICE, the price customer offer; BET_SIZE, the unit of win or loss
# as long tail distribution, it maybe reasonable to separate big bet(largest 5% BET_SIZE and BET_PRICE)
# to analyse
# based event, notice BET_PROICE varies a lot through differnt event 
event <- unique(dt$EVENT_ID)

for(i in 1:length(event)){
    size_pct <- quantile(dt[EVENT_ID == event[i]]$BET_SIZE, probs=0.95)
    hist(dt[EVENT_ID == event[i]][BET_SIZE <= size_pct]$BET_SIZE, breaks = 200)
    print(size_pct)
    readline('next')
}


for(i in 1:length(event)){
    price_pct <- quantile(dt[EVENT_ID == event[i]]$BET_PRICE, probs=0.98)
    hist(dt[EVENT_ID == event[i]][BET_PRICE <= price_pct]$BET_PRICE, breaks = 200)
    print(size_90)
    readline('next')
}

major_trans <- dt[1,]
# select the majority bets
for(i in 1:length(event)){
    price_pct <- quantile(dt[EVENT_ID == event[i]]$BET_PRICE, probs=0.95)
    major_trans <- rbind( major_trans, dt[EVENT_ID == event[i]][BET_PRICE <= price_pct])

}
major_trans <- major_trans[-1,]


##### divide dataset to investigate #########
# separate transactions into inplay bet and before play bet
dt_in_play<- major_trans[INPLAY_BET=='Y']
dt_prior_play <- major_trans[INPLAY_BET=='N']

# seperate Back and Lay bet, 
dt_in_play_b <- dt_in_play[BID_TYP=='B']
dt_in_play_l<- dt_in_play[BID_TYP=='L']
dt_prior_play_b <- dt_prior_play[BID_TYP=='B']
dt_prior_play_l<- dt_prior_play[BID_TYP=='L']

nrow(dt_in_play_b) + nrow(dt_in_play_l) +nrow(dt_prior_play_b) +nrow(dt_prior_play_l)
sum(dt_in_play_b$MATCHED_BET =='No') + sum(dt_in_play_l$MATCHED_BET =='No') 
   +sum(dt_prior_play_b$MATCHED_BET =='No') +sum(dt_prior_play_l$MATCHED_BET =='No')

# can see all he in play bet are matched
sum(is.na(dt[INPLAY_BET=='Y']$MATCH_BET_ID))



# how bet can be matched
fit_b <- rpart(MATCHED_BET~ BET_PRICE
                          +BET_SIZE
                          +EVENT_ID
                          +COUNTRY_OF_RESIDENCE_NAME
                         , data=dt_prior_play, na.action = na.omit)

fit_l <- rpart(MATCHED_BET~ BET_PRICE
               +BET_SIZE
               +EVENT_ID
               +COUNTRY_OF_RESIDENCE_NAME
               , data=dt_prior_play, na.action = na.omit)

plot(fit_l)
text(fit_l)

# BET_PRICE, BET_SIZE changing through PLACED_DATE ??



# Matched trans features
matched_trans <- dt[!is.na(MATCH_BET_ID)]
matched_trans <- matched_trans[STATUS_ID !='V']
unmatched_trans <- dt[is.na(MATCH_BET_ID)]


# check the total porift by event
profit <- matched_trans[, list(sum_profit = sum(PROFIT_LOSS)), by= EVENT_ID]

# check the transactions based on event
trans_cnt <-  sqldf("select EVENT_ID, count(*) from dt group by EVENT_ID")

