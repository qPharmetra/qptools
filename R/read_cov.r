#' Read NONMEM COV Results
#' 
#' Reads NONMEM COV results.
#' Generic, with method \code{\link{read_cov.character}}
#' 
#' @export
#' @keywords internal
#' @family cov
#' @param x object of dispatch
#' @param ... passed
read_cov <- function(x, ...)UseMethod('read_cov')

#' Read NONMEM COV Results for Character
#' 
#' Reads NONMEM COV results for class character using \code{\link{read_gen.character}}.
#' 
#' @export
#' @family cov
#' @importFrom utils file_test
#' @param x character: a file path, or the name of a run in 'directory', or cov content
#' @param directory character: optional location of x
#' @param extension character: extension identifying cov files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
#' @param clue a text fragment expected to occur in cov files
#' @param ... passed arguments
#' @return length-one character of class 'cov'
#' @examples
#' library(magrittr)
#' options(nmDir = getOption('qpExampleDir'))
#' 'example1' %>% read_cov
#' 'example1.cov' %>% read_cov
#' path <- file.path(getOption('qpExampleDir'), 'example1', 'example1.cov.7z')
#' path
#' file.exists(path)
#' path %>% read_cov
#' path %>% read_cov %>% as.matrix
#' path %>% get_covmat # same
#' 'example1' %>% get_covmat
#' 'example1' %>% get_cormat
#' 'example1' %>% get_coimat

read_cov.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = getOption("nmFileCov", 'cov'),
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
   class(y) <- c('cov', 'mat') # enforced
   y
}

#' Read NONMEM COV results for 'cov'
#' 
#' Reads NONMEM COV results for class 'cov'. 
#' Just returns its argument, which is already the result of reading COV.
#' 
#' @export
#' @keywords internal
#' @family cov
#' @param x class 'cov'
#' @param ... ignored
#' @return character vector of class 'cov'
read_cov.cov <- function(x, ...) x


#' Extract a Matrix of a Converged NONMEM Run
#'
#' Parses a 'mat' object (see e.g. \code{\link{read_cov}}) as a list 
#' of one data.frame for each estimation method
#' @param x 'mat' object, e.g. output of \code{\link{read_cov.character}}
#' @param ... ignored
#' @return list of matrices as data frames
#' @export
#' @family mat
# @importFrom Hmisc unPaste
#' @importFrom stringr str_trim
#' @examples
#'
#' cov <- read_cov('example1', directory = getOption("qpExampleDir"))
#' covmat =  as.matrix(cov)
#' names(covmat)
#' names(covmat[[1]])
#' lapply(covmat, dim)
#'

as.matrix.mat = function (x, ...){
   # currently x is length 1
   # restore lines
   x <- strsplit(x, split = '\n')
   x <- x[[1]]
   locs = grep("TABLE", substring(x, 1, 6))
   covNames = substring(unlist(unPaste(x[locs], ":")[[2]]),2)
   int = unPaste(x[locs], sep = ":")[[1]]
   int = gsub("[.]", "", int)
   int = gsub(" ", "", int)
   tabnums = extract_number(int)
   locs = c(locs, length(x))
   locations = list(NULL)
   for (i in 1:length(locs[-length(locs)])) {
      locations[[i]] = x[seq((locs[i] + 1), (locs[i + 1]))]
   }
   x = lapply(locations, function(x) if (length(grep("TABLE",x)) > 0)
      x[-grep("TABLE", x)]
      else x)
   names(x) = tabnums
   covmat = lapply(x, extract_varcov)
   names(covmat) = covNames
   return(covmat)
}

#' Extract a Matrix of a Converged NONMEM Run
#'
#' Parses a 'mat' object (see \code{\link{read_cov}}) as a list 
#' of one data.frame for each estimation method
#' @param x 'mat' object, e.g. output of \code{\link{read_cov.character}}
#' @param ... ignored
#' @return list of covariance matrices as data frames
#' @export
#' @family mat
#' 
as.list.mat <- function(x, ...)as.matrix(x, ...)

#' Get the covariance matrix from an already parsed .cov output file.
#' @section Notes:
#' function not to be called alone - is called by qP function nm.covmat.extract inside get.covmat
#' @param text A character or numeric string containing the .cov output.
#' @return A named list. The sole item in the list should have a name that is the estimation method
#' used (e.g. "First Order Conditional Estimation with Interaction").  That named item will be a
#' data frame containing the covariance matrix.
# @importFrom Hmisc unPaste
#' @keywords internal
#' @export
#' @family nm
#' @examples
#' \dontrun{
#' nm_unzip(
#'   path = file.path(getOption("qpExampleDir"),"run11"),
#'   x = "run11", extension = ".cov"
#' )
#' x = scan(
#'   file = file.path(getOption("qpExampleDir"),"run11","run11.cov"),
#'   what = "character",sep = "\n", quiet = T
#' )
#'
#' ## the heart of the function: parse space delimited text into a matrix
#' cov = extract.varcov(x[-1])
#'
#' ## warning: this matrix is LARGE. View only start and end of output
#' head(cov)
#' tail(cov)
#'
#' file.remove(file.path(getOption("qpExampleDir"),"run11","run11.cov")) ## clean things up
#' }

extract_varcov = function(text)
{
   nams = substring(text[-1], 2, 13)
   covmat = lapply(lapply(substring(text[-1], 15), unPaste, sep = " "), function(x)
      as.numeric(unlist(x[!is.element(x, c("", " "))])))
   names(covmat) = nams
   covmat = as.data.frame(do.call("rbind", covmat))
   names(covmat) = str_trim(nams)
   covmat
}

#' Get Covariance Matrix
#' 
#' Gets covariance matrix.
#' Generic, with methods \code{\link{get_covmat.character}} and \code{\link{get_covmat.cov}}.
#' 
#' @export
#' @family cov
#' @param x object of dispatch
#' @keywords internal
#' @param ... passed arguments
get_covmat <- function(x, ...)UseMethod('get_covmat')

#' Get Covariance Matrix for Character
#' 
#' Gets covariance matrix for character.
#' 
#' @export
#' @family cov
#' @param x character: a file path, or the name of a run in 'directory', or cov content
#' @param directory character: optional location of x
#' @param extension character: extension identifying cov files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
#' @param clue a text fragment expected to occur in cov files
#' @param ... passed arguments
#' @return list of covariance matrices as data frames
get_covmat.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = getOption("nmFileCov", 'cov'),
      quiet = TRUE, 
      clean = TRUE,
      nested = TRUE,
      clue = 'TABLE NO.',
      ...
){
   y <- read_cov(
      x,
      directory = directory,
      extension = extension,
      quiet = quiet,
      clean = clean,
      nested = nested,
      clue = clue,
      ...
   )
   get_covmat(y, ...)
}
#' Get Covariance Matrix for COV
#' 
#' Get covariance matrix for COV.
#' 
#' @export
#' @keywords internal
#' @family cov
#' @param x cov
#' @param ... passed arguments
#' @return list of covariance matrices as data frames
get_covmat.cov <- function(x, ...)as.matrix(x, ...)

