#' Read NONMEM MOD Results
#' 
#' Reads NONMEM MOD results.
#' Generic, with method \code{\link{read_mod.character}}
#' 
#' @export
#' @keywords internal
#' @family mod
#' @param x object of dispatch
#' @param ... passed
read_mod <- function(x, ...)UseMethod('read_mod')

#' Read NONMEM MOD Results for Character
#' 
#' Reads NONMEM MOD results for class character using \code{\link{read_gen.character}}.
#' 
#' @export
#' @family mod
#' @importFrom utils file_test
#' @param x character: a file path, or the name of a run in 'directory', or mod content
#' @param directory character: optional location of x
#' @param extension character: extension identifying mod files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
#' @param clue a text fragment expected to occur in cov files
#' @param ... passed arguments
#' @return length-one character of class 'mod'
#' @examples
#' library(magrittr)
#' options(nmDir = getOption('qpExampleDir'))
#' 'example1' %>% read_mod(ext = 'ctl')

read_mod.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = getOption("nmFileMod", 'mod'),
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
   class(y) <- 'mod'
   y
}

#' Read NONMEM MOD results
#' 
#' Reads NONMEM MOD results for class 'mod'. 
#' Just returns its argument, which is already the result of reading MOD.
#' 
#' @export
#' @keywords internal
#' @family mod
#' @param x class 'mod'
#' @param ... ignored
#' @return character vector of class 'mod'
read_mod.mod <- function(x, ...) x

