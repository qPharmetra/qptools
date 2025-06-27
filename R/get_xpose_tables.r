globalVariables(c('item', 'se_est', 'estimate', 'fix' ))
#' Compile all Xpose Output Datasets into one Dataset
#' 
#' Compiles a NONMEM output files as single dataset.
#' 
#' @export
#' @return data.frame
#' @family runrecord
#' @importFrom stringr str_split str_squish
#' @importFrom magrittr %<>%
#' @importFrom tibble tibble
#' @importFrom dplyr bind_cols as_tibble any_of
#' @param x character vector of run names, e.g. c('run1','run2')
#' @param directory path to working directory
#' @param pattern regular expression matching xpose table file names
#' @param ... ignored
#' @examples
#' library(magrittr)
#' options(nmDir = getOption('qpExampleDir'))
#' 'run100' %>% get_xpose_tables

get_xpose_tables = function (
    x, 
    directory = getOption("nmDir"),
    pattern = '(sd|pa|ca|co|my|sim)tab|.tab',
    ...
){
  myPath = file.path(directory, x)
  if(!dir.exists(myPath)) {message(paste(myPath, "does not exist.")); return()}
  
  
  tabNames = dir(myPath)[grepl(pattern, dir(myPath))]
  
  handler <- function(i,x,directory,tabNames){
     thisTabName <- tabNames[i]
     thisFilePath <- file.path(directory,x,thisTabName)
     tab <- read.table(thisFilePath, skip = 1, header = TRUE)
     if('ID' %in% names(tab)){
        if(nrow(tab) > 1){
           first <- tab$ID[[1]]
           second <- tab$ID[[2]]
           if(!identical(first, second)){
              warning('I saw ', first, ' in the first row and ', second, ' in the second row of ', thisFilePath, ': probably first line of the value of get_xpose_tables() is corrupt')
           }
        }
     }
     tab
  }
  
  out = lapply(1:length(tabNames), handler, directory=directory, x=x, tabNames=tabNames)
  data = out[[1]]
  suppressMessages(
    for(i in seq_along(out)[-1])
    {
      nms = names(data)
      new_nms = names(out[[i]])
      new_nms = new_nms[!new_nms %in% nms]
      if (length(new_nms) > 0)
        data %<>% bind_cols(out[[i]][new_nms])
    }
    )
  data %>% as_tibble
}

  # read_nmTabs <- function(path.in = myPath, tabNames.in = tabNames) {
  #   if (length(tabNames.in) > 0) {
  #     nmTab = read.table(paste(path.in, tabNames.in[1], 
  #                              sep = "/"), skip = 1, header = TRUE)
  #     if (length(tabNames.in) > 1) {
  #       for (tabName in tabNames[2:length(tabNames)]) {
  #         tmp = read.table(paste(path.in, tabName, sep = "/"), 
  #                          skip = 1, header = TRUE)
  #         if (!all(!(names(tmp) %in% names(nmTab)) == FALSE)) 
  #           nmTab = cbind(nmTab, tmp[, !(names(tmp) %in% 
  #                                          names(nmTab))])
  #       }
  #     }
  #     return(nmTab)
  #   }
  # }
  # out <- read_nmTabs()
  # if(!length(out))stop('found no tables with names matching ', pattern)
  # out
