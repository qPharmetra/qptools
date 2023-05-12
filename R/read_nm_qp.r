globalVariables('num')
#' Read the entire XML output of a Converged NONMEM Run
#' 
#' Extracts the output of a completed NONMEM run that is stored in an XML file.
#' 
#' @param run character string in the form of 'run1'
#' @param path root directory of the run folder where .cov file resides
#' @param clear_zip should the unzipped cov file be removed when done (defaults to T)
#' @param quiet suppresses the messages (defaults to not suppressing)
#' @return pmx_nm: List of all elements of the XML output of a NONMEM model run
#' @export
#' @family nm
#' @importFrom pmxTools read_nm
#' @examples
#'
#' xml1 = read_nm_qp(run="example1", path = getOption("qpExampleDir"))
#' names(xml1)
#' names(xml1$nonmem)
#' names(xml1$nonmem$problem)
#' names(xml1$nonmem$problem$estimation)

read_nm_qp = function(
  run,
  path = getOption("nmDir", getwd()),
  clear_zip = TRUE,
  quiet = FALSE
){
  xmlFile <- file.path(path, run, paste0(run, ".xml"))
  if(!(file.exists(xmlFile))){
    nm_unzip(
       run = run,
       path = file.path(path, run),
       quiet = TRUE
    )
  }
  result = read_nm(fileName = xmlFile, quiet = quiet)
  if (clear_zip)
    file.remove(xmlFile)
  class(result) <- 'nonmem'
  return(result)
}

#' Harvest Model Item Definitions for NONMEM
#' 
#' Harvests model item definitions for NONMEM object.
#' @export
#' @return definitions data.frame
#' @param x nonmem, i.e. output of \code{\link{read_nm_qp}}
#' @param ... passed to \code{\link[nonmemica]{definitions}}
#' @family nm
#' @seealso read_nm_qp
definitions.nonmem <- function(x, ...){
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
