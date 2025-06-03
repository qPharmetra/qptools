# ROXYGEN Documentation
#' Check for missing values
#' @description Create a concentration prediction for a 1 compartment open model with first order absorption
#' @param dose value for dose level
#' @param tob numeric vector describing time of observation
#' @param parms numeric vector consisting of clearance, volume of distribution and absorption rate constant (in this order). The vector might be named but this is not required.
#' @return A numeric vector of concentration predictions
#' @export
#' @family modelpred
#' @examples
#' pk_1comp_1abs(dose=1000,tob=seq(0,48,1),parms=c(3,10,0.05))

pk_1comp_1abs <- function(dose, tob, parms) {
  cl = parms[1]
  v = parms[2]
  ka = parms[3]
  kel = cl/v
  return((tob > 0) * dose * ka/v/(ka - kel) * (exp(-kel *
                                                     tob) - exp(-ka * tob)))
}
