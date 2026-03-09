---
title: Isoplots and Trendplots
author: Tim Bergsma
output: 
  html_document:
    toc: true
    toc_float: true
    code_folding: show
    keep_md : TRUE
    fig.width: 8
    fig.height: 6
    theme: united
    highlight: tango
vignette: >
  %\VignetteIndexEntry{Isoplots and Trendplots}
  %\VignetteEncoding{UTF-8}
  %\VignetteEngine{knitr::rmarkdown}
editor_options: 
  chunk_output_type: console
---



## Objective

In this exercise, we show some simple goodness-of-fit plots using isoplot()
and trendplot(). Admittedly, actual needs could quickly outstrip the flexibility
of these tools. Perhaps the concepts here can serve as a starting point
for further development.

## Data

We read example data from the yamlet package.


``` r
library(qptools) 
library(magrittr)
library(yamlet)
```

```
## 
## Attaching package: 'yamlet'
```

```
## The following object is masked from 'package:stats':
## 
##     filter
```

``` r
library(ggplot2)
x <- 'extdata/modeling/xanomeline-mod.csv.gz' %>% system.file(package = 'yamlet') %>% io_csv %>% filter(cp > 1) %>% resolve
```

## DV vs IPRED by ACTARM per VISIT
 

``` r
#(
  x %>%
  ggplot(aes(IPRED, DV, color = ACTARM, pch = ACTARM)) + 
    geom_point(alpha = .5, size = 1.5) +
    scale_shape_manual(values = c(1,3))+
    facet_wrap(~VISIT, ncol = 3) +
  theme_bw() +
  theme(aspect.ratio = 1, legend.position = 'top', legend.title = element_blank()) +
  geom_abline(aes(slope = 1, intercept = 0))
```

![DV-IPRED-ACTARM-VISIT.png](C:/project/devel/qptools/vignettes/data-diagnostics_files/figure-html/DV-IPRED-ACTARM-VISIT-1.png)

``` r
  #) %>% devsize(3,3,verbose = T)
```

## Observations vs. Individual Predictions
 
![x %>% isoplot(PRED, DV)](C:/project/devel/qptools/vignettes/data-diagnostics_files/figure-html/DV-PRED-1.png)

## DV vs PRED log-log

```
## Warning in transformation$transform(coord_limits): NaNs produced
## Warning in transformation$transform(coord_limits): NaNs produced
```

![x %>% isoplot(PRED, DV, transform = 'log10')](C:/project/devel/qptools/vignettes/data-diagnostics_files/figure-html/DV-PRED-LOG-1.png)

## DV vs PRED and IPRED

![x %>% isopair(PRED, DV, IPRED)](C:/project/devel/qptools/vignettes/data-diagnostics_files/figure-html/DV-PRED-DV-IPRED-1.png)

## DV vs IPRED, untransformed and log-log
 

```
## Warning in transformation$transform(coord_limits): NaNs produced
## Warning in transformation$transform(coord_limits): NaNs produced
```

![x %>% isopair(IPRED, DV, transform = c('identity','log10'))](C:/project/devel/qptools/vignettes/data-diagnostics_files/figure-html/DV-IPRED-DV-IPRED-notrans-log-1.png)

## IWRES vs TIME
 
![x %>% trendplot(TIME, IWRES)](C:/project/devel/qptools/vignettes/data-diagnostics_files/figure-html/IWRES-TIME-1.png)

## IWRES vs TIME, untransformed and log-log
![x %>% trendpair(TIME, IWRES, transform_x = c('identity', 'log10'))](C:/project/devel/qptools/vignettes/data-diagnostics_files/figure-html/IWRES-TIME-IWRES-TIME-untrans-log-1.png)

