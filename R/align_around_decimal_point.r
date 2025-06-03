#' Pad Numeric Vector Around Decimal Point
#'
#' Pads a vector of numeric values so that the decimal is at the same ordinal location.
#' @param x A vector of numbers.
#' @param sep The decimal separator.
#' @param len The total character width desired in the formatted field.
#' @return A character vector with members of length \code{len}, with \code{sep} located in the same position
#' of each member.
#' @export
# @importFrom Hmisc unPaste
#' @family padding
#' @examples
#' align_around_decimal_point(c(1,100, 0.01))

align_around_decimal_point  =
  function(x, sep = "\\.", len)
  {
    xx = unlist(lapply(lapply(paste(x), unPaste, sep = sep), function(x)
      x[[1]]))
    if (missing(len))
      len = max(nchar(xx))
    sapply(seq(along = x), function(y, x, yy, len)
      paste(paste(
        "$\\phantom{",
        paste(rep("0", (len - nchar(
          yy[y]
        ))), collapse = ""), "}$", sep = ""
      ),
      x[y], sep = ""), yy = xx, x = x, len = len)
  }

#' Pad Numeric Vector Around Decimal Point
#'
#' Pads a vector of numeric values so that the decimal is at the same ordinal location.
#' @param x A vector of numbers.
#' @param sep The decimal separator.
#' @param len The total character width desired in the formatted field.
#' @return A character vector with members of length \code{len}, with \code{sep} located in the same position
#' of each member.
#' @export
#' @family padding
#' @examples
#' aadp(c(1,100, 0.01))

aadp = align_around_decimal_point

