#' Load Modeled Dataset
#' 
#' Returns the modeled dataset, given details about the model run.
#' If visibility is TRUE, the column VISIBLE is added (it is an error if 
#' VISIBLE already present) with integer 1 or 0 indicating which records
#' were visible to NONMEM.
#' 
#' @export
#' @family lst
#' @param x character run name
#' @param directory path to directory containing the run
#' @param extension extension for model file, e.g. 'mod' or 'ctl'
#' @param visibility logical: include VISIBLE flag indicating ignore/accept results?
#' @param read.input if visibility is TRUE, passed to \code{\link[nonmemica]{ignored}}
#' @param nested passed to \code{\link[nonmemica]{datafile}} and \code{\link[nonmemica]{ignored}}
#' @param ... passed to 
#'  \code{\link[nonmemica]{ignored}},
#'  \code{\link[nonmemica]{datafile}}, and
#'  \code{\link[yamlet]{io_csv}}
#' @return data.frame
#' @importFrom nonmemica ignored datafile psn_nested
#' @importFrom yamlet io_csv decorate
#' @importFrom utils read.csv
#' @examples
#' library(magrittr)
#' dir <- getOption('qpExampleDir')
#' options(nmDir = dir)
#' 
#' # This example breaks because we need to skip the first line of the dataset:
#' 
#' 'example2' %>%
#'   load_modeled_dataset(extension = 'ctl', nested = FALSE) %>% 
#'   head(3)
#' 
#' # This example is difficult but correct:
#' 
#' load_modeled_dataset(
#'   'example2',              # exists in the example NONMEM directory
#'   directory = dir,         # created above
#'   extension = 'ctl',        # NOT mod, creates problems below
#'   nested = FALSE,          # cannot guess whether ctl files are inside run directories
#'   read.input = list(       # a method to read the data for visibility check
#'     read.csv, 
#'     header = TRUE, 
#'     skip = 1               # associated dataset has intro comment! passed to read.csv
#'   ),
#'   visibility = TRUE,       # call for visibility check
#'   skip = 1                 # passed again to io_csv() when acquiring data!
#' ) %>% head(3)

load_modeled_dataset <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = getOption("nmFileMod", 'mod'),
      visibility = FALSE,
      read.input=list(read.csv,header=TRUE,as.is=TRUE),
      nested = getOption('nested', psn_nested),
      ...
){
   dat <- datafile(x, project = directory, ext = extension, nested = nested, ... )
   dat <- io_csv(dat, ...)
   vis <- rep(1, nrow(dat))
   if(visibility){
      ignored <- ignored(
         x, 
         read.input = read.input, 
         ext = extension, 
         project = directory, 
         nested = nested, 
         ...
      )
      vis <- as.integer(!ignored)
      if('VISIBLE' %in% names(dat))stop('cannot add VISIBLE because it is already present')
      dat$VISIBLE <- vis
      dat <- decorate(dat, 'VISIBLE: [Record Visibility, [ Ignored: 0, Visible: 1]]')
   }
   dat
}
