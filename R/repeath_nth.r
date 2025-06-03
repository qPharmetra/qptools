
# ROXYGEN Documentation
#' Hide repetition of character strings
#' @description Creates a vector in which text is repeated every "nth" item in the result, and in which that text is concatenated with a numeric integer indicating which occurence it represents. Useful for making good-looking, not-too busy Appendix tables of for example observed concentrations  with multiple samples taken at various dose levels and/or various dosing cycles.
#' @param x numeric or character
#' @param before prefix (optional)
#' @param after suffix (optional)
#' @param pos position within the repetition the non-empty character string should appear
#' @param replacement character string to replace the repeated entries (defaults to the empty "")
#' @return Character vector
#' @export
#' @family format
#' @examples
#' ## simplest form
#' repeat_nth(c(1,1,1,1,2,2,2))
#'
#' ## adding a prefix
#' repeat_nth(c(1,1,1,1,2,2,2), before = "CYCLE", pos = 1)
#' repeat_nth(c(1,1,1,1,2,2,2), before = "CYCLE", pos = 2)
#' repeat_nth(c(1,1,1,1,2,2,2), before = "CYCLE", pos = 3)
#'
#' ## addding a suffix
#' repeat_nth(c(1,1,1,1,2,2,2), after = "CYCLE", pos = 1)
#' repeat_nth(c(1,1,1,1,2,2,2), after = "CYCLE", pos = 2)
#' repeat_nth(c(1,1,1,1,2,2,2), after = "CYCLE", pos = 3)
#'
#' ## both
#' repeat_nth(c(1,1,1,1,2,2,2), before = "BI", after = "CYCLE", pos = 1)

repeat_nth =
  function(x, replacement = "", before = "", after = "", pos = 1)
  {
    ## before and after agruments allow to expand on the result, forexample:
    ## repeat.nth(c(1,1,1,1,2,2,2), before = "CYCLE", pos = 1) become:
    ## [1] "CYCLE1" ""       ""       ""       "CYCLE2" ""       ""
    dups = duplicated(x)
    if(pos<1 | pos>length(x)) pos = 1
    nvec = ifelse(dups,replacement, paste(before,x,after, sep = ""))
    if(pos>1){nvec[1] = replacement
              nvec[pos] = paste(before,x,after, sep = "")[1]
    }
    return(nvec)
  }




