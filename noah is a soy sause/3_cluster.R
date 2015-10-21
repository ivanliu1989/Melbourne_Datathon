rm(list = ls()); gc()
require(data.table)
require(dplyr)
load("../Datathon_Full_Dataset/subsetAcct.RData")
##########################################################################
## 1. model ##############################################################
##########################################################################
str(subsetAcct)
# $ ACCOUNT_ID                   : chr  "1000001" "1000002" "1000003" "1000004" ...
# $ COUNTRY_OF_RESIDENCE_NAME    : chr  "United Kingdom" "United Kingdom" "Australia" "United Kingdom" ...
# $ AVG_NO_OF_TRANS_PER_BET      : num  1 1.14 1.2 1.14 1.15 ...
# $ AVG_NO_OF_BETS_PER_MATCH     : num  1 13.42 1.67 2.33 24.75 ...
# $ TTL_NO_OF_MATCH              : int  1 26 3 12 8 20 3 2 2 24 ...
# $ AVG_EXP_WIN_PER_TRAN         : num  30.6 184.1 12.5 104 213.6 ...
# $ AVG_EXP_LOSS_PER_TRAN        : num  49.4 155.6 28.8 64.3 145.5 ...
# $ AVG_TTL_PROFIT_LOSS_PER_BET  : num  -49.35 3.64 -21 -15.37 -5.32 ...
# $ AVG_TTL_PROFIT_LOSS_PER_MATCH: num  -49.4 48.9 -35 -35.9 -131.7 ...
# $ TTL_RATE_CANCEL              : num  0 0.1436 0 0.0938 0.2335 ...
# $ AVG_RATE_CANCEL_PER_BET      : num  0 0.163 0 0.107 0.268 ...
# $ AVG_RATE_CANCEL_PER_MATCH    : num  0 2.19 0 0.25 6.62 ...
# $ TTL_RATE_WIN                 : num  0 0.411 0.333 0.188 0.366 ...
# $ AVG_RATE_WIN_PER_BET         : num  0 0.467 0.4 0.214 0.419 ...
# $ AVG_RATE_WIN_PER_MATCH       : num  0 6.269 0.667 0.5 10.375 ...
# $ TOP                          : num  0 3 2 2 0 2 2 0 0 1 ...

# filter out some non-sense dimensions
subsetAcct <- subsetAcct[,!c(
    "AVG_EXP_WIN_PER_TRAN"
    , "AVG_EXP_LOSS_PER_TRAN"
    , "AVG_TTL_PROFIT_LOSS_PER_MATCH"
    , "AVG_RATE_CANCEL_PER_BET"
    , "AVG_RATE_CANCEL_PER_MATCH"
    , "TTL_RATE_WIN"
    , "AVG_RATE_WIN_PER_MATCH"
)
, with = F]
str(subsetAcct)
# $ ACCOUNT_ID                 : chr  "1000001" "1000002" "1000003" "1000004" ...
# $ COUNTRY_OF_RESIDENCE_NAME  : chr  "United Kingdom" "United Kingdom" "Australia" "United Kingdom" ...
# $ AVG_NO_OF_TRANS_PER_BET    : num  1 1.14 1.2 1.14 1.15 ...
# $ AVG_NO_OF_BETS_PER_MATCH   : num  1 13.42 1.67 2.33 24.75 ...
# $ TTL_NO_OF_MATCH            : int  1 26 3 12 8 20 3 2 2 24 ...
# $ AVG_EXP_WIN_PER_TRAN       : num  30.6 184.1 12.5 104 213.6 ...
# $ AVG_EXP_LOSS_PER_TRAN      : num  49.4 155.6 28.8 64.3 145.5 ...
# $ AVG_TTL_PROFIT_LOSS_PER_BET: num  -49.35 3.64 -21 -15.37 -5.32 ...
# $ TTL_RATE_CANCEL            : num  0 0.1436 0 0.0938 0.2335 ...
# $ AVG_RATE_WIN_PER_BET       : num  0 0.467 0.4 0.214 0.419 ...
# $ TOP                        : num  0 3 2 2 0 2 2 0 0 1 ...

# standardization
dtAcctScale <- scale(subsetAcct[, c(-1, -2), with = F])
apply(dtAcctScale, 2, class)

