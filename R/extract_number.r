# ROXYGEN Documentation
#' Takes character string and parses the numeric input from it, if available.
#' @section Notes:
#' If multiple blocks of numeric input exist wthin the input, only the first is parsed
#' @param x A character or numeric string.
#' @return A numeric vector if the input has multiple character blocks.
#' @export
#' @family basic
#' @examples
#' extract_number("c76")
#' extract_number("c76c7")
#' extract_number("BLOQ = 0.144")
#' extract_number("6.023+23")
#' stopifnot(extract_number("6.1973+01") == 61.973)
#' extract_number(c('7e1', '7e+1', '7E-1'))
#' extract_number(c('-7e1', '+7e+1', '-7E-1'))
#' extract_number('E7')

extract_number <- function(x)
{
  x = as.character(x)
  # 2025-06-30 TTB
  # shrinkage in the form 6.1973+01 is not recognized by as.numeric
  x <- sub('(\\d)([+-]\\d+).*$','\\1E\\2', x)
  w1 = regexpr("[+-]?[0-9.]+(?:[eE][+-]?\\d+)?", x)
  as.numeric(substring(x, w1, w1 + attr(w1, "match.length")-1))
}
