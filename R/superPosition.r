
# ROXYGEN Documentation
#' Superposition of concentration-time profiles
#' @description Superposition of concentration-time profiles.
#' @param val numeric vector
#' @param time sorted numeric vector (positive values only)
#' @param tau time interval between two doses
#' @return numeric vector with super positioned results
#' @export
#' @examples
#' pPK = superPosition(15*exp(-0.15*seq(0,84)), time = seq(0,84), tau = 8)
#' plot(seq(0,84), pPK, type = 'l')

superPosition <- function(val, time, tau)
{
  len = ceiling(max(time)/tau)
  newval = matrix(NA, nrow = length(val), ncol = len)
  for(i in 1 : len)
  {
    xlen = time > tau * (i - 1)
    xnlen = time <= tau * (i - 1)
    newval[, i] = c(rep(0, length(which(xnlen))), val[1 : (length(val)-length(which(xnlen)))])
  }
  return(rowSums(newval))
}

