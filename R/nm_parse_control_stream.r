globalVariables(c('ctl','ctlSections'))

# name:     nm_parse_control_stream
# purpose:  function to read NONMEM control stream and parse it out as named list
# input:    run number (character), optionally the path where the NM run resides
# output:   list with as many (named) element as there are $.... elements in the cotnrol stream,
# note:     depends on qP function nm.remove.section

# ROXYGEN Documentation
#' Parse NONMEM control stream
#'
#' Parses NONMEM control stream and list all elements into sections
#'
#' @export
#' @family lst
#' @param x character: object of dispatch
#' @param directory character: optional location of x
#' @param extension length-two character: extensions identifying ext and lst files
#' @param nested length-two logical: are the ext and lst files nested within the run 
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param clue a text fragment expected to occur in cov files
#' @param ... passed arguments
#' @importFrom stringr str_split str_remove
#' @importFrom magrittr %>% 
# @importFrom Hmisc unPaste
#' @return list
#' @examples 
#' library(magrittr)
#' 
#' "run103" %>% nm_parse_control_stream
#' nm_parse_control_stream("example1", directory = getOption("qpExampleDir"),extension=c("ext","ctl"))
#'

nm_parse_control_stream <- function(x,
                                    directory = getOption("nmDir", getwd()),
                                    extension = c(getOption("nmFileExt", 'ext'),
                                                  getOption("nmFileMod", 'mod')),
                                    nested = c(TRUE, FALSE),
                                    quiet = TRUE,
                                    clean = TRUE,
                                    clue = '\\$PROB',
                                    ...
)
{
  ctl = read_mod(x, extension = extension[[2]],...)
  ctl = strsplit(ctl, split = "\n") %>% .[[1]]
  ctlSections = ctl[grep("\\$", ctl)]
  ctlSections = ctlSections[substring(gsub(" ","",ctlSections),1,1)!= ";"]
  ctlSections = unlist(lapply(ctlSections, function(x) unPaste(x,sep = " ")[[1]]))
  ctlSections = substring(unique(ctlSections), 2)
  ctlSections = ctlSections[ctlSections!= ""]
  nams = ctlSections
  
  ctlSections = lapply(ctlSections
                       , function(x, ctl) {
                         as.vector(
                           unlist(
                             invisible(nm_remove_section(x,ctl)[[2]])
                           ), "character")
                       }
                       , ctl = ctl
  )
  names(ctlSections) = nams
  return(ctlSections)
}

nm_remove_section <- function(secNames, ctl){
  # remove a section of a control stream
  # secNames = character vector containing the names of the sections to remove
  # ctl = character vector containing the NONMEM control stream
  #
  # output is a list -- ctl is the edited control stream
  # savSecs is a list containing the sections that were removed
  
  ## check if they are there
  check.if.they.are.there = sapply(1:length(secNames), function(i, secNames,ctl){
    str = paste("\\$", secNames[i], sep = "")
    length(grep(str, ctl))>0
  }, secNames = secNames, ctl = ctl)
  secNames = secNames[check.if.they.are.there]
  saveSecs = vector("list", length(secNames))
  
  LEN = length(secNames)
  for(i in 1:LEN){ #i = 9 ;LEN = 7
    str = paste("\\$", secNames[i], sep = "")
    nsec = length(grep(str, ctl))    # likely more than one section of a particular type
    names(saveSecs)[i] = secNames[i]
    saveSecs[[i]] = vector("list", nsec)
    # Identify and remove the next section containing str
    for(j in 1:nsec){ #j = 2
      if(any(grepl(str,ctl))){
        # Identify all sections
        secs = data.frame(sec = ctl[grep("\\$", ctl)], ind = grep("\\$", ctl))
        secs$nextS = c(secs$ind[2:nrow(secs)], length(ctl))
        thisSec = grep(str, secs$sec)[1]
        startS = secs$ind[thisSec]
        endS = ifelse(secs$nextS[thisSec] == length(ctl), length(ctl),
                      secs$nextS[thisSec]-1)
        saveSecs[[i]][[j]] = ctl[startS:endS]
        if(startS<endS) ctl = ctl[-(startS:endS)] else ctl = ctl[-startS]
      }
    }
  }
  return(list(ctl = ctl, saveSecs = saveSecs))
}
