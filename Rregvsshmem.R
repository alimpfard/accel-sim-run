library(ggplot2)
setwd("/windata/research/run")
stats<-read.delim("regfile-vs-shmem-access.xsv", header=FALSE, sep=" ")
df <- rbind(
  data.frame(L1=stats$V1, variable="shmem", value=stats$V3, label=sprintf("%0.2f%%", stats$V3/stats$V2*100)),
  data.frame(L1=stats$V1, variable="register", value=stats$V2, label=""))

bp <- ggplot(df, aes(x=factor(variable), y=value, fill=variable)) +
  geom_bar(stat = 'identity') +
  geom_text(aes(label=label), vjust=-0.5) +
  facet_wrap(~ L1, scales = "free_y") +
  labs(x="category", y="number of accesses to resource")
ggsave("register_vs_shmem_count.pdf")

