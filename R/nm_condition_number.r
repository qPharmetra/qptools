#' Get Condition Number.
#' 
#' Get condition number.
#' Generic, with methods 
#' \code{\link{nm_condition_number.default}} and
#' \code{\link{nm_condition_number.ext}}.
#' 
#' @export
#' @keywords internal
#' @param x object of dispatch
#' @param ... passed arguments
#' @family ext
nm_condition_number <- function(x, ...)UseMethod('nm_condition_number')

#' Get Condition Number by Default
#' 
#' Gets condition number for a finished run. Uses EXT file.
#' 
#' @export
#' @family ext
#' @return numeric
#' @param x character: a file path, or the name of a run in 'directory', or ext content
#' @param directory character: optional location of x
#' @param extension character: extension identifying ext files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
#' @param clue a text fragment expected to occur in cov files
# @param final logical: return just the iterations with numbers greater than zero
#' @param ... passed arguments
#' @examples
#' library(magrittr)
#' options(nmDir = getOption('qpExampleDir'))
#' 'example1' %>% nm_condition_number
#' 

nm_condition_number.default <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = getOption("nmFileExt", 'ext'),
      quiet = TRUE, 
      clean = TRUE,
      nested = TRUE,
      clue = 'ITERATION',
      #      final = TRUE,
      ...
){
   ext <- read_ext(
      x, 
      directory = directory, 
      extension = extension, 
      quiet = quiet, 
      clean = clean,
      nested = nested,
      clue = clue,
      ...
   )
   #   parsed <- as.list(ext, ...)
   #   nm_condition_number(parsed, final = final, ...)
   nm_condition_number(ext, ...)
}


#' Get Condition Number for class 'ext'
#' 
#' Gets condition number for class 'ext'.
#' See also \code{\link{read_ext.character}} which makes this class.
#' 
#' @export
#' @keywords internal
#' @family ext
#' @return numeric
#' @param x class 'ext', see \code{\link{as.list.ext}}
# @param final passed to \code{\link{summary.extList}}
#' @param ... ignored

nm_condition_number.ext <- function(x, ...){
   lapply(x, function(x) as.numeric(x[x$ITERATION == "-1000000003",2]))
}