#' Read NONMEM LST Results
#' 
#' Reads NONMEM LST results.
#' Generic, with method \code{\link{read_lst.character}}
#' 
#' @export
#' @keywords internal
#' @family lst
#' @param x object of dispatch
#' @param ... passed
read_lst <- function(x, ...)UseMethod('read_lst')

#' Read NONMEM LST Results for Character
#' 
#' Reads NONMEM LST results for class character using \code{\link{read_gen.character}}.
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
#' 'example1' %>% read_lst
#' 'example1.lst' %>% read_lst
#' 'example1.lst' %>% read_lst(nested = TRUE) # different file! (if it exists)
#' path <- file.path(getOption('qpExampleDir'), 'example1', 'example1.lst.7z')
#' path
#' stopifnot(file.exists(path))
#' path %>% read_lst
#' 'run100' %>% nm_shrinkage


read_lst.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = getOption("nmFileLst", 'lst'),
      quiet = TRUE, 
      clean = TRUE,
      nested = FALSE,
      clue = '\\$PROB',
      ...
){
   y <- read_gen(
      x,
      directory = directory,
      extension = extension,
      quiet = quiet,
      clean = clean,
      nested = nested,
      clue = clue,
      ...
   )
   class(y) <- 'lst' # enforced
   y
}

#' Read NONMEM LST results
#' 
#' Reads NONMEM LST results for class 'lst'. 
#' Just returns its argument, which is already the result of reading LST.
#' 
#' @export
#' @keywords internal
#' @family lst
#' @param x class 'lst'
#' @param ... ignored
#' @return character vector of class 'lst'
read_lst.lst <- function(x, ...) x

