#' Read NONMEM COR Results
#' 
#' Reads NONMEM COR results.
#' Generic, with method \code{\link{read_cor.character}}
#' 
#' @export
#' @keywords internal
#' @family cor
#' @param x object of dispatch
#' @param ... passed
read_cor <- function(x, ...)UseMethod('read_cor')

#' Read NONMEM COR Results for Character
#' 
#' Reads NONMEM COR results for class character using \code{\link{read_gen.character}}.
#' 
#' @export
#' @family cor
#' @importFrom utils file_test
#' @param x character: a file path, or the name of a run in 'directory', or cor content
#' @param directory character: optional location of x
#' @param extension character: extension identifying cor files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
#' @param clue a text fragment expected to occur in cor files
#' @param ... passed arguments
#' @return length-one character of class 'cor'
#' @examples
#' library(magrittr)
#' options(nmDir = getOption('qpExampleDir'))
#' 'example1' %>% read_cor
#' 'example1.cor' %>% read_cor
#' path <- file.path(getOption('qpExampleDir'), 'example1', 'example1.cor.7z')
#' path
#' file.exists(path)
#' path %>% read_cor
#' path %>% read_cor %>% as.matrix
#' path %>% get_cormat # same
#' 'example1' %>% get_cormat
#' 'example1' %>% get_covmat
#' 'example1' %>% get_coimat

read_cor.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = getOption("nmFilecor", 'cor'),
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
   class(y) <- c('cor', 'mat') # enforced
   y
}

#' Read NONMEM COR results for 'cor'
#' 
#' Reads NONMEM COR results for class 'cor'. 
#' Just returns its argument, which is already the result of reading COR.
#' 
#' @export
#' @keywords internal
#' @family cor
#' @param x class 'cor'
#' @param ... ignored
#' @return character vector of class 'cor'
read_cor.cor <- function(x, ...) x

#' Get Correlation Matrix
#' 
#' Gets correlation matrix.
#' Generic, with methods \code{\link{get_cormat.character}} and \code{\link{get_cormat.cor}}.
#' 
#' @export
#' @family cor
#' @param x object of dispatch
#' @keywords internal
#' @param ... passed arguments
get_cormat <- function(x, ...)UseMethod('get_cormat')

#' Get Correlation Matrix for Character
#' 
#' Gets Correlation matrix for character.
#' 
#' @export
#' @family cor
#' @param x character: a file path, or the name of a run in 'directory', or cor content
#' @param directory character: optional location of x
#' @param extension character: extension identifying cor files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
#' @param clue a text fragment expected to occur in cor files
#' @param ... passed arguments
#' @return list of correlation matrices as data frames
get_cormat.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = getOption("nmFilecor", 'cor'),
      quiet = TRUE, 
      clean = TRUE,
      nested = TRUE,
      clue = 'TABLE NO.',
      ...
){
   y <- read_cor(
      x,
      directory = directory,
      extension = extension,
      quiet = quiet,
      clean = clean,
      nested = nested,
      clue = clue,
      ...
   )
   get_cormat(y, ...)
}
#' Get Correlation Matrix for COR
#' 
#' Gets correlation matrix for COR.
#' 
#' @export
#' @keywords internal
#' @family cor
#' @param x cor
#' @param ... passed arguments
#' @return list of correlation matrices as data frames
get_cormat.cor <- function(x, ...)as.matrix(x, ...)

