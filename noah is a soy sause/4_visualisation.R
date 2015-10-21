rm(list = ls()); gc()
require(data.table)
require(reshape)
require(ggplot2)
source("noah is a soy sause/3_cluster.R")
##########################################################################
## 1. visualisation ######################################################
##########################################################################
## 1.1 run the cluster with Kmeans
set.seed(1)
dtAcctClusters <- KmeansClusters(dt = dtAcctScale
                                 , k = 4
                                 , nstart = 50)

dtAcctClusters[, CLUSTER := ifelse(dtAcctClusters$CLUSTER == 1, "a. Strong but Simple"
                                   , ifelse(dtAcctClusters$CLUSTER == 2, "b. Frequent and Careful"
                                            , ifelse(dtAcctClusters$CLUSTER == 3, "c. Fast then Win!"
                                                     , ifelse(dtAcctClusters$CLUSTER == 4, "d. Casual and Bold", "NA")
                                            )
                                   )
)]
dim(dtAcctClusters)

dtClusters <- SummariseClusters(dtAcctClusters)
dtCountClusters <- dtAcctClusters %>%
    group_by(CLUSTER) %>%
    summarise(CNT = n())

dtCountClusters

## 1.2 plot
## melt
dfMeltAcctClusters <- melt(dtClusters, id = 1)
gSummary <- ggplot(dfMeltAcctClusters, aes(x = variable, y = value, fill = factor(CLUSTER))) 
gSummary <- gSummary + geom_bar(stat = "identity")
gSummary <- gSummary + theme_bw()
gSummary <- gSummary + theme(axis.text.x = element_text(angle = 45, hjust = 1)
                             , axis.text.y = element_blank()
                             , plot.title = element_text(lineheight=.8, face="bold")
                             , legend.position="left")
gSummary <- gSummary + guides(fill=guide_legend(title = "Cluster"))
# gSummary <- gSummary + scale_fill_manual("Cluster")
gSummary <- gSummary + xlab("Dimension")
gSummary <- gSummary + ylab("Value")
gSummary <- gSummary + ggtitle("Betor Cluster Profiles")
gSummary <- gSummary + facet_grid(CLUSTER ~.)
gSummary

## 1.3 heatmap
gHeat <- ggplot(dfMeltAcctClusters, aes(x = variable, y = CLUSTER))
gHeat <- gHeat + geom_tile(aes(fill = value))
gHeat <- gHeat + scale_fill_gradient(low = "white", high = "red")
gHeat <- gHeat + theme_bw()
gHeat <- gHeat + xlab("Dimension")
gHeat <- gHeat + ylab("Cluster")
gHeat <- gHeat + ggtitle("Betor Cluster Profiles Heatmap")
gHeat <- gHeat + theme(axis.text.x = element_text(angle = 45, hjust = 1)
                       , plot.title = element_text(lineheight=.8, face="bold")
                       , legend.position="left")
gHeat <- gHeat + guides(fill=guide_legend(title = "Cluster"))
gHeat

## 2.1 run the cluster with Hierachical clustering
set.seed(2)
dtAcctClusters_hc <- HierClusters(dt = dtAcctScale
                               , k = 4
                               , method = "average")

# dtAcctClusters_hc[, CLUSTER]
dfMeltAcctClusters <- melt(dtAcctClusters_hc, id = 1)
gSummary <- ggplot(dfMeltAcctClusters, aes(x = variable, y = value, fill = factor(CLUSTER))) 
gSummary <- gSummary + geom_bar(stat = "identity")
gSummary <- gSummary + theme(axis.text.x = element_text(angle = 45, hjust = 1))
gSummary <- gSummary + facet_grid(CLUSTER ~.)
gSummary