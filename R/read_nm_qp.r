globalVariables(c('num', 'short', 'com'))

#' Read NONMEM Results
#' 
#' Reads NONMEM results.
#' Generic, with method \code{\link{read_nm_qp.character}}
#' 
#' @export
#' @keywords internal
#' @family nm
#' @param x object of dispatch
#' @param ... passed
read_nm_qp <- function(x, ...)UseMethod('read_nm_qp')

#' Read NONMEM Results for Character
#' 
#' Reads NONMEM results for class character using \code{\link{read_gen.character}}.
#' See also \code{\link[pmxTools]{read_nm}}.
#' 
#' 
#' @export
#' @family nm
#' @importFrom pmxTools read_nm
#' @importFrom utils file_test
#' @param x character: a file path, or the name of a run in 'directory', or xml content
#' @param directory character: optional location of x
#' @param extension character: extension identifying cov files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
#' @param clue a text fragment expected to occur in cov files
#' @param ... passed arguments
#' @return list of class 'nonmem'
#' @examples
#' nm <- read_nm_qp("example1", directory = getOption("qpExampleDir"))
#' names(nm)
#' names(nm$nonmem)
#' names(nm$nonmem$problem)
#' names(nm$nonmem$problem$estimation)
#' 
#'# consider multiple ways of addressing an xml file
#'
#' dir <- getOption("qpExampleDir")
#' options(nmDir = dir)
#' run <- 'example1'
#' file <- 'example1.xml'
#' zipped <- 'example1.xml.7z'
#' path <- file.path(dir, run, zipped)
#' file.exists(path)
#' 
#' nm1 <- read_nm_qp(run)
#' nm2 <- read_nm_qp(run, directory = dir)
#' nm3 <- read_nm_qp(file)
#' nm4 <- read_nm_qp(file, directory = dir)
#' nm5 <- read_nm_qp(path)

read_nm_qp.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = getOption("nmFileXml", 'xml'),
      quiet = TRUE, 
      clean = TRUE,
      nested = TRUE,
      clue = '</nm:output>',
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
   file <- tempfile(fileext = '.xml')
   writeLines(y, con = file)
   z <- pmxTools::read_nm(file, quiet = quiet, ...)
   class(z) <- 'nonmem' # enforced
   z
}

#' Read NONMEM results
#' 
#' Reads NONMEM results for class 'nonmem'. 
#' Just returns its argument, which is already the result of reading nonmem.
#' 
#' @export
#' @keywords internal
#' @family nm
#' @param x class 'nonmem'
#' @param ... ignored
#' @return character vector of class 'nonmem'
read_nm_qp.nonmem <- function(x, ...) x

#' Harvest Model Item Definitions for NONMEM
#' 
#' Harvests model item definitions for NONMEM object.
#' @export
#' @return definitions data.frame
#' @param x nonmem, i.e. output of \code{\link{read_nm_qp}}
#' @param fields character: names of semicolon-delimited fields to expect in control streams
#' @param ... passed to \code{\link[nonmemica]{definitions}}
#' @family nm
#' @seealso read_nm_qp
definitions.nonmem <- function(x, fields = getOption('fields', c('symbol', 'unit', 'transform', 'label')), ...){
   # nonmem class is assigned by read_nm_qp to 
   # output of pmxTools::read_nm
   # nonmem has $control_stream element, a list with (at least) one element.
   # definitions.character() requires length one character path to ctl file.
   # we accommodate here.
   # only supporting first element
   control_stream <- x$control_stream
   stopifnot(length(control_stream) > 0)
   if(length(control_stream) > 1)warning('length of control_stream (list) > 1; only first element supported')
   control_stream <- control_stream[[1]]
   stopifnot(is.character(control_stream))
   file <- tempfile()
   writeLines(control_stream, file)
   defs <- definitions(x = '', ctlfile = file, fields = fields, ...) # x is superfluous if ctlfile supplied
   unlink(file)
   return(defs)
}

# https://rstudio.github.io/r-manuals/r-exts/Generic-functions-and-methods.html

#' Create a Table of Model Parameters
#' 
#' Creates a Table of Model Parameters.
#' Generic, with default method \code{\link{get_est_table.default}}
#' and special method \code{\link{get_est_table.nonmem}}.
#' @export
#' @keywords internal
#' @param x object of dispatch
#' @param ... passed arguments
#' @family nm
get_est_table <- function(x, ...) UseMethod("get_est_table")

#' Create a Table of Model Parameters by Default
#' 
#' Creates a Table of Model Parameters using default method.
#' See also \code{\link[pmxTools]{get_est_table}}.

#' @export
#' @param x object of dispatch
#' @param ... passed to \code{\link[pmxTools]{get_est_table}}
#' @family nm
#' @importFrom pmxTools get_est_table
get_est_table.default <- function(x, ...) pmxTools::get_est_table(x, ...)


#' Create a Table of Model Parameters for NONMEM
#' 
#' Creates a Table of Model Parameters for class 'nonmem'.
#' See also \code{\link{read_nm_qp}} which returns this class.
#' if \code{meta} is TRUE, an attempt is made
#' to supply metadata using markup in the nonmem control stream
#' (as saved in the xml) and the result of \code{definitions(x)}.
#' The value of \code{getOption('fields')} is highly relevant.
#' See also \code{\link[nonmemica]{psn_options}}.

#' @export
#' @param x object of dispatch
#' @param thetaLabels passed to \code{\link[pmxTools]{get_est_table}}
#' @param omegaLabels passed to \code{\link[pmxTools]{get_est_table}}
#' @param sigmaLabels passed to \code{\link[pmxTools]{get_est_table}}
#' @param sigdig passed to \code{\link[pmxTools]{get_est_table}}
#' @param fields character: names of semicolon-delimited fields to expect in control streams
#' @param ... passed to \code{\link[pmxTools]{get_est_table}} and \code{\link[nonmemica]{definitions}}
#' @param meta whether to merge metadata (labels etc.) from control stream
#' @importFrom nonmemica definitions safe_join
#' @family nm
#' @examples
#' library(magrittr)
#' options(nmDir = getOption('qpExampleDir'))
#' 'example1' %>% 
#'   read_nm_qp %>% 
#'   get_est_table %$% 
#'   Parameter
#' 
get_est_table.nonmem <- function(
   x, 
   thetaLabels = NULL, 
   omegaLabels = NULL, 
   sigmaLabels = NULL, 
   sigdig = 3,
   fields = getOption('fields', c('symbol', 'unit', 'transform', 'label')),
   ...,
   meta = TRUE
){
   y <- NextMethod()
   if(meta){
   z <- definitions(x, fields = fields, ...)
   names(z)[names(z) == 'item'] <- 'Parameter'
   z$Parameter <- nms_pmx(as_nms_canonical(z$Parameter))
   z <- z[z$Parameter %in% y$Parameter,, drop = FALSE]
   y <- safe_join(y, z, by = intersect(names(y), names(z)))
   }
   class(y) <- union('nm_est_table', class(y))
   y
}
   