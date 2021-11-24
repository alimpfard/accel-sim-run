library(ggplot2)
library(rjson)
library(purrr)
library(reshape2)
setwd("/windata/research/run")
vanilla<-read.delim("vanilla", header=FALSE, sep=" ")
reg2mem<-read.delim("reg2mem", header=FALSE, sep=" ")
vanilla$cat = "vanilla"
reg2mem$cat = "reg2mem"
mixed <- rbind(vanilla, reg2mem)
df <- rbind(
  data.frame(L1=mixed$V1, variable="read", value=mixed$V2, cat=mixed$cat),
  data.frame(L1=mixed$V1, variable="write", value=mixed$V3, cat=mixed$cat))

bp <- ggplot(df, aes(x=factor(cat), y=value, fill=variable)) +
  geom_bar(stat = 'identity', position='stack') +
  facet_wrap(~ L1, scales = "free_y") +
  labs(x="category")
ggsave("power.pdf")

