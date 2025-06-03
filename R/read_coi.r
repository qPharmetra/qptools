#' Read NONMEM COI Results
#' 
#' Reads NONMEM COI results.
#' Generic, with method \code{\link{read_coi.character}}
#' 
#' @export
#' @keywords internal
#' @family coi
#' @param x object of dispatch
#' @param ... passed
read_coi <- function(x, ...)UseMethod('read_coi')

#' Read NONMEM COI Results for Character
#' 
#' Reads NONMEM COI results for class character using \code{\link{read_gen.character}}.
#' 
#' @export
#' @family coi
#' @importFrom utils file_test
#' @param x character: a file path, or the name of a run in 'directory', or coi content
#' @param directory character: optional location of x
#' @param extension character: extension identifying coi files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
#' @param clue a text fragment expected to occur in coi files
#' @param ... passed arguments
#' @return length-one character of class 'coi'
#' @examples
#' library(magrittr)
#' options(nmDir = getOption('qpExampleDir'))
#' 'example1' %>% read_coi
#' 'example1.coi' %>% read_coi
#' path <- file.path(getOption('qpExampleDir'), 'example1', 'example1.coi.7z')
#' path
#' file.exists(path)
#' path %>% read_coi
#' path %>% read_coi %>% as.matrix
#' path %>% get_coimat # same
#' 'example1' %>% get_coimat
#' 'example1' %>% get_covmat
#' 'example1' %>% get_cormat

read_coi.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = getOption("nmFilecoi", 'coi'),
      quiet = TRUE, 
      clean = TRUE,
      nested = TRUE,
      clue = 'TABLE NO.',
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
   class(y) <- c('coi', 'mat') # enforced
   y
}

#' Read NONMEM COI results for 'coi'
#' 
#' Reads NONMEM COI results for class 'coi'. 
#' Just returns its argument, which is already the result of reading COI.
#' 
#' @export
#' @keywords internal
#' @family coi
#' @param x class 'coi'
#' @param ... ignored
#' @return character vector of class 'coi'
read_coi.coi <- function(x, ...) x

#' Get Inverse Correlation Matrix
#' 
#' Gets Inverse Inverse Correlation matrix.
#' Generic, with methods \code{\link{get_coimat.character}} and \code{\link{get_coimat.coi}}.
#' 
#' @export
#' @family coi
#' @param x object of dispatch
#' @keywords internal
#' @param ... passed arguments
get_coimat <- function(x, ...)UseMethod('get_coimat')

#' Get Inverse Correlation Matrix for Character
#' 
#' Gets Inverse Correlation matrix for character.
#' 
#' @export
#' @family coi
#' @param x character: a file path, or the name of a run in 'directory', or coi content
#' @param directory character: optional location of x
#' @param extension character: extension identifying coi files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
#' @param clue a text fragment expected to occur in coi files
#' @param ... passed arguments
#' @return list of Inverse Correlation matrices as data frames
get_coimat.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = getOption("nmFilecoi", 'coi'),
      quiet = TRUE, 
      clean = TRUE,
      nested = TRUE,
      clue = 'TABLE NO.',
      ...
){
   y <- read_coi(
      x,
      directory = directory,
      extension = extension,
      quiet = quiet,
      clean = clean,
      nested = nested,
      clue = clue,
      ...
   )
   get_coimat(y, ...)
}
#' Get Inverse Correlation Matrix for COI
#' 
#' Gets Inverse Correlation matrix for COI.
#' 
#' @export
#' @keywords internal
#' @family coi
#' @param x coi
#' @param ... passed arguments
#' @return list of Inverse Correlation matrices as data frames
get_coimat.coi <- function(x, ...)as.matrix(x, ...)

