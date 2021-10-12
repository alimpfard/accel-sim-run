library(ggplot2)
library(rjson)
library(purrr)
library(reshape2)
setwd("/windata/research/run")
melted <- melt(map(fromJSON(paste(readLines("power-results.json"), collapse="")), data.frame))
melted$cat = ''
melted[seq(1, nrow(melted), 3),]$cat = 'with'
melted[seq(2, nrow(melted), 3),]$cat = 'with1'
melted[seq(3, nrow(melted), 3),]$cat = 'without'
bp <- ggplot(melted, aes(x=factor(cat, levels=c("with", "with1", "without")), y=value, fill=variable)) +
      geom_bar(stat = 'identity', position='stack') +
      facet_wrap(~ L1, scales = "free_y") # + theme(legend.position = "none")
ggsave("power.pdf")
