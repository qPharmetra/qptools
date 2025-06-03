#' Apply a Box-Cox Transformation to a Vector
#' 
#' Applies a Box-Cox transformation to a vector.
#' @param shape shape parameter
#' @param distr the distribution
#' @return Box-Cox tranformation of \code{distr} with \code{shape}.
#' @export
#' @examples
#' x = rnorm(1000, mean = 0, sd = 0.25)
#' x.boxcox.pos = boxcoxf(0.5,x)
#' x.boxcox.neg = boxcoxf(-3.5,x)
#' par(mfrow = c(1,3))
#' hist(x)
#' hist(x.boxcox.pos)
#' hist(x.boxcox.neg)
boxcoxf <- function(shape, distr){
  exp((exp(distr)**shape-1)/shape)
}
