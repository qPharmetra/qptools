
# ROXYGEN Documentation
#' Number of unique values
#' @description Derive the length (number) of unique values in a vector
#' @param x values to be uniqued
#' @return Number of unique values in vector \code{x}
#' @export
#' @family basic
#' @examples
#' lunique(1:10)
#' lunique(c(1,1,2,2,3,3,4,4))

lunique <- function(x) length(unique(x))

