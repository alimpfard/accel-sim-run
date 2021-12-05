library(ggplot2)
setwd("/windata/research/run")
vanilla<-read.delim("vanilla-total-ipc", header=FALSE, sep=" ")
reg2mem<-read.delim("reg2mem-total-ipc", header=FALSE, sep=" ")
vanilla$cat = "vanilla"
reg2mem$cat = "reg2mem"
reg2mem$percent = sprintf("+%0.2f%%", (reg2mem$V2/vanilla$V2*100 - 100))
vanilla$percent = ''
df <- rbind(vanilla, reg2mem)

bp <- ggplot(df, aes(x=factor(cat, levels=c("vanilla", "reg2mem")), y=V2)) +
  geom_bar(stat = 'identity') +
  geom_text(aes(label=percent), vjust=1.5) +
  facet_wrap(~ V1, scales = "free_y") +
  labs(x="category", y="IPC")
ggsave("ipc-comparison.pdf")

