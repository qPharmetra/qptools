#' Parse the NONMEM List File Data Record
#' 
#' Parses the NONMEM 'lst' file data record.
#' 
#' @export
#' @keywords internal
#' @family lst
#' @param x character: a file path, or the name of a run in 'directory', or lst content
#' @param directory character: optional location of x
#' @param extension character: extension identifying lst files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the lst file nested within the run directory?
#' @param clue a text fragment expected to occur in lst files
#' @param remove_at_sign whether to remove the 'at' symbol
#' @param ... passed arguments
#' @return list
#' @importFrom stringr str_split str_squish
#' @examples
#'   library(magrittr)
#'   library(nonmemica)
#'   options(nmDir = getOption('qpExampleDir'))
#'   'run100' %>% as.model %$% data %>% writeLines
#'   'run100' %>% datafile %>% suppressWarnings
#' # 'run100' %>% ignored # datafile not actually present
#'   'run100' %>% nm_parse_dollar_data
#' 
nm_parse_dollar_data = function(
   x, 
   directory = getOption("nmDir", getwd()), 
   extension = getOption("nmFileLst", 'lst'),
   quiet = TRUE, 
   clean = TRUE,
   nested = FALSE,
   clue = '\\$PROB',
   remove_at_sign = TRUE,
   ...
){
  lst = read_lst(
    x,
    directory = directory,
    extension = extension,
    quiet = quiet,
    clean = clean,
    nested = nested,
    clue = clue,
    ...
  )
  lst <- strsplit(lst, '\n')[[1]]
  
  d = str_split(str_squish(lst[grep("[$]DATA", lst)]), " ")[[1]][-1]
  dta = d[[1]]
  
  ignores = str_split(str_squish(d[grep("IGNORE", d)]), " ") %>%
    unlist()
  ignores = ignores[grep("IGNORE", ignores)]
  
  accepts = str_split(str_squish(d[grep("ACCEPT", d)]), " ") %>%
    unlist()
  accepts = accepts[grep("ACCEPT", accepts)]
  
  if(remove_at_sign) ignores = ignores[!grepl("@",ignores)]
  ignores_glued = if(is.null(ignores)) NULL else glue_operators(ignores)
  accepts_glued = if(is.null(accepts)) NULL else glue_operators(accepts)
  
  return(list(data = dta, ignores = ignores_glued, accepts = accepts_glued))
}

nm_parse_2r = function(x)
{
  x = gsub("[.]GT[.]", " > ", x)
  x = gsub("[.]GE[.]", " >= ", x)
  x = gsub("[.]LT[.]", " < ", x)
  x = gsub("[.]LE[.]", " <= ", x)
  x = gsub("[.]EQ[.]", " == ", x)
  x = gsub("[.]NE[.]", " != ", x)
  x = gsub("ACCEPT=", "", x)
  x = gsub("IGNORE=", "", x)
  x = substring(x, length(x))
  return(x)
}

glue_operators = function(x)
{
  x = stringr::str_replace(x, "[(]+", "")
  x = stringr::str_replace(x, "[)]+", "")
  x = paste(sapply(x, nm_parse_2r), collapse = " & ")
  x
}
