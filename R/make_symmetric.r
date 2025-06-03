# name:     make.symmetric
# purpose:  create symmetrical matrix of lower or upper traingle of a matrix
# input:    vector of cumsum(ncol(matrix)), optional "upper" or "lower"
# output:   symmetrical matrix
# note:

# ROXYGEN Documentation
#' Create symmetrical matrix
#' @description Create symmetrical matrix of lower or upper traingle of a matrix
#' @param values vector of length cumsum(ncol(matrix))
#' @param triangle defaulting to 'upper', can also take the value 'lower'
#' @return A matrix of dimension ncol x ncol
#' @export
#' @family basic
#' @examples
#'   make_symmetric(c(0.12,
#'                    0.02,1.02,
#'                    0.23,-0.3,0.23))
make_symmetric <- function(values, triangle = "upper"){
  # Values specify row-wise lower triangle or column-wise upper triangle
  # Note:
  #   if length of values isn't triangular, specifically the nth triangular number,
  #   it will fill completely the largest matrix it can and throw the warning
  #   "number of items to replace is not a multiple of replacement length"
  if(!is.element(triangle, c( "upper", "lower"))){
    message("triangle must be 'lower' or 'upper'."); return()
  }
  .nth <- floor((sqrt(8*length(values) + 1) - 1) / 2)
  .matrix <- matrix(0, .nth, .nth)
  if(triangle == "upper") .matrix[upper.tri(.matrix, diag = TRUE)] <- values else {
    .matrix[lower.tri(.matrix, diag = TRUE)] <- values}
  .matrix <- .matrix + t(.matrix) - diag(diag(.matrix))
  .matrix
}


