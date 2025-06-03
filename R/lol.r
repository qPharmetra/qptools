#' Get the Last Element of a List
#' 
#' Extracts the Last Element of a List. most NONMEM post-processing functions in 
#' \pkg{qptools} provide a list of data frames. This function returns the last (default)
#' or nth element of that list. 
#' 
#' @export
#' @family ext
#' @return data.frame 
#' @param x any list
#' @param n numeric: position of the element. Defaults to NULL which ensure that the last element is returned.
#' @examples
#' library(magrittr)
#' library(dplyr)
#' options(nmDir = getOption("qpExampleDir"))
#' "run103" %>% nm_params_table %>% format
#' "run103" %>% nm_params_table %>% format %>% lol
#' d = list(A=data.frame(A=1:3,B=3:1),B=data.frame(A=3:1,B=1:3),C=data.frame(A=10:12,B=5:7))
#' d %>% lol
#' d %>% lol(n=2)
#' 

lol  = function(x, n=NULL)
{
  stopifnot(is.list(x) & !is.data.frame(x))
  if(!is.null(n))
     if(n>length(x) | n<1)
     {
       message(paste("argument n should not be higher than length(x) =", length(x))); return()
     }
     
  if(is.null(n)) x[[length(x)]] else x[[n]]
}
