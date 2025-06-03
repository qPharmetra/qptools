#' Geometric Mean
#' @param x presumed log-normally distributed values
#' @param na.rm logical (default to TRUE) to omit NA entries
#' @return Geometric mean of vector x on the original scale
#' @export
#' @family basic
#' @examples
#' set.seed(1234)
#' x = rlnorm(1000)
#' mean(x)
#' geomean(x)
geomean <- function(x, na.rm = FALSE)
{
  if(na.rm) x = x[!is.na(x)]
  exp(mean(log(x)))
}


