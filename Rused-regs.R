library(ggplot2)

setwd("/windata/research/run")
regs<-read.delim("used-registers.xsv", header=FALSE, sep=" ")
regs <- rbind(
  data.frame(L1=regs$V1, variable="after", value=regs$V3, percent=sprintf("%0.2f%%", (regs$V3/regs$V2)*100)),
  data.frame(L1=regs$V1, variable="before", value=regs$V2, percent="100%")
)

bp <- ggplot(regs, aes(x=factor(variable, levels=c("before", "after")), y=value, fill=variable)) +
  geom_bar(stat = 'identity') +
  geom_text(aes(label=percent), vjust=1.5) +
  facet_wrap(~ L1, scales = "free_y") +
  labs(x="category", y="number of used registers across the entire execution")
ggsave("used_register_count.pdf")

