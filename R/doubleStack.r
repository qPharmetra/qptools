globalVariables(c(
  'value','name'
  ))

#' Stack a Value Twice by Two Covariates
#' @description Dataset will be melted by specified columsn after it will be melted by a second set of columns.
#' This comes in handy when plotting multiple individual parameter estimates versus multiple covariates.
#' @param data dataset containing all variables specified in vars1 and vars2
#' @param vars1 The first variable to stack by. For example \code{c(WT,AGE,BMI,SEX)}
#' @param vars2 The second variable to stack by after the first stack. For example \code{c(ETA1,ETA2,ETA3)}
#' @return A data.frame
#' @importFrom tidyr pivot_longer
#' @importFrom tidyselect all_of
#' @importFrom dplyr ungroup rename
#' @importFrom magrittr %>%
#' @export
#' @family basic
#'
#' @examples
#' set.seed(1234)
#'
#' myDF = data.frame(id = 1:100)
#' myDF$wt = with(myDF, signif(rnorm_by_id(id, 76,15)))
#' myDF$age = with(myDF, signif(sample_by_id(id, samples = seq(18,99))))
#' myDF$sex = with(myDF, sample_by_id(id, samples = c("F","M")))
#' myDF$CL = with(myDF, signif(rnorm_by_id(id, 10,1)))
#' myDF$V = with(myDF, signif(rnorm_by_id(id, 3,0.25)))

#' stacked.df = doubleStack(myDF, vars1 = c("CL","V"), vars2 = c("wt","age","sex"))
#' stacked.df = doubleStack(myDF, vars1 = c("CL","V"), vars2 = c("wt","age"))
#' head(myDF)
#' head(stacked.df)

doubleStack <- function(data, vars1, vars2)
{
  ## check if vars1 and vars2 are numeric
  if((sum(sapply(data[, vars1], class) != "numeric") +
     sum(sapply(data[, vars2], class) != "numeric")) > 0){
    message("All variables in 'vars1' or 'vars2' must be numeric or integer.")
    return()
  }
  stackedData = pivot_longer(data, cols=all_of(vars1)) %>%
    rename(value1=value,variable1=name) %>%
    pivot_longer(cols=all_of(vars2)) %>%
    rename(value2=value,variable2=name)
  return(stackedData)
}

