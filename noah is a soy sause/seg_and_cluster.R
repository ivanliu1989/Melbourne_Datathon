load("data/ivan_rfm/SEG_list.RData")
class(dat)
head(dat)
unique(dat$rfm)

require(data.table)
dtSeg <- as.data.table(dat)
