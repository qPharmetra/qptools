# ROXYGEN Dodata:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAWElEQVR42mNgGPTAxsZmJsVqQApgmGw1yApwKcQiT7phRBuCzzCSDSHGMKINIeDNmWQlA2IigKJwIssQkHdINgxfmBBtGDEBS3KCxBc7pMQgMYE5c/AXPwAwSX4lV3pTWwAAAABJRU5ErkJggg==cumentation
#' Extract character information from a string
#' @description Takes character string and parses the character input from it, if available
#' @param x A character or numeric string.
#' @param collapse A boolean, should the character vector returned by collapsed (see \code{\link[base]{paste}}).
#' @return A character string or vector if the input has multiple character blocks.
#' @export
#' @family basic
#' @examples
#' extract_character(x = "df12Lee31df")
#' extract_character(x = "df1231df", TRUE)

extract_character <- function(x, collapse = FALSE)
{
  x = as.character(x)
  w1 = gregexpr("[A-Z]?[a-z]*", x)
  x = substring(x, unlist(w1), unlist(w1) + attr(w1[[1]], "match.length")-1)
  x = if(collapse == FALSE) x[x != ""] else paste(x[x != ""], collapse = "")
  return(x)
}
