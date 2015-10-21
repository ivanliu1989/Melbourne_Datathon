load("data/ivan_rfm/SEG_list.RData")
class(dat)
head(dat)
unique(dat$rfm)

require(data.table)
dtSeg <- as.data.table(dat)
dtCluster <- dtAcctClusters[, c("ACCOUNT_ID", "CLUSTER"), with = F]
dtSegCluster <- merge(x = dtSeg
               , y = dtCluster
               , by = "ACCOUNT_ID"
               , all.x = T)

save(dtSegCluster, file = "data/seg_cluster/seg_cluster.RData")
