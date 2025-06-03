#' Geometric Coefficient of Variation
#' @param x presumed log-normally distributed values
#' @param na.rm logical: set TRUE to omit NA entries
#' @return geometric coefficient of variation (not percent)
#' @export
#' @importFrom stats var
#' @family basic
#' @examples
#' set.seed(1234)
#' x = rlnorm(1000)
#' mean(x)
#' geomean(x)
#' geocv(x)

geocv = function(x, na.rm = FALSE)
{ 
   if(na.rm) x = x[!is.na(x)]
   sqrt(exp(var(log(x))) - 1)
}
