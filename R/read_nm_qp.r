
# ROXYGEN Documentation
#' Read the entire XML output of a Converged NONMEM Run
#' @description Extracts the output of a completed NONMEM run that is stored in an XML file.
#' @param run character string in the form of 'run1'
#' @param path root directory of the run folder where .cov file resides
#' @param clear_zip should the unzipped cov file be removed when done (defaults to T)
#' @param quiet suppresses the messages (defaults to not suppressing)
#' @return List of all elements of the XML output of a NONMEM model run
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
  return(result)
}
