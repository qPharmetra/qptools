
# ROXYGEN Documentation
#' Fixed character length of a String
#' @description Format string of fixed character length
#' @param x string to format
#' @param pattern format to adhere to
#' @return x reformatted according to pattern
#' @export
#' @family basic
#' @examples
#' fxs(c(0,1,34, 50000), pattern = "    ")
#' fxs(c(0,1,34, 50000), "000000")


fxs <- function(x, pattern = "0000")
{
  newString = rep("NA", length(x))
  pattern = rep(pattern, length(x))

  ## check if pattern and input length are OK
  for (idx in 1:length(x))
  {
    if (nchar(x[idx]) > nchar(pattern[idx]))
      pattern[idx] = paste(substring(pattern[idx], 1, 1), nchar(x[idx]), collapse = "")

    ##create the new string
    newString[idx] = paste(substring(pattern[idx], 1, (nchar(pattern[idx]) -
                                                         nchar(x[idx]))), as.character(x[idx]), sep = "")
  }
  return(newString)
}
