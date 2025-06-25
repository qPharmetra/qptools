globalVariables(c('th','om', 'sg', 'diag_df','on', 'pclass','parameter','idx','sloc1','loc2','loc3','loc4','txt1','txt2','txt3','sr','fr','pattern_theta','pattern_eta','pattern_sigma'))

#' Create template NULL value Diagonal Elements of a NONMEM Parameter Table
#' 
#' use first component of NONMEM output to read THETA, SIGMA, and OMEGA structure
#' and turn this into a table that informs which parameters are on-diagonal elements (on=1)
#' and which are not (on=0). This will be used by \code{\link{nm_params_table}} 
#' to have a column to (de)select off-diagnal elements in an parameter table.
#'  
#' @export
#' @keywords internal
#' @family lst
#' @param x object of dispatch
#' @param x character: a file path, or the name of a run in 'directory', or ext content
#' @param directory character: optional location of x
#' @param extension length-two character: extensions identifying ext and lst files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested length-two logical: are ext and lst files nested within the run directory?
#' @param ... passed
#' @examples
#' library(magrittr)
#' library(dplyr)
#' options(nmDir = getOption("qpExampleDir"))
#' "run105" %>% find_diag_template()

find_diag_template = function(x,
                              directory = getOption("nmDir", getwd()), 
                              extension = c(getOption("nmFileLst", 'ext'),
                                            getOption("nmFileLst", 'lst')),
                              quiet = TRUE, 
                              clean = TRUE,
                              nested = c(TRUE, FALSE),
                              clue="$PROB",
                              ...)
  {
  lst <- read_lst(
    x, 
    directory = directory, 
    extension = extension[[2]], 
    quiet = quiet, 
    clean = clean,
    nested = nested[[2]],
    ...
  )
  lst = lst %>% strsplit(., split="\n") %>% .[[1]]

  ## pull text component of lst output that we need
  loc1 = grep("TOT. NO. OF INDIVIDUALS:", lst)
  loc2 = grep("0INITIAL ESTIMATE OF THETA:", lst)
  txt1 = lst[loc1:loc2]

  # simple internal functions to get the lower traingle of the cov blocks
  fr = function(x) sapply(1:x,function(y)rep(y,times=y)) %>% unlist()
  sr = function(x) sapply(1:x,function(y) 1:y) %>% unlist()

  # regular format
  #"0OMEGA HAS SIMPLE DIAGONAL FORM WITH DIMENSION:   2"                                                                      
  #"0SIGMA HAS SIMPLE DIAGONAL FORM WITH DIMENSION:   1" 
  
  ## when BLOCK exists:
  #"0OMEGA HAS BLOCK FORM:"                      "
  block = c(FALSE,FALSE)
  if(any(grepl("0OMEGA HAS BLOCK FORM:",txt1))) block[1] = TRUE
  if(any(grepl("0SIGMA HAS BLOCK FORM:",txt1))) block[2] = TRUE

  if(any(block)){
    locpk = lst[grep("[$]", lst)]
    loc1 = locpk[c(grep("[$]PK",locpk), grep("[$]PRED",locpk))[1]][1] %>% str_squish()
    loc2 = locpk[c(grep("[$]PK",locpk), grep("[$]PRED",locpk))[1]+1][1] %>% str_squish()
    loc3 = locpk[grep("[$]ERROR",locpk)][1] %>% str_squish()
    loc4 = locpk[grep("[$]ERROR",locpk)+1][1] %>% stringr::word() 

    loc1 = grep(paste0("[$]",substring(loc1,2)) ,lst)+1
    loc2 = grep(paste0("[$]",substring(loc2,2)) ,lst)-1
    loc2 = loc2[whichClosestToZero(abs(loc1 - loc2))] # was Hmisc::whichClosest before 0.3.2
    loc3 = grep(paste0("[$]",substring(loc3,2)) ,lst)+1
    loc4 = grep(paste0("[$]",substring(loc4,2)) ,lst)-1 
    loc4 = loc4[whichClosestToZero(abs(loc3 - loc4))]
    
    txt2 = lst[loc1:loc2]
    txt3 = lst[loc3:loc4]
  }
  
  pattern_theta <- "(?<=PLACEHOLDER\\()\\d+"
  pattern_eta <- "(?<=ETA\\()\\d+"
  pattern_eps <- "(?<=EPS\\()\\d+|(?<=ERR\\()\\d+"
  
  ## extract dimensions of THETA, OMEGA, SIGMA
  if(!block[1]) {
    th = txt1[grep("0LENGTH OF THETA:",txt1)] %>% substring(.,2) %>% extract_number
    om = txt1[grep("0OMEGA HAS", txt1)] %>% substring(., 2) %>% extract_number
    sg = txt1[grep("0SIGMA HAS", txt1)] %>% substring(., 2) %>% extract_number
  } else {
    txt2_modified <- gsub("THETA", "PLACEHOLDER", txt2)
    th = lapply(txt2_modified, function(y) {
      matches <- regmatches(y, gregexpr(pattern_theta, y, perl=TRUE))
      as.numeric(unlist(matches))
      }
      ) %>% unlist %>% max
    om = lapply(txt2_modified, function(y) {
           matches <- regmatches(y, gregexpr(pattern_eta, y, perl=TRUE))
           as.numeric(unlist(matches))
      }
      ) %>% unlist %>% max
    sg = lapply(txt3, function(y) {
      matches <- regmatches(y, gregexpr(pattern_eps, y, perl=TRUE))
      as.numeric(unlist(matches))
    }) %>% unlist %>% max
    
  }
    # TTB 2024-10-31 Normally sg would be numeric.
    # Here problematic results are flagged as dummy integer, for removal.

  if(length(sg) == 0)sg <- integer(1)
  if(length(sg) > 1) stop('not expecting sg to be longer than 1')
  if(is.na(sg)) sg <- integer(1) 
  if(sg == 0) sg <- integer(1)
  if(is.infinite(sg)) sg <- integer(1)

## currently running on block[1] only
## should be sufficient
  
  diag_df = data.frame(parameter = c(
      paste0("THETA", 1:th),
      paste0("SIGMA(", fr(sg), ",", sr(sg), ")"),
      paste0("OMEGA(", fr(om), ",", sr(om), ")")
    )) %>%
      mutate(pclass = parameter %>% substring(., 1, 5), on = 0)
  
  # diag_df %<>% mutate(idx = c(rep(1,th),fr(sg)*10+sr(sg),fr(om)*10+sr(om)))
  # diag_df %<>% mutate(on=as.numeric((idx%%11)==0)) # mod 11 gives false positives
  # diag_df %<>% select(-idx)

    diag_df %<>% mutate_cond(pclass %in% c('SIGMA','OMEGA'), on = c(fr(sg), fr(om)) == c(sr(sg), sr(om)))
  
  
  # TTB 2024-10-31 remove dummy value of sigma, if present.  See above.
  if(identical(sg, integer(1))){
     diag_df %<>% filter(pclass != 'SIGMA')
  }
  diag_df
}

