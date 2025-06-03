#' Replace Existing set of Values with Another set of Values
#' 
#' Replaces existing set of values with another set of values
#' @param x vector to apply the exchange over
#' @param from (Sorted) vector of unique OLD values
#' @param to (Sorted) vector of unique NEW values
#' @return swapped vector of x
#' @export
#' @keywords internal
#' @family format
#' @examples
#' my.vect = c(1,2,2,2,4,4,4,3,3,3,3,5)
#' swap(my.vect, c(1,2,3,4), c(11,22,33,44))

swap <- function(x, from, to)
{
   stopifnot(anyDuplicated(from) == 0)
   stopifnot(anyDuplicated(to) == 0)
   stopifnot(length(from) == length(to))
    
  pos = match(x, from, 0)
  x[as.logical(pos)] = to[pos]
  return(x)
}

