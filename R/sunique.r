

# ROXYGEN Documentation
#' Unique values sorted
#' @description Derive the unique values in a vector and sort the result
#' @param x values to be uniqued and sorted
#' @return Sorted unique values in vector \code{x}
#' @export
#' @note This function is different from \code{sort(unique(x))} which omits any NAs in the result. \code{sunique}
#' @family basic
#' @examples
#' sunique(round(100*runif(100)))
sunique <- function(x) unique(x)[order(unique(x))]
