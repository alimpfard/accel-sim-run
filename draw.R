library(purrr)
library(dplyr)
library(reshape2)
library(ggplot2)
library(scales)

setwd("/windata/research/results")

clamp_to_limit <- function(x) {
    ifelse(x < 2, x, '2 or more')
}

data <- read.csv('all') %>%
    na.exclude %>%
    map(clamp_to_limit)

t <- data %>% 
    melt %>%
    group_by(L1, value) %>%
    tally %>%
    mutate(f = n/sum(n))

p <- ggplot(t, aes(x=value, y=n, fill=value)) +
    geom_bar(position="stack", stat="identity") +
    geom_text(aes(label=scales::percent(f)), vjust=.5)+
    labs(x="Number of reads while live", y="#Occurences", fill="#Reads while live")+
    facet_grid(L1~.)
p
