
# ROXYGEN Documentation
#' Last Observation Carried Forward (LOCF)
#' @description Derive Last Observation Carried Forward (LOCF). Preserves factors as well.
#' @param x Placehoder for parameter description
#' @param na code for missing values to be LOCF-ed
#' @return Placeholder for return description
#' @family basic
#' @export
#' @examples
#' locf(c(NA,NA,1,NA,NA,2,NA,NA,NA,NA,3))
#' # Note that initial missing values take next value (1),
#' # so next value carried backward at beginning
#' # Example with "."
#' locf(c(".",".",1,".",".",2,".",".",".",".",3), na = ".")
#' # Note, if you have text in the vector, it is all converted to text.
#' # This is by design so we can use different types.
#' # Examples with factors
#' fac = as.factor(c(".",".","A",".",".","B",".",".",".",".","C"))
#' locf(fac,na = ".")
#' fac = as.factor(c(NA,NA,"A",NA,NA,"B",NA,NA,NA,NA,"C"))
#' locf(fac,na = NA)


locf <- function(x, na = NA)
{
  is.fac = class(x) == "factor"
  if(is.fac) x = as.character(x)
  #replace in x, whatever is na (maybe text value like ".") with last non na value
  if(!is.na(na)) x[x == na]=NA
  Y =!is.na(x)
  x = c(x[Y][1], x[Y])[cumsum(Y)+1]
  if(is.fac) x = as.factor(x)
  x
}
