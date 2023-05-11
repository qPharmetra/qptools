# ROXYGEN Documentation
#' like as.ordered with extended formatting
#' @param x a vector of numeric values
#' @param prefix text string to preceed the number (like drug name)
#' @param suffix text string to ome after the number (like mg)
#' @param paste.function function to use when glueing together prefix, x, and suffix
#' @param special.x list of length 2, with first (numeric) element being the number that will be exchanged
#' for the 2nd element which should be a text string.
#' @return A formatted character vector containing count and percentage of
#' unique values in \code{x}.
#' @export
#' @family format
#' @examples
#' out = expand.grid(ID = 1:5, DOSE = c(0,500,100,4000))
#' factor(out$DOSE)
#' #Levels: 0 100 500 4000  ## W H A T ???
#' orderedNumeric(out$DOSE)
#' #Levels:  0   100   500   4000    #that's better, similar to ordered(out$DOSE)
#' orderedNumeric(out$DOSE, special.x = list(0, "Placebo"))
#' #Levels: Placebo  100   500   4000
#' orderedNumeric(out$DOSE, prefix = "DrugName ")
#' orderedNumeric(out$DOSE, prefix = "DrugName", suffix = "mcg")
#' orderedNumeric(out$DOSE, prefix = "DrugName", suffix = "mcg", special.x = list(0, "Placebo"))
#' orderedNumeric(out$DOSE, prefix = "DrugName ", suffix = "mcg", special.x = list(0, "Vehicle"),
#' paste.function = paste0)
orderedNumeric <- function(x, prefix = "", suffix = "", paste.function = paste, special.x = NULL){
  xx = x
  if(!is.null(special.x) & is.list(special.x)) xx = swap(xx, special.x[[1]], special.x[[2]])
  theString = do.call(paste.function, list(prefix,xx,suffix))
  if(!is.null(special.x) & is.list(special.x)) theString[x == special.x[[1]]] = special.x[[2]]
  factor(theString, levels = unique(theString[order(x)]))
}
