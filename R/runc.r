#' Glue run rootname and number together
#' 
#' Pastes run rootname and number together.
#' 
#' @export
#' @return data.frame
#' @family basic
#' @param x numeric vector
#' @param run prefix of run number, defaults to "run"
#' @examples
#' library(magrittr)
#' 1:10 %>% runc
#' c(878,1021,1030:1035) %>% runc
#' 

runc = function(x,run="run") paste0(run, x)
