# name:     geomean
# purpose:  computes geometic mean on inout
# input:    numeric vector
# output:   numeric vector
# note:

# ROXYGEN Documentation
#' Geometric Mean
#' @param x numeric value
#' @param na.rm logical (default to TRUE) to omit NA entries
#' @return Geometric mean of vector x
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


