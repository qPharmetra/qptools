#' Logit Back-transformation
#'
#' Backtransforms logit transformed data to the <0,1> scale
#' @param x any value
#' @param min lower boundary of backtransformed value
#' @param max upper boundary of backtransformed value
#' @return logit(x) backtransformed to <0,1>
#' @export
#' @family basic
#' @examples
#' myVector = runif(n = 1000, min = 0.001,max = 0.999)
#' myVector.logit = logit(myVector)
#' par(mfrow = c(1,3))
#' hist(myVector)
#' hist(myVector.logit)
#' hist(logit_inv(myVector.logit))

logit_inv <- function(x, min = 0, max = 1)
{
  xnew = exp(x)
  return(min+(max-min) * xnew/(1+xnew))
}