dtAcctScale <- as.data.table(dtAcctScale)
dtAcctScale <- cbind(ACCOUNT_ID = subsetAcct$ACCOUNT_ID, dtAcctScale)
dim(dtAcctScale)

# generic function for summarising the clusters
SummariseClusters <- function(dt){
    dtClusters <- dt %>%
        group_by(CLUSTER) %>%
        summarise(
                  # AVG_NO_TRANS_PER_TRANS = mean(TTL_NO_OF_TRANS)
                  NO_OF_TRANS_PER_BET = mean(AVG_NO_OF_TRANS_PER_BET)
                  # , AVG_NO_OF_TRANS_PER_MATCH = mean(AVG_NO_OF_TRANS_PER_MATCH)
                  
                  # , AVG_NO_OF_BETS = mean(TTL_NO_OF_BETS)
                  , NO_OF_BETS_PER_MATCH = mean(AVG_NO_OF_BETS_PER_MATCH)
                  
                  , NO_OF_MATCH = mean(TTL_NO_OF_MATCH)
                  
                  # , AVG_MIN_EXP_WIN = mean(MIN_EXP_WIN)
                  # , AVG_MAX_EXP_WIN = mean(MAX_EXP_WIN)
                  # , AVG_TTL_EXP_WIN = mean(TTL_EXP_WIN)
                  
                  # , EXP_WIN_PER_TRAN = mean(AVG_EXP_WIN_PER_TRAN)
                  # , AVG_EXP_WIN_PER_BET = mean(AVG_EXP_WIN_PER_BET)
                  # , AVG_EXP_WIN_PER_MATCH = mean(AVG_EXP_WIN_PER_MATCH)
                  
                  # , AVG_MIN_EXP_LOSS = mean(MIN_EXP_LOSS)
                  # , AVG_MAX_EXP_LOSS = mean(MAX_EXP_LOSS)
                  # , AVG_TTL_EXP_LOSS = mean(TTL_EXP_LOSS)
                  
                  # , EXP_LOSS_PER_TRAN = mean(AVG_EXP_LOSS_PER_TRAN)
                  # , AVG_EXP_LOSS_PER_BET = mean(AVG_EXP_LOSS_PER_BET)
                  # , AVG_EXP_LOSS_PER_MATCH = mean(AVG_EXP_LOSS_PER_MATCH)
                  
                  # , AVG_PROFIT_LOSS = mean(TTL_PROFIT_LOSS)
                  # , AVG_TTL_PROFIT_LOSS_PER_TRAN = mean(AVG_TTL_PROFIT_LOSS_PER_TRAN)
                  , PROFIT_LOSS_PER_BET = mean(AVG_TTL_PROFIT_LOSS_PER_BET)
                  # , AVG_TTL_PROFIT_LOSS_PER_MATCH = mean(AVG_TTL_PROFIT_LOSS_PER_MATCH)
                  
                  , RATE_CANCEL = mean(TTL_RATE_CANCEL)
                  # , AVG_RATE_CANCEL_PER_BET = mean(AVG_RATE_CANCEL_PER_BET)
                  # , AVG_RATE_CANCEL_PER_MATCH = mean(AVG_RATE_CANCEL_PER_MATCH)
                  
                  # , AVG_RATE_WIN = mean(TTL_RATE_WIN)
                  , RATE_WIN_PER_BET = mean(AVG_RATE_WIN_PER_BET)
                  # , AVG_RATE_WIN_PER_MATCH = mean(AVG_RATE_WIN_PER_MATCH)
                  
                  , TIMES_OF_TOP = mean(TOP)
        )
}
## modelling with Kmeans
KmeansClusters <- function(dt, k = 3, nstart = 50){
    kmAcct.out <- kmeans(dt, k, nstart = 50)
    dtCombined <- cbind(dt, CLUSTER = kmAcct.out$cluster)
    
    dtCombined <- as.data.table(dtCombined)
    # dtClusters <- SummariseClusters(dtCombined)
    
    # return(dtClusters)
    return(dtCombined)
}

## modelling with Hierachical Clustering
HierClusters <- function(dt, k = 2, method){
    hc <- hclust(dist(dt), method = "complete")
    hcAcc.out <- cutree(hc, k)
    dtCombined <- cbind(dt, CLUSTER = hcAcc.out)
    
    dtCombined <- as.data.table(dtCombined)
    dtClusters <- SummariseClusters(dtCombined)
    
    return(dtClusters)
}






