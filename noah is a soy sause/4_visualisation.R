rm(list = ls()); gc()
require(data.table)
require(reshape)
require(ggplot2)
source("noah is a soy sause/3_cluster.R")
##########################################################################
## 1. visualisation ######################################################
##########################################################################
## 1.1 run the cluster with Kmeans
dtAcctClusters <- KmeansClusters(dt = dtAcctScale
                                 , k = 3
                                 , nstart = 50)

dtAcctClusters
dim(dtAcctClusters)

## 1.2 plot
## melt
dfMeltAcctClusters <- melt(dtAcctClusters, id = 1)
gSummary <- ggplot(dfMeltAcctClusters, aes(x = variable, y = value, fill = factor(CLUSTER))) 
gSummary <- gSummary + geom_bar(stat = "identity")
gSummary <- gSummary + theme(axis.text.x = element_text(angle = 45, hjust = 1))
gSummary <- gSummary + facet_grid(CLUSTER ~.)
gSummary

## 1.2 run the cluster with Hierachical clustering
dtAcctClusters_hc <- HierClusters(dt = dtAcctScale
                               , k = 4
                               , method = "compelte")

dfMeltAcctClusters <- melt(dtAcctClusters_hc, id = 1)
gSummary <- ggplot(dfMeltAcctClusters, aes(x = variable, y = value, fill = factor(CLUSTER))) 
gSummary <- gSummary + geom_bar(stat = "identity")
gSummary <- gSummary + theme(axis.text.x = element_text(angle = 45, hjust = 1))
gSummary <- gSummary + facet_grid(CLUSTER ~.)
gSummary