
# ROXYGEN Documentation
#' Extract the Variance-Covariance Matrix of a Converged NONMEM run
#' @description Unzips the zipped *.cov file and parses the elements for each estimation method into a data frame
#' @param run character string in the form of 'run1'
#' @param path root directory of the run folder where .cov file resides
#' @param extension extension of the file to parse. Defaults to 'cov' but could also be 'cor'
#' @param clear_zip should the unzipped cov file be removed when done (defaults to T)
#' @param quiet suppresses the messages (defaults to not suppressing)
#' @return List of covariance matrices as data frames
#' @export
#' @family nm
#' @importFrom Hmisc unPaste
#' @examples
#'
#' getOption("qpExampleDir")
#' run1.covmat =  nm_covmat_extract(run = "example1", path = getOption("qpExampleDir"))
#' names(run1.covmat)
#' names(run1.covmat[[1]])
#' lapply(run1.covmat, dim)
#'

nm_covmat_extract = function (run,
                              path = getOption("nmDir"),
                              extension = "cov",
                              clear_zip = TRUE,
                              quiet = FALSE)
{
  covFile = file.path(path, run, paste0(run, ".", extension))
  if (!file.exists(covFile))
    nm_unzip(run = run, path = file.path(path,run), extension = "cov", quiet=T)
  internalDir = file.path(path, run)
  if (!quiet) {
    message("Reading ", covFile)
  }
  covText = scan(file = covFile,
                 what = "character", sep = "\n", quiet = TRUE)
  locs = grep("TABLE", substring(covText, 1, 6))
  covNames = substring(unlist(Hmisc::unPaste(covText[locs], ":")[[2]]),2)
  int = Hmisc::unPaste(covText[locs], sep = ":")[[1]]
  int = gsub("[.]", "", int)
  int = gsub(" ", "", int)
  tabnums = extract_number(int)
  locs = c(locs, length(covText))
  locations = list(NULL)
  for (i in 1:length(locs[-length(locs)])) {
    locations[[i]] = covText[seq((locs[i] + 1), (locs[i + 1]))]
  }
  covText = lapply(locations, function(x) if (length(grep("TABLE",x)) > 0)
    x[-grep("TABLE", x)]
    else x)
  names(covText) = tabnums
  covmat = lapply(covText, extract_varcov)
  names(covmat) = covNames
  if(clear_zip) file.remove(covFile)
  return(covmat)
}

# ROXYGEN Documentation
#' Get the covariance matrix from an already parsed .cov output file.
#' @section Notes:
#' function not to be called alone - is called by qP function nm.covmat.extract inside get.covmat
#' @param text A character or numeric string containing the .cov output.
#' @return A named list. The sole item in the list should have a name that is the estimation method
#' used (e.g. "First Order Conditional Estimation with Interaction").  That named item will be a
#' data frame containing the covariance matrix.
#' @importFrom Hmisc unPaste
#' @keywords internal
#' @export
#' @family nm
#' @examples
#' \dontrun{
#' nm.unzip(
#'   path = file.path(getOption("qpExampleDir"),"run11"),
#'   run = "run11",extension = ".cov"
#' )
#' covText = scan(
#'   file = file.path(getOption("qpExampleDir"),"run11","run11.cov"),
#'   what = "character",sep = "\n", quiet = T
#' )
#'
#' ## the heart of the function: parse space delimited text into a matrix
#' cov = extract.varcov(covText[-1])
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
  covmat = lapply(lapply(substring(text[-1], 15), Hmisc::unPaste, sep = " "), function(x)
    as.numeric(unlist(x[!is.element(x, c("", " "))])))
  names(covmat) = nams
  covmat = as.data.frame(do.call("rbind", covmat))
  names(covmat) = nams
  covmat
}

#nm_covmat_extract(run = "run1298")
