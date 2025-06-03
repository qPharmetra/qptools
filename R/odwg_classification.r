globalVariables(c('AST', 'BILI'))
#' Calculate ODWG Classification
#' 
#' Calculates ODWG classification.  Generic, with method \code{\link{odwg_classification.data.frame}}.
#' 
#' @export
#' @param x object of dispatch
#' @param ... passed arguments
odwg_classification <- function(x, ...)UseMethod('odwg_classification')

#' Calculate ODWG Classification for Data Frame
#' 
#' Calculates ODWG classification for data frame.
#' 
#' @export
#' @param x data.frame
#' @param ULNAST upper limit of normal for AST in IU (default)
#' @param ULNBILI upper limit of normal for bilirubin umol/L (default)
#' @param ... ignored
#' @return data.frame, with additional column ODWG (integer, 0-3)
#' @family basic
#' @examples
#' library(magrittr)
#' x <- data.frame(id = 1:4, AST = c(39, 41, 39, 39), BILI = c(17, 17, 26, 52))
#' x %>% odwg_classification

odwg_classification.data.frame = function(x, ULNAST = 40,ULNBILI = 17.104, ...)
{
   if('ODWG' %in% names(x)) stop('not overwriting column ODWG')
   if(!('AST' %in% names(x))) stop ('please supply AST as a column')
   if(!('BILI' %in% names(x))) stop ('please supply BILI as a column')
   x %<>% mutate(ODWG = odwg(AST, BILI, ULNAST = ULNAST, ULNBILI = ULNBILI, ...)) 
   # x %<>% mutate_cond(AST <= ULNAST & BILI <= ULNBILI, ODWG=0) 
   # x %<>% mutate_cond({AST > ULNAST | BILI > ULNBILI} & BILI <= 1.5*ULNBILI, ODWG=1)
   # x %<>% mutate_cond(BILI > 1.5*ULNBILI & BILI < 3*ULNBILI, ODWG=2)
   # x %<>% mutate_cond(BILI > 3*ULNBILI, ODWG=3)
   x
}
#' Calculate ODWG Classification
#' 
#' Calculates ODWG classification from values of AST and bilirubin.
#' 
#' @export
#' @param ast AST in same units as ULNAST
#' @param bili bilirubin in same units as ULNBILI
#' @param ULNAST upper limit of normal for AST in IU (default)
#' @param ULNBILI upper limit of normal for bilirubin in umol/L (default)
#' @param ... ignored
#' @return integer
#' @family basic
#' @examples
#' library(magrittr)
#' library(dplyr)
#' x <- data.frame(id = 1:4, AST = c(39, 41, 39, 39), BILI = c(17, 17, 26, 52))
#' x %>% mutate(ODWG = odwg(AST, BILI))

odwg <- function(ast, bili, ULNAST = 40,ULNBILI = 17.104, ...){
   stopifnot(
      is.numeric(ast), 
      is.numeric(bili), 
      is.numeric(ULNAST), 
      is.numeric(ULNBILI)
   )
   stopifnot(length(ULNAST) == 1, length(ULNBILI) == 1)
   stopifnot(length(ast) == length(bili))
   odwg <- case_when(
     ast <= ULNAST & bili <= ULNBILI ~ 0L,
     bili <= 1.5 * ULNBILI ~ 1L,
     bili < 3 * ULNBILI ~ 2L,
     TRUE ~ 3L
   )
   odwg
}
