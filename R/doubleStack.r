globalVariables(c(
  'value','name'
  ))

#' Double-stack something
#' 
#' Generic, with method \code{\link{doubleStack.default}}
#' 
#' @export
#' @keywords internal
#' @family basic
#' @param x object of dispatch
#' @param ... passed
doubleStack <- function(x, ...)UseMethod('doubleStack')

#' Stack a Value Twice by Two Covariates
#' @description Dataset will be melted by specified columns after it will be melted by a second set of columns.
#' This comes in handy when plotting multiple individual parameter estimates versus multiple covariates.
#' @param x dataset containing all variables specified in vars1 and vars2
#' @param vars1 The first variable to stack by. For example \code{c(WT,AGE,BMI,SEX)}
#' @param vars2 The second variable to stack by after the first stack. For example \code{c(ETA1,ETA2,ETA3)}
#' @param ... ignored
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

doubleStack.default <- function(x, vars1, vars2, ...)
{
  ## check if vars1 and vars2 are numeric
  if(
     sum(!sapply(x[, vars1], is.numeric)) +
     sum(!sapply(x[, vars2], is.numeric)) > 0
   ){
    message("All variables in 'vars1' or 'vars2' must be numeric or integer.")
    return()
  }
  stackedData = pivot_longer(x, cols=all_of(vars1)) %>%
    rename(value1=value,variable1=name) %>%
    pivot_longer(cols=all_of(vars2)) %>%
    rename(value2=value,variable2=name)
  return(stackedData)
}


#' Stack a Value Twice by Two Covariates 
#' @description Dataset will be melted by specified columns after it will be melted by a second set of columns.
#' This comes in handy when plotting multiple individual parameter estimates versus multiple covariates.
#' This is the method for class "decorated".  See also \code{\link{doubleStack.default}}. The advantage here is that you can have variables that are not integer or numeric.  Also, you can have words rather than numeric values in the axes of resulting plots.  See examples.
#' @param x dataset containing all variables specified in vars1 and vars2
#' @param vars1 The first variable to stack by. For example \code{c(WT,AGE,BMI,SEX)}
#' @param vars2 The second variable to stack by after the first stack. For example \code{c(ETA1,ETA2,ETA3)}
#' @param ... ignored
#' @return A decorated data.frame
#' @export
#' @family basic
#' @examples
#' set.seed(0)
#' library(magrittr)
#' library(dplyr)
#' library(yamlet)
#' library(tidyr)
#' library(ggplot2)
#' x <- data.frame(id = 1:100)
#' x %<>% mutate(wt  = id %>% rnorm_by_id(76, 15) %>% signif)
#' x %<>% mutate(age = id %>% sample_by_id(18:99))
#' x %<>% mutate(sex = id %>% sample_by_id(0:1))
#' x %<>% mutate(coh = id %>% sample_by_id(1:3))
#' x %<>% mutate(CL  = id %>% rnorm_by_id(10, 1) %>% signif)
#' x %<>% mutate(V   = id %>% rnorm_by_id(3, 0.25) %>% signif)
#' 
#' # At the moment, we just have a data.frame, that responds normally 
#' y <- doubleStack(x, vars1 = c("CL","V"), vars2 = c("wt","age","sex"))
#' 
#' # Now we decorate it.
#' head(x)
#' x %<>% decorate('
#' id: Subject ID
#' wt:  [ Body Weight, kg]
#' age: [ Age, year]
#' sex: [ Sex, [ Female: 0, Male: 1 ]]
#' coh: [ Cohort, [ Cohort 1: 1, Cohort 2: 2, Cohort 3: 3]]
#' CL:  [ CL/F, L/h]
#' V:   [ V/F, L ]
#' ')
#' 
#' # Select some variables
#' vars1 = c('CL', 'V')
#' vars2 = c('coh', 'sex')
#' 
#' # A conventional plot gives numbers in x axis labels
#' x %>% 
#'    doubleStack(vars1, vars2) %>%
#'    mutate(value2 = factor(value2)) %>%
#'    ggplot(aes(x = value2, y = value1)) +
#'    facet_grid(variable1 ~ variable2, scales = 'free') +
#'    geom_boxplot()
#' 
#' # A plot of "resolved" data is more informative.
#' x %>% 
#'    resolve %>%
#'    modify(coh, sex, name = label) %>%
#'    doubleStack(c('CL', 'V'), c('Cohort', 'Sex')) %>%
#'    ggplot(aes(x = value2, y = value1)) +
#'    facet_grid(variable1 ~ variable2, scales = 'free') +
#'    xlab('') + ylab('') +
#'    geom_boxplot()

doubleStack.decorated <- function(x, vars1, vars2, ...)
{
   x %<>% pivot_longer(cols=all_of(vars1)) 
   x %<>% rename(value1=value,variable1=name) 
   x %<>% pivot_longer(cols=all_of(vars2)) 
   x %<>% rename(value2=value,variable2=name)
   x
}

