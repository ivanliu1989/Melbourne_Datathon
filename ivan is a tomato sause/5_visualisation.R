setwd('/Users/ivanliu/Google Drive/Melbourne Datathon/Melbourne_Datathon')
rm(list=ls()); gc()
load('../Datathon_Full_Dataset/Datathon_WC_Data_Complete.RData')
load('data/ivan_rfm/RFM_all.RData')
ls()

library(googleVis)
dat_all$LAST_DATE <- as.Date(dat_all$LAST_DATE, '%Y-%m-%d')
data_all <- aggregate(ACCOUNT_ID ~ ACCOUNT_ID, data=dt, sum, na.action = na.omit)

dat_all <- dat_all[,-c(2,8:10)]
Motion=gvisMotionChart(data = dat_all[1:100,], idvar="ACCOUNT_ID", timevar="LAST_DATE",
                       xvar='Monetary', yvar='Frequency',
                       sizevar='R_Score', 
                       colorvar="R_Score",  # RFM segments / Country
                       date.format = "%Y-%m-%d",
                       options=list(width=1200, height=600))
plot(Motion)
print(Motion,'chart',file='motionChart.html')
# x: frequency | y: recency | z: monetory

head(dat_all)
range(dat_all$Recency)
summary(dat_all$Frequency)
range(dat_all$Monetary)

hist(dat_all$Frequency, breaks = 100)

head(dt)
