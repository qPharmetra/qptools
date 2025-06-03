globalVariables(c('lst', 'txt', 'loc1','loc2'))

#' Split NONMEM Output Listed by Estimation Method for Character
#' 
#' Splits NONMEM output and put it in a list for each estimation method for Character
#' 
#' @export
#' @family lst
#' @param x character: a file path, or the name of a run in 'directory', or lst content
#' @param directory character: optional location of x
#' @param extension length-two character: extensions identifying ext and lst files
#' @param nested length-two logical: are the ext and lst files nested within the run 
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param clue a text fragment expected to occur in cov files
#' @param ... passed arguments
#' @importFrom stringr str_split 
#' @importFrom magrittr %>% %<>%
#' @return data.frame
#' @examples
#' library(magrittr)
#' library(dplyr)
#' dir <- getOption("qpExampleDir")
#' options(nmDir = dir)
#' nm_lst_by_est_method('run103')
#' nm_lst_by_est_method('run103') %>% lapply(., function(x) x[1:10])

nm_lst_by_est_method.character <- function(x,
                                 directory = getOption("nmDir", getwd()),
                                 extension = c(getOption("nmFileLst", 'ext'),
                                               getOption("nmFileLst", 'lst')),
                                 nested = c(TRUE, FALSE),
                                 quiet = TRUE,
                                 clean = TRUE,
                                 clue = '\\$PROB',
                                 ...)
{
  stopifnot(is.logical(nested))
  nested <- rep(nested, length.out = 2)
  extension <- rep(extension, length.out = 2)
  lst = read_lst(
    x,
    directory = directory,
    extension = extension[[2]],
    quiet = quiet,
    clean = clean,
    nested = nested[[2]],
    clue = clue,
    ...
  )
  nm_lst_by_est_method(lst)
}

#' Split NONMEM Output Listed by Estimation Method 
#' 
#' Splits NONMEM output and put it in a list for each estimation method
#' 

#' @export
#' @family lst
#' @param x object of dispatch
#' @param ... passed arguments

nm_lst_by_est_method = function(x, ...)UseMethod('nm_lst_by_est_method')

#' Split NONMEM Output Listed by Estimation Method for LST
#' 
#' Splits NONMEM output and put it in a list for each estimation method for LST
#' 
#' @export
#' @family lst
#' @param x object of disptach of class 'lst'
#' @param ... passed arguments

nm_lst_by_est_method.lst = function(x, ...)
{
  txt = strsplit(x, '\n')[[1]]
  ## txt is the lst files split into a list of text belonging to each estimation method
  txt = txt[grep("#TBLN", txt)[1]:length(txt)]
  loc1 = grep("#TBLN", txt)
  loc2 = c(loc1[-1] - 1, length(txt))
  txt = lapply(1:length(loc1), function(y, txt, loc1, loc2)
    txt[loc1[y]:loc2[y]]
    , txt = txt, loc1 = loc1, loc2 = loc2)
  txt
}

