globalVariables(c('y'))


#' Get NONMEM Version
#' 
#' Gets NONMEM version.
#' Generic, with method \code{\link{nm_version.character}}
#' 
#' @export
#' @keywords internal
#' @family lst
#' @param x object of dispatch
#' @param ... passed
nm_version <- function(x, ...)UseMethod('nm_version')

#' Get the NONMEM Version for Character
#' 
#' Get the NONMEM Version for class character using \code{\link{read_lst}}.
#' 
#' @export
#' @family lst
#' @param x character: a file path, or the name of a run in 'directory', or lst content
#' @param directory character: optional location of x
#' @param extension character: extension identifying lst files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
#' @param clue a text fragment expected to occur in lst files
#' @param ... passed arguments
#' @return length-one character of class 'lst'
#' @examples
#' library(magrittr)
#' options(nmDir = getOption('qpExampleDir'))
#' 'example1' %>% nm_version
#' 'run100' %>% nm_version

nm_version.character <- function(
    x, 
    directory = getOption("nmDir", getwd()), 
    extension = getOption("nmFileLst", 'lst'),
    quiet = TRUE, 
    clean = TRUE,
    nested = FALSE,
    clue = '\\$PROB',
    ...
){
  y <- read_lst(
    x,
    directory = directory,
    extension = extension,
    quiet = quiet,
    clean = clean,
    nested = nested,
    clue = clue,
    ...
  )
  nm_version(y)
}

#' Get the NONMEM Version for Lst
#' 
#' Get the NONMEM Version for class lst (see also \code{\link{read_lst}}).
#' 
#' @export
#' @family lst
#' @importFrom stringr boundary str_extract_all
#' @param x character: of class lst
#' @param ... ignored

nm_version.lst = function(x, ...) 
{
  y = x %>% strsplit(., split="\n")
  y = y[[1]]
  y = y[grepl("version",tolower(y)) & grepl("nonmem",tolower(y))] %>% tolower
  # y = str_extract_all(y, boundary("word"))
  # y = y[[1]]
  # y[length(y)]
  z <- sub('.*version +', '', y)
  x <- sub(' .*', '', z)
  names(x) <- y
  x
  
}

