library(ggplot2)
setwd("/windata/research/run")
results<-read.delim("register-count-from-maxrregcount0.xsv", header=FALSE, sep=" ")
results$V2 <- strtoi(results$V2)
print(results)
df<-data.frame(L1=results$V1, variable="value", value=(results$V2-results$V3)/results$V2)
df$value.string <- sprintf("%0.2f%%\n%d/%d", df$value*100, results$V2-results$V3, results$V2)

bp <- ggplot(df, aes(x=L1, y=value, fill=variable)) +
  geom_crossbar(width=0.6, aes(ymax=value, ymin=-.25), stat = 'identity', position=position_dodge(width=0.4)) +
  geom_hline(yintercept=0, lwd=0.4, colour='grey50') +
  geom_label(label=df$value.string) +
  # facet_wrap(~ L1, scales = "free_y") +
  scale_y_continuous(limits=c(NA, .5), labels=scales::percent_format()) +
  labs(y="Percentage of PTX registers saved over 'nvcc -maxrregcount=0'")
ggsave("register_count-maxrreg0.pdf")
