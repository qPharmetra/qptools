#' Convert Character to Numeric with NA Substitution
#'
#' Converts character to numeric with NA substitution.
#' @param x A vector of character representations of numbers.
#' @param missing.code A string in \code{x} that signifies missing values that should be represented as NA.
#' @return A numeric vector with NA in place of \code{missing.code} .
#' @export
#' @family basic
#' @examples
#' as.numeric(c("3.45","1000","1e6","<BLOQ","NA","<0.100"))
#' asNumeric(c("3.45","1000","1e6","<BLOQ","NA","<0.100"))
#' asNumeric(c("3.45","1000","1e6","<BLOQ","NA","<0.100"), missing.code = c("<BLOQ","NA","<0.100"))

asNumeric <- function(x, missing.code = c("NA"))
{
  # as.numeric function returning NA for isNumeric == F and numeric for isNumeric == T
  x[x %in% missing.code] = NA
  return(as.numeric(x))
}

