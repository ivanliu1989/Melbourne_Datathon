rm(list = ls()); gc()
require(scatterplot3d)
load("../Datathon_Full_Dataset/subsetRateAccount_noTail.RData")
load("../Datathon_Full_Dataset/subsetRateLoc.RData")
##########################################################################
## 1. visualisation ######################################################
##########################################################################
## 1.1 ACCOUNT oriented graph
str(subsetRateAccount_noTail)
# $ ACCOUNT_ID               : chr  "1000002" "1000004" "1000005" "1000006" ...
# $ COUNTRY_OF_RESIDENCE_NAME: chr  "United Kingdom" "United Kingdom" "United Kingdom" "Australia" ...
# $ CNT_L                    : int  176 23 74 46 57 63 34 2 5 17 ...
# $ PROFIT_LOSS_L            : num  -90.5 -24.1 -64.2 -12.5 -95.6 ...
# $ CNT_W                    : int  163 6 83 58 29 44 4 11 6 29 ...
# $ PROFIT_LOSS_W            : num  105.5 20.7 44.6 15.3 169.6 ...
# $ WINRATE                  : num  0.481 0.207 0.529 0.558 0.337 ...

## just take a look
hist(subsetRateAccount_noTail$WINRATE) # a very balanced histgram
hist(subsetRateAccount_noTail$PROFIT_LOSS_L + subsetRateAccount_noTail$PROFIT_LOSS_W) # a long head of loss
hist(subsetRateAccount_noTail$CNT_L + subsetRateAccount_noTail$CNT_W) # a long tail of large no. of transactions

# cluster with kmeans
subsetRateAccount_noTailForKmeans <- subsetRateAccount_noTail
subsetRateAccount_noTailForKmeans$CNT_TRANS <- subsetRateAccount_noTailForKmeans$CNT_L + subsetRateAccount_noTailForKmeans$CNT_W
subsetRateAccount_noTailForKmeans$PROFIT_LOSS <- subsetRateAccount_noTailForKmeans$PROFIT_LOSS_L + subsetRateAccount_noTailForKmeans$PROFIT_LOSS_W
subsetRateAccount_noTailForKmeans <- subsetRateAccount_noTailForKmeans[, !c("CNT_L", "CNT_W", "PROFIT_LOSS_L", "PROFIT_LOSS_W"), with = F]
subsetRateAccount_noTailForKmeans <- as.data.table(cbind(ACCOUNT_ID = subsetRateAccount_noTailForKmeans$ACCOUNT_ID, scale(subsetRateAccount_noTailForKmeans[, -c(1, 2), with = F])))

kmAcct.out <- kmeans(subsetRateAccount_noTailForKmeans[, -1, with = F]
                             , 3
                             , nstart = 50)
attach(subsetRateAccount_noTailForKmeans[, -1, with = F])

scatterplot3d(subsetRateAccount_noTailForKmeans$CNT_TRANS
              , y = subsetRateAccount_noTailForKmeans$WINRATE
              , z = subsetRateAccount_noTailForKmeans$PROFIT_LOSS
              , color = kmAcct.out$cluster)

plot(subsetRateAccount_noTailForKmeans$PROFIT_LOSS, subsetRateAccount_noTailForKmeans$WINRATE, col = kmAcct.out$cluster)

## 1.2 LOC oriented graph
str(subsetRateLoc)
# $ COUNTRY_OF_RESIDENCE_NAME: chr  "United Kingdom" "Australia" "Malta" "India" ...
# $ CNT_ACCOUNT              : int  3686 1113 1244 448 579 811 133 1321 10 15 ...
# $ CNT_TRANS_L              : int  388811 57090 138808 30726 191407 155870 4133 248442 1046 1090 ...
# $ CNT_TRANS_W              : int  379408 53681 133294 24912 212364 161389 4874 246165 817 1183 ...
# $ PROFIT_LOSS_L            : num  -530838 -159824 -280696 -30856 -203652 ...
# $ PROFIT_LOSS_W            : num  569546 176694 285856 41052 188122 ...
# $ CNT_TRANS_PER_ACCT       : num  208.4 99.5 218.7 124.2 697.4 ...
# $ PROFIT_LOSS_PER_ACCT     : num  10.5 15.16 4.15 22.76 -26.82 ...
# $ WINRATE                  : num  0.494 0.485 0.49 0.448 0.526 ...

## just take a look
hist(subsetRateLoc$CNT_ACCOUNT) # a long tail of big no. of accounts
hist(subsetRateLoc$WINRATE)

## cluster with kmeans
subsetRateLocForKmeans <- subsetRateLoc
subsetRateLocForKmeans$CNT_TRANS <- subsetRateLocForKmeans$CNT_TRANS_L + subsetRateLocForKmeans$CNT_TRANS_W
subsetRateLocForKmeans$PROFIT_LOSS <- subsetRateLocForKmeans$PROFIT_LOSS_L + subsetRateLocForKmeans$PROFIT_LOSS_W
subsetRateLocForKmeans <- subsetRateLocForKmeans[, !c("CNT_TRANS_L", "CNT_TRANS_W", "PROFIT_LOSS_L", "PROFIT_LOSS_W"), with = F]
subsetRateLocForKmeans <- as.data.table(cbind(COUNTRY_OF_RESIDENCE_NAME = subsetRateLocForKmeans$COUNTRY_OF_RESIDENCE_NAME, scale(subsetRateLocForKmeans[, -1, with = F])))

kmLoc.out <- kmeans(subsetRateLocForKmeans[, -1, with = F]
                             , 3
                             , nstart = 50)

plot(subsetRateLocForKmeans[, c("WINRATE", "CNT_TRANS_PER_ACCT"), with = F]
     , col=(kmLoc.out$cluster)
     , main="K-Means Clustering Results with K = 5", xlab="WINRATE", ylab="CNT_TRANS_PER_ACCT", pch=20, cex=2)

## 






