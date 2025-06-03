# ROXYGEN Documentation
#' Create an example PKPD Dataset
#' @description Create a data set with concentration predictions and (effect compartment) predictions for a 1 compartment open model with first order absorption
#' @param dose value for dose level
#' @param tob numeric vector describing time of observation
#' @param params numeric vector consisting of clearance, volume of distribution and absorption rate constant (in this order). The vector might be named but this is not required.
#' @param nsub number of subjects to simulate
#' @param seed seed for sampling
#' @param age numeric vector of length four to populate a normal age distribution with mean (1), SD (2), minimum (3) and maximum (4)
#' @param wt numeric vector of length four to populate a normal weight distribution with mean (1), SD (2), minimum (3) and maximum (4)
#' @return A data.frame with concentration and effect predictions
#' @export
#' @importFrom stats median
#' @importFrom tidyr as_tibble
#' @family example
#' @examples
#' library(magrittr)
#' library(dplyr)
#' library(ggplot2)
#' pkpd_df = example_pkpd_data()
#' #pkpd_df %>% wrangle::enumerate(trt,endpoint,type,dose)
#' pkpd_df %<>% group_by(id) 
#' pkpd_df %<>% mutate(conc = 
#'    pk_1comp_1abs(tob=time,dose=dose,parms = c(cl,v,ka)))
#' pkpd_df %<>% mutate(ceff = 
#'    eff_1comp_1abs(tob=time,dose=dose,parms = c(cl=cl,v=v,ka=ka,keo=keo)))
#'pkpd_df %>%
#'   filter(dose>0&time>0&time<12) %>%
#'   ggplot(aes(x=time,y=conc,group=as.factor(id))) + 
#'   geom_line() + 
#'   facet_grid(~dose) +
#'   scale_y_log10()     

example_pkpd_data = function(dose = c(0, 100, 250, 500),
                             age = c(mid=50,sd=10, min=18,max=85),
                             wt = c(mid=75,sd=10, min=0, max=140),
                             seed = 1234,
                             nsub = 32,
                             tob = c(0, 1, 2, 3, 4, 5, 6, 7, 10, 14, 21, 28, 35, 42),
                             params = c(3,10,0.05,0.01))
{
  set.seed(seed)
  pkpdData = list(NULL)

  for (i in 1:length(dose))
    pkpdData[[i]] = expand.grid(id = paste(dose[i],
                                           1:nsub), dose = dose[i])
  pkpdData = do.call("rbind", pkpdData)
  pkpdData$id = as.integer(as.factor(pkpdData$id))
  lunique(pkpdData$id)
  pkpdData$age = round(rnorm_by_id(pkpdData$id, mean = age[1], sd = age[2]), 0)
  pkpdData$age[pkpdData$age < age[3]] = age[3]
  pkpdData$age[pkpdData$age > age[4]] = age[4]
  pkpdData$wt = round(rnorm_by_id(pkpdData$id, mean = wt[1], sd = wt[2]), 0)
  pkpdData$wt[pkpdData$age < wt[3]] = wt[3]
  pkpdData$wt[pkpdData$age > wt[4]] = wt[4]
  pkpdData$ht = sample_by_id(pkpdData$id, 158:200, TRUE)
  pkpdData$bmi = round(pkpdData$wt/(pkpdData$ht/100)^2, 1)
  pkpdData$sex = sample_by_id(pkpdData$id, c("M", "F"), TRUE)
  pkpdData$race = sample_by_id(pkpdData$id
                               , rep(c("Caucasian", "Asian", "Black", "Other")
                                     , c(10, 3, 3, 1)), TRUE)
  pkpdData$endpoint = rep("effect", nrow(pkpdData))
  pkpdData$trt = ifelse(pkpdData$dose == 0, "Placebo", paste("drug ", pkpdData$dose, "mg", sep = ""))
  xTime = tob
  nr = nrow(pkpdData)
  pkpdData = pkpdData[rep((1:nrow(pkpdData)), ea = length(xTime)), ]
  pkpdData$time = rep(xTime, nr)
  nr = nrow(pkpdData)
  pkpdData = rbind(pkpdData, pkpdData)
  pkpdData$type = rep(c("PK", "PD"), ea = nr)
  pkpdData$cl = params[1] * ((pkpdData$wt/stats::median(pkpdData$wt))^0.5) *
    exp(rnorm_by_id(pkpdData$id, 0, 0.25))
  pkpdData$v = params[2] * exp(rnorm_by_id(pkpdData$id, 0, 0.25)) +
    (pkpdData$sex == "F") * 5
  pkpdData$keo = params[4] * exp(rnorm_by_id(pkpdData$id, 0, 0.5))
  pkpdData$ka = params[3] * exp(rnorm_by_id(pkpdData$id, 0, 0.1))

  ok = pkpdData$type == "PK"
  pkpdData$value[ok] = unlist(lapply(split(pkpdData[ok,],
                                           pkpdData$id[ok]), function(x)
                                             pk_1comp_1abs(x$dose, x$time,
                                                           parms = c(
                                                             cl = x$cl[1], v = x$v[1], ka = x$ka[1]
                                                           ))))
  pkpdData$value[pkpdData$type == "PK"] = pkpdData$value[pkpdData$type == "PK"] *
    (1 + rnorm(sum(pkpdData$type == "PK"), 0, 0.05)) +
    rnorm(sum(pkpdData$type == "PK"), 0, 0.02)
  pkpdData$value[pkpdData$type == "PK" & pkpdData$value < 0.05] = 0.05

  ok = pkpdData$type == "PD"
  pkpdData$value[ok] = unlist(lapply(split(pkpdData[ok,],
                                           pkpdData$id[ok])
                                     , function(x)
                                       1 + eff_1comp_1abs(x$dose,
                                                          x$time, parms = c(
                                                            cl = x$cl[1],
                                                            v = x$v[1],
                                                            ka = x$ka[1],
                                                            keo = x$keo[1]
                                                          ))))
  return(pkpdData %>% as_tibble)
}
