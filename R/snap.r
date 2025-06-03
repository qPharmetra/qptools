#' Coerce Values to Nearest of Candidates
#'
#' For each value in a numeric vector, return the closest match from a vector of candidate values.
#'
#' If rule is scalar, it must be positive; a rule will be constructed as a sequence of rule-spaced values that includes zero and includes values at least as extreme as the extremes of x. In some sense, this function is the complement to cut: whereas in cut one specifies the "breaks", with snap one specifies a set of "attractors" (breaks are the implied midpoints); both functions map their primary argument to a (possibly) smaller set of values.

#' Note: If length of x is zero, it is returned unmodified. If length of rule is zero, value is all NA.

#' @export
#' @return numeric
#' @param x numeric
#' @param rule a vector of (finite numeric) candidates, or a single value giving candidate interval on the real number line
#' @param left whether to return the lesser of two equidistant candidates
#' @param ... ignored
#' @examples
#' snap(c(0.0, 1.0, 1.2, 2.0, 2.9, 3))
#'snap(-10:10, 0.3)
#' times <- c(0,.25,.5,1,2,4,5,7,9,12,24)
#' snap(c(3,NA,5), c(2,4,6))
#' snap(c(3,NA,5), numeric(0))

snap <- function (x, rule = 1, left = TRUE, ...) 
{
   stopifnot(is.numeric(x), is.numeric(rule), is.finite(rule))
   if (!length(x)) 
      return(x)
   rule <- sort(unique(rule))
   if (length(rule) == 1) {
      stopifnot(rule > 0)
      lo <- min(x, na.rm = TRUE)
      hi <- max(x, na.rm = TRUE)
      lo <- (lo%/%rule) * rule - rule
      hi <- (hi%/%rule) * rule + rule
      rule <- seq(from = lo, to = hi, by = rule)
   }
   lt <- findInterval(x, rule)
   rt <- findInterval(x, rule) + 1
   lt[lt == 0] <- 1
   rt[rt > length(rule)] <- length(rule)
   lt <- rule[lt]
   rt <- rule[rt]
   fun <- match.fun(if (left) 
      "<="
      else "<")
   closer <- ifelse(fun(abs(x - lt), abs(rt - x)), lt, rt)
   closer
}