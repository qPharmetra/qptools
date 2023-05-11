
# ROXYGEN Documentation
#' Check for numeric values
#' @description Take a vector and return a vector of boolean values indicating which input
#       vector values would return a numeric result when evaluated with \code{as.numeric()}
#' @param x Placehoder for parameter description
#' @return Placeholder for return description
#' @export
#' @family basic
#' @examples
#' isNumeric(12)
#' isNumeric("x")
#' isNumeric(c(1,2,3,"b",5,6))

isNumeric <- function(x){
  # Identify which members of a character vector will translate to numeric mode
  # return a logical vector with true values corresponding to matches
  numsel = grepl("[0-9]", x)
  charsel = grepl("[A-Za-z]", x) & !grepl("[eE]+[+-]+", x)
  gtltsel = grepl("[<>=]", x)
  return((numsel & !charsel & !gtltsel))
}

