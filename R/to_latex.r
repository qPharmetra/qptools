#' Convert to Latex
#' 
#' Converts something to latex. Generic, with method \code{\link{to_latex.nms_nonmem}}.
#' 
#' @export
#' @family latex
#' @param x object of dispatch
#' @param ... passed arguments
#' @examples
#' library(magrittr)
#' library(dplyr)
#' library(knitr)
#' library(yamlet)
#' options(nmDir = getOption("qpExampleDir"))
#' "run103" %>% 
#'   nm_params_table %>% 
#'   lol %>%
#'   format %>%
#'   to_latex
to_latex <- function(x, ...)UseMethod('to_latex')

#' Convert Anything to Latex
#' 
#' Converts anything to latex.
#' By default, does nothing!
#' This lets us avoid unintentional coversions.
#' 
#' @param x anything
#' @param ... ignored
#' @family latex
#' @export
#' 
to_latex.default <- function(x, ...)x

#' Convert Dataframe to Latex
#' 
#' Converts 'data.frame' to latex.
#' Iterates across columns, calling to_latex().
#'
#' @param x data.frame
#' @param ... ignored
#' @family latex
#' @export
#' @examples
#' to_latex(Theoph)
#' 
to_latex.data.frame <- function(x, ...){
   x %<>% mutate(across(everything(), to_latex))
   x
}

#' Convert Nonmem Names to Latex
#' 
#' Converts nms_nonmem to latex. 
#' Expects THETA(1), OMEGA(2,2), SIGMA(1,1) etc.
#' 
#' @export
#' @family latex
#' @param x nms_nonmem
#' @param ... ignored arguments
to_latex.nms_nonmem <- function(x, ...){
   y <- as.character(x)
   # Format THETA parameters: THETA1 becomes \theta_{1}
   y <- gsub("THETA(\\d+)", "\\\\theta_\\{\\1\\}", y)
   # Format SIGMA: SIGMA(1,1) becomes \sigma_{1,1}^2
   y <- gsub("SIGMA\\((\\d+),(\\d+)\\)", "\\\\sigma_\\{\\1,\\2\\}^2", y)
   # Format OMEGA: OMEGA(1,1) becomes \omega_{1,1}^2
   y <- gsub("OMEGA\\((\\d+),(\\d+)\\)", "\\\\omega_\\{\\1,\\2\\}^2", y)
   # Surround with $ symbols for LaTeX math mode
   y <- paste0("$", y, "$")
   class(y) <- c('latex', 'character')
   return(y)
}

# Convert One Parameter Table to Latex
# 
# Converts 'nmpartab_' to latex. Expects 'parameter' to contain THETA(1), OMEGA(2,2), SIGMA(1,1) etc.
# @export
# @family latex
# @param x nmpartab_
# @param ... ignored arguments
# to_latex.nmpartab_ <- function(x, ...){
#    x$parameter %<>% to_latex
#    x
# }

#' Convert Parameter Tables to Latex
#' 
#' Converts 'nmpartab' (list of parameter tables) to latex.
#' calls to_latex() for each member.
#' @export
#' @family latex
#' @param x nmpartab
#' @param ... ignored arguments
to_latex.nmpartab <- function(x, ...)lapply(x, to_latex)


