#' Format Real with Enforced Significant Digits
#' 
#' Formats real number, enforcing printed number of significant digits.
#' In contrast, \code{as.character(signif())} drops trailing zeros.
#' 
#' 
#' @param x a vector of values to be processed into significant digits format
#' @param digits single value specifying the number of significant digits
#' @param latex whether to convert scientific notation to latex equivalent (e -> *10^)
#' @param align.dot whether to decimal-align the result
#' @return A formatted character vector containing \code{x} with significant \code{digits} format
#' @family format
#' @export
# @importFrom Hmisc unPaste
#' @examples
#' library(xtable)
#' formatted_signif(c(5,4.99, 4.99999,5.0000001,5001),4)
#'
#' numvec = c(5,4.99, 4.99999,5.0000001,5001, 0.00005,101,39.9)
#' print(
#'    xtable(
#'       data.frame(
#'           original = numvec
#'          ,latex.TRUE = formatted_signif(numvec,3, TRUE,FALSE)
#'          ,align.TRUE = formatted_signif(numvec,3, FALSE,TRUE)
#'          ,all.TRUE = formatted_signif(numvec,3, TRUE,TRUE)
#'       )
#'    )
#'    , booktabs = TRUE
#'    , sanitize.text.function = identity
#' )
#' # now take this to a LaTeX compiler!


formatted_signif <- function(x, digits = 3, latex = FALSE, align.dot = FALSE){
  res = vector(length = length(x))
  for(i in 1:length(x))
  {
    res[i] = sprintf(paste0("%#.",digits,"g"), signif(x[i],digits))
    if(substring(res[i],nchar(res[i])) == ".") res[i] = substring(res[i],1,(nchar(res[i])-1)) ## remove trailing dot
  }
  if(latex) for(i in 1:length(x))
  {
    if(grepl("e", res[i])){
      tmp = unPaste(res[i], sep = "e")
      res[i] = paste0(tmp[[1]],"$\\cdot$10$^{", as.numeric(tmp[[2]]),"}$")
    }
  }
  if(align.dot&latex){
    res = align_around_decimal_point(res)
  }
  return(res)
}

