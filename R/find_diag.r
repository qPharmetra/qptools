globalVariables(c('nms', 'pos','pos_om','pos_sg','th','om', 'sg','what', 'diag','on', 'pclass','parameter'))

#' Find Diagonal Elements of a NONMEM Parameter Table
#' 
#' Find diagonal elements of a NONMEM parameter table.
#' Generic, with method \code{\link{find_diag.data.frame}}
#' 
#' @export
#' @keywords internal
#' @family ext
#' @param x object of dispatch
#' @param ... passed
find_diag <- function(x, ...) UseMethod('find_diag')

#' Find Diagonal Elements of a NONMEM Parameter Table for Character
#' 
#' Find diagonal elements of a NONMEM parameter table for 'character'. 
#' @export
#' @keywords internal
#' @param x character: a file path, or the name of a run in 'directory', or ext content
#' @param directory character: optional location of x
#' @param extension character: extension identifying ext files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
#' @param clue a text fragment expected to occur in cov files
#' @param ... passed arguments
#' @return list of data.frames
#' @importFrom dplyr mutate select
#' @importFrom stringr str_split
#' @importFrom magrittr %<>%
#' @examples 
#' library(magrittr)
#' options(nmDir = getOption("qpExampleDir"))
#' "example2" %>% find_diag
#' 
find_diag.character = function(
    x, 
    directory = getOption("nmDir", getwd()), 
    extension = getOption("nmFileExt", 'ext'),
    quiet = TRUE, 
    clean = TRUE,
    nested = TRUE,
    clue = 'ITERATION',
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
  nms <- names(as.list(ext))
  out <- lapply(ext %>% as.list %>% summary, find_diag, ...)
  if(length(nms) == length(out)){
    names(out) <- nms
  }
  return(out)
}

#' Find Diagonal Elements of a NONMEM Parameter Table for Data Frame
#' 
#' Find diagonal elements of a NONMEM parameter table for 'data.frame'.
#' @export
#' @importFrom dplyr mutate select
#' @importFrom stringr str_split
#' @importFrom magrittr %<>%
#' @param x data.frame of class 'ext'
#' @param ... passed arguments
#' @return data.frame
#' @seealso [find_diag_template()]
#' @examples
#' library(magrittr)
#' options(nmDir = getOption("qpExampleDir"))
#' "example2" %>% read_ext %>% as.list %>% summary -> tmp
#' tmp[[1]] %>% find_diag
#' "example2" %>% find_diag
#' 
#' #an error is thrown in case a run does not minimize or terminates without parseable content
#' #in that case use find_diag_template instead

find_diag.data.frame = function(x,...) 
{
  nms = row.names(x)
  th = nms[grep("THETA",nms)]
  om = nms[grep("OMEGA",nms)]
  sg = nms[grep("SIGMA",nms)]
  pos_om = lapply(str_split(om,pattern=","),extract_number) %>% 
    unlist %>% matrix(nrow=2) %>% t %>% data.frame
  pos_sg = lapply(str_split(sg,pattern=","),extract_number) %>% 
    unlist %>% matrix(nrow=2) %>% t %>% data.frame
  names(pos_om) = names(pos_sg) = c("one","two")
  pos_th = data.frame(one=1:length(th), two=1:length(th))
  pos = rbind(pos_th,pos_sg, pos_om)
  pos %<>% mutate(parameter = nms)
  pos %<>% mutate(pclass = substring(nms,1,5))
  pos %<>% mutate(on = c(rep(0,length(th)),
                                  as.numeric(pos_sg$one==pos_sg$two),
                                  as.numeric(pos_om$one==pos_om$two)
  ))
  pos %<>% mutate(shrinkage=NA) 
  pos %>% select(parameter,pclass,on)
}

