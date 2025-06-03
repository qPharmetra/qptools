globalVariables('num')

#' Retrieve NONMEM Objective Function Value
#' 
#' Retrieves NONMEM Objective Function Value(s).
#' Generic, with method \code{\link{get_ofv.character}}
#' 
#' @export
#' @keywords internal
#' @family nm
#' @param x object of dispatch
#' @param ... passed
get_ofv <- function(x, ...)UseMethod('get_ofv')

#' Retrieve NONMEM Objective Function Value for Character
#' 
#' Retrieves NONMEM Objective Function Value(s) for class character.
#' An attempt is made to acquire the xml output for the relevant model run.
#' Then nodes matching "final_objective_function" are extracted, rounded, 
#' and returned.
#' 
#' @export
#' @family nm
#' @param x character: a file path, or the name of a run in 'directory', or xml content
#' @param directory character: optional location of x
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param digits passed to \code{\link{round}}
#' @param ... passed arguments
#' @return numeric
#' @examples
#' library(magrittr)
#' dir <- getOption("qpExampleDir")
#' options(nmDir = dir)
#' run <- 'example1'
#' file <- 'example1.ext'
#' get_ofv(run)
#' get_ofv(run, directory = dir)
#' get_ofv(file)
#' get_ofv(file, directory = dir)

get_ofv.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      quiet = TRUE, 
      clean = TRUE,
      digits = 1,
      ...
){
   y <- read_ext(x = x, directory = directory, quiet = quiet, clean = clean, ...)
   get_ofv(y, digits = digits)
}

#' Retrieve NONMEM Objective Function Value for Ext
#' 
#' Retrieves NONMEM Objective Function Value(s) for class 'ext'. 
#' See \code{\link{read_ext.character}} and \code{\link{get_ofv.character}}.
#' 
#' @export
#' @family ext
#' @param x character: a file path, or the name of a run in 'directory', or xml content
# @param directory character: optional location of x
# @param quiet logical: flag for displaying intermediate output
# @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param digits passed to \code{\link{round}}
#' @param ... ignored
#' @return numeric

# get_ofv.nonmem <- function(
#    x, 
#    directory = getOption("nmDir", getwd()), 
#    quiet = TRUE, 
#    clean = TRUE,
#    digits = 1,
#    ...
# ){
#    y <- x$nonmem$problem
#    y <- y[names(y) == 'estimation']
#    z <- sapply(y, function(method)method$final_objective_function)
#    z <- unlist(z)
#    z <- as.numeric(z)
#    if(length(z) != length(y))warning('length of result differs number of estimations')
#    z <- round(z, digits = digits)
#    z
# }

get_ofv.ext <- function(
    x, 
    digits = 1,
    ...
){
  x <- as.list(x, ...)
  lapply(x, function(y) y %>% filter(ITERATION == -1000000000) %>% 
           .[, ncol(.)] %>% 
           unlist %>% 
           as.numeric() %>% 
           round(digits = digits)
  )
}

#' Retrieve NONMEM Objective Function Value for NONMEM
#' 
#' Retrieves NONMEM Objective Function Value(s) for class 'nonmem'. 
#' See \code{\link{read_nm_qp.character}} and \code{\link{get_ofv.character}}.
#' Then nodes matching "final_objective_function" are extracted, rounded,
#' and returned. Currently supports NONMEM models with only one problem.
   
#' @export
#' @family ext
#' @param x character: a file path, or the name of a run in 'directory', or xml content
#' @param directory character: optional location of x
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param digits passed to \code{\link{round}}
#' @param ... ignored
#' @return numeric

get_ofv.nonmem <- function(
   x,
   directory = getOption("nmDir", getwd()),
   quiet = TRUE,
   clean = TRUE,
   digits = 1,
   ...
){
   y <- x$nonmem$problem
   y <- y[names(y) == 'estimation']
   z <- sapply(y, function(method)method$final_objective_function)
   z <- unlist(z)
   z <- as.numeric(z)
   if(length(z) != length(y))warning('length of result differs number of estimations')
   z <- round(z, digits = digits)
   z
}

