## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = FALSE, eval = TRUE)

## ----echo = TRUE--------------------------------------------------------------
library(qptools) 
library(magrittr)
library(yamlet)
library(ggplot2)
x <- 'extdata/modeling/xanomeline-mod.csv.gz' %>% system.file(package = 'yamlet') %>% io_csv %>% filter(cp > 1) %>% resolve

## ----DV-IPRED-ACTARM-VISIT, echo = TRUE, fig.width = 9.69, fig.height = 4.3, fig.cap = 'DV-IPRED-ACTARM-VISIT.png'----
#(
  x %>%
  ggplot(aes(IPRED, DV, color = ACTARM, pch = ACTARM)) + 
    geom_point(alpha = .5, size = 1.5) +
    scale_shape_manual(values = c(1,3))+
    facet_wrap(~VISIT, ncol = 3) +
  theme_bw() +
  theme(aspect.ratio = 1, legend.position = 'top', legend.title = element_blank()) +
  geom_abline(aes(slope = 1, intercept = 0))
  #) %>% devsize(3,3,verbose = T)

## ----DV-PRED, fig.width = 3.65, fig.height = 3.52, fig.cap = "x %>% isoplot(PRED, DV)"----
x %>% isoplot(PRED,DV)

## ----DV-PRED-LOG, fig.width = 3.65, fig.height = 3.52, fig.cap = "x %>% isoplot(PRED, DV, transform = 'log10')"----
x %>% isoplot(PRED, DV, transform = 'log10')

## ----DV-PRED-DV-IPRED, fig.width = 7.3, fig.height = 3.52, fig.cap = "x %>% isopair(PRED, DV, IPRED)"----
x %>% isopair(PRED, DV, IPRED)

## ----DV-IPRED-DV-IPRED-notrans-log, fig.width = 7.3, fig.height = 3.52, fig.cap = "x %>% isopair(IPRED, DV, transform = c('identity','log10'))"----
x %>% isopair(IPRED, DV, transform = c('identity','log10'))

## ----IWRES-TIME, fig.width = 3.65, fig.height = 3.52, fig.cap = "x %>% trendplot(TIME, IWRES)"----
x %>% trendplot(TIME, IWRES) #%>% devsize(3,3,verbose = T)

## ----IWRES-TIME-IWRES-TIME-untrans-log, fig.width = 7.3, fig.height = 3.52, fig.cap = "x %>% trendpair(TIME, IWRES, transform_x = c('identity', 'log10'))"----
x %>% trendpair(TIME, IWRES, transform_x = c('identity', 'log10'))

