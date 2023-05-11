# ROXYGEN Documentation
#' Geometric Mean Coefficient of Variation in Percent
#' @param x numeric values
#' @param na.rm logical (default to TRUE) to omit NA entries
#' @return Geometric mean of vector x
#' @export
#' @family basic
#' @examples
#' set.seed(1234)
#' x = rlnorm(1000)
#' mean(x)
#' geomean(x)
#' geomean_cv(x)

geomean_cv = function(x, na.rm = FALSE)
{ 
   if(na.rm) x = x[!is.na(x)]
   sqrt(exp(x) - 1)
}