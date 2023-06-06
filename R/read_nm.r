globalVariables('num')

#' Read NONMEM Results
#' 
#' Reads NONMEM results.
#' Generic, with method \code{\link{read_nm.character}}
#' 
#' @export
#' @family nm
#' @param x object of dispatch
#' @param ... passed
read_nm <- function(x, ...)UseMethod('read_nm')

#' Read NONMEM Results for Character
#' 
#' Reads NONMEM results for class character.
#' If length of x is greater than one, it is collapsed.
#' If x is a file, possibly in \code{directory}, it is read with \code{\link{read_nm.file}}.
#' If x is a directory, possibly in \code{directory}, it is read with \code{\link{read_nm.run}}.
#' Otherwise an attempt is made to read it with \code{\link{read_nm.xml}}.
#' See also \code{\link[pmxTools]{read_nm}} on which this depends.
#' 
#' 
#' @export
#' @family nm
#' @importFrom pmxTools read_nm
#' @param x character: a file path, or the name of a run in 'directory', or xml content
#' @param directory character: optional location of x
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param ... passed arguments
#' @return list of class 'nonmem'
#' @examples
#' nm <- read_nm("example1", directory = getOption("qpExampleDir"))
#' names(nm)
#' names(nm$nonmem)
#' names(nm$nonmem$problem)
#' names(nm$nonmem$problem$estimation)
#' 
#'# consider multiple ways of addressing an xml file
#'
#' dir <- getOption("qpExampleDir")
#' run <- 'example1'
#' zip <- 'example1.xml.7z'
#' path <- file.path(dir, run, file)
#' file.exists(path)
#' to <- nm_unzip(zip.filename = path)
#' xml <- readLines(path)


read_nm.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      quiet = FALSE, 
      clean = TRUE,
      ...
){
   stopifnot(is.character(directory), length(directory) == 1)
   stopifnot(is.logical(quiet), length(quiet) == 1)
   stopifnot(is.logical(clean), length(clean) == 1)
   if(length(x) > 1) x <- paste(x, collapse = '\n')
   class(x) <- 'xml'
   if(file_test('-f', x) || file_test('-f', file.path(directory, x))) class(x) <- 'file'
   if(file_test('-d', x) || file_test('-d', file.path(directory, x))) class(x) <- 'run'
   read_nm(x, directory = directory, quiet = quiet, clean = clean, ...)
}

#' Read NONMEM Results as XML
#' 
#' Reads NONMEM results for class 'xml': length-one character with xml content.
#' See also \code{\link[pmxTools]{read_nm}}.
#' 
#' @export
#' @family nm
#' @importFrom pmxTools read_nm
#' @param x length-one character with xml content
#' @param quiet logical: flag for displaying intermediate output
#' @param ... passed arguments
#' @return list of class 'nonmem'
read_nm.xml <- function(
      x, 
      quiet = FALSE, 
      ...
){
   stopifnot(length(x) == 1)
   stopifnot(is.logical(quiet), length(quiet) == 1)
   file <- tempfile(fileext = '.xml')
   writeLines(x, con = file)
   class(file) <- 'file'
   read_nm(file, quiet = quiet, ...)
}

#' Read NONMEM Results as File
#' 
#' Reads NONMEM results for class 'file': a path to an xml file.
#' See also \code{\link[pmxTools]{read_nm}}.
#' 
#' @export
#' @family nm
#' @importFrom pmxTools read_nm
#' @param x length-one character: path to an xml file, possibly in \code{directory}
#' @param directory character: optional location of x
#' @param quiet logical: flag for displaying intermediate output
#' @param ... passed arguments
#' @return list of class 'nonmem'
read_nm.file <- function(
      x, 
      directory = getwd(),
      quiet = FALSE, 
      ...
){
   stopifnot(length(x) == 1)
   stopifnot(is.character(directory), length(directory) == 1)
   stopifnot(is.logical(quiet), length(quiet) == 1)
   if(file_test('-f', file.path(directory, x))) x <- file.path(directory, x)
   x <- as.character(x)
   y <- pmxTools::read_nm(x, quiet = quiet, ...)
   class(y) <- 'nonmem'
   return(y)
}



#' Read the entire XML output of a Converged NONMEM Run
#' 
#' Extracts the output of a completed NONMEM run that is stored in an XML file,
#' possibly 7-zipped.
#' 
#' @param x character string in the form of 'run1'
#' @param directory parent directory of the run folder where .xml file resides
#' @param clean should the unzipped file be removed when done (defaults to TRUE, but ignored if file was already present)
#' @param quiet suppresses the messages (defaults to not suppressing)
#' @param ... passed arguments
#' @return nonmem: List of all elements of the XML output of a NONMEM model run
#' @export
#' @family nm
#' @importFrom pmxTools read_nm
#' @examples
#' nm <- read_nm("example1", directory = getOption("qpExampleDir"))
#' names(nm)
#' names(nm$nonmem)
#' names(nm$nonmem$problem)
#' names(nm$nonmem$problem$estimation)

read_nm.run = function(
  x,
  directory = getOption("nmDir", getwd()), 
  quiet = FALSE,
  clean = TRUE,
  ...
){
  stopifnot(is.character(x), length(x) == 1)
  xmlFile <- file.path(directory, x, paste0(x, ".xml"))
  class(xmlFile) <- 'file'
  if(!(file.exists(xmlFile))){
   res <- try(
     nm_unzip(
       run = x,
       path = file.path(directory, x),
       quiet = TRUE
     )
   )
   if(inherits(res,'try-error'))warning('unzip error creating ', xmlFile)
  } else {
     clean <- FALSE # do not clean up a file you didn't create
  }
  result <- read_nm(xmlFile, quiet = quiet, ...)
  if (clean) file.remove(xmlFile)
  return(result)
}

#' Harvest Model Item Definitions for NONMEM
#' 
#' Harvests model item definitions for NONMEM object.
#' @export
#' @return definitions data.frame
#' @param x nonmem, i.e. output of \code{\link{read_nm}}
#' @param ... passed to \code{\link[nonmemica]{definitions}}
#' @family nm
#' @seealso read_nm
definitions.nonmem <- function(x, ...){
   # nonmem class is assigned by read_nm to 
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
   defs <- definitions(x = '', ctlfile = file, ...) # x is superfluous if ctlfile supplied
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
#' See also \code{\link{read_nm}} which returns this class.
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
#' @param ... passed to \code{\link[pmxTools]{get_est_table}} and \code{\link[nonmemica]{definitions}}
#' @param meta whether to merge metadata (labels etc.) from control stream
#' @importFrom nonmemica definitions safe_join
#' @family nm
get_est_table.nonmem <- function(
   x, 
   thetaLabels = NULL, 
   omegaLabels = NULL, 
   sigmaLabels = NULL, 
   sigdig = 3,
   ...,
   meta = TRUE
){
   y <- NextMethod()
   if(meta){
   z <- definitions(x, ...)
   names(z)[names(z) == 'item'] <- 'Parameter'
   z$Parameter <- as_pmx_canonical(z$Parameter)
   z <- z[z$Parameter %in% y$Parameter,, drop = FALSE]
   y <- safe_join(y, z, by = intersect(names(y), names(z)))
   }
   class(y) <- union('nm_est_table', class(y))
   y
}

#' Convert Parameter Names to pmxTools Style
#' 
#' Converts parameter names from nonmemica \code{link[nonmemica]{nms_canonical}}
#' to pmxTools style.  I.e., theta_01 becomes THETA1, and 
#' omega_01_01 becomes OM1,1.
#' 
#' @export
#' @return character
#' @param x character
#' @param ... ignored
#' @family nm
#' @importFrom magrittr %<>%
#' @importFrom dplyr case_when
#' @examples
#' as_pmx_canonical(
#'  c(
#'    'theta_15',
#'    'omega_01_01',
#'    'omega_01_02',
#'    'sigma_01_01',
#'    'sigma_02_01'
#'  )
#' )
#' 
as_pmx_canonical <- function(x, ...){
   model <- '^(theta|omega|sigma)_(\\d+)(_(\\d+))?$'
   term <- sub(model, '\\1', x)
   ind1 <- sub(model, '\\2', x)
   ind2 <- sub(model, '\\4', x)
   suppressWarnings({
   d <- data.frame(
      term = toupper(term), 
      ind1 = as.character(as.integer(ind1)), 
      ind2 = as.character(as.integer(ind2))
   )
   })
   d %<>% mutate(
      short = case_when(
         term == 'THETA' ~ 'TH',
         term == 'OMEGA' ~ 'OM',
         term == 'SIGMA' ~ 'SG',
         TRUE ~ term
      )
   )
   d %<>% mutate(com = paste(ind1, ind2, sep = ','))
   d %<>% mutate(name = case_when(ind1 != ind2 ~ short, TRUE ~ term))
   d %<>% mutate(num =  case_when(ind1 != ind2 ~ com, TRUE ~ ind1))
   d %<>% mutate(token = paste0(name, num))
   d$token
}
