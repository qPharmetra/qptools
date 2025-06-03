
# ROXYGEN Documentation
#' Logit transformation
#' @description Logit-transforms any value between 0 and 1
#' @param x any value
#' @param min lower boundary of backtransformed value
#' @param max upper boundary of backtransformed value
#' @return Logit-transformed x
#' @export
#' @family basic
#' @examples
#' myVector = runif(n = 1000, min = 0.001,max = 0.999)
#' myVector.logit = logit(myVector)
#' par(mfrow = c(1,3))
#' hist(myVector)
#' hist(myVector.logit)
#' hist(logit_inv(myVector.logit))

logit <- function(x, min = 0, max = 1)
{
  xnew = (x - min) / (max-min)
  log(xnew/(1-xnew))
}

