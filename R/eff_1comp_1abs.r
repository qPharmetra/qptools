# ROXYGEN Documentation
#' Check for missing values
#' @description Create a effect predictions for an effect compartment model based on a 1 compartment open model with first order absorption
#' @param dose value for dose level
#' @param tob numeric vector describing time of observation
#' @param parms numeric vector consisting of clearance cl, volume of distribution v, absorption rate constant ka, and effect compartment rate constant keo (in this order). The vector might be named but this is not required.
#' @return A numeric vector of concentration predictions
#' @export
#' @family modelpred
#' @examples
#' eff_1comp_1abs(dose=1000,tob=seq(0,48,1),parms=c(3,10,0.05))

eff_1comp_1abs <- function(dose, tob, parms) {
  cl = parms[1]
  v = parms[2]
  ka = parms[3]
  keo = parms[4]
  kel = cl/v
  A = 1/(kel - ka)/(keo - ka)
  B = 1/(ka - kel)/(keo - kel)
  C = 1/(ka - keo)/(kel - keo)
  dose * ka * keo/v * (A * exp(-ka * tob) + B * exp(-kel * tob) + C * exp(-keo * tob))
}
