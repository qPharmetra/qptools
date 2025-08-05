globalVariables(c('th','om', 'sg', 'diag_df','on', 'pclass','parameter','idx','sloc1','loc2','loc3','loc4','txt1','txt2','txt3','sr','fr','pattern_theta','pattern_eta','pattern_sigma', 'left','right'))

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
#' @importFrom nonmemica parens text2decimal
#' @examples
#' library(magrittr)
#' library(dplyr)
#' options(nmDir = getOption("qpExampleDir"))
#' "run105" %>% find_diag_template()

find_diag_template = function(
   x,
   directory = getOption("nmDir", getwd()), 
   extension = c(getOption("nmFileLst", 'ext'),
                 getOption("nmFileLst", 'lst')),
   quiet = TRUE, 
   clean = TRUE,
   nested = c(TRUE, FALSE),
   clue="$PROB",
   ...
)
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
  locA = grep("TOT. NO. OF INDIVIDUALS:", lst)
  locB = grep("0INITIAL ESTIMATE OF THETA:", lst)

  # locations must be positive definite integer
  unambiguous <- function(x){
     if(length(x) != 1) return(FALSE)
     if(is.na(x)) return(FALSE)
     if(!is.integer(x)) return(FALSE)
     if(x <= 0) return(FALSE)
     return(TRUE)
  }
  
  stopifnot(unambiguous(locA))
  stopifnot(unambiguous(locB))

  txt1 = lst[locA:locB]

  # simple internal functions to get the lower triangle of the cov blocks
  fr = function(x) rowdex(x) # sapply(1:x,function(y)rep(y,times=y)) %>% unlist()
  sr = function(x) coldex(x) # sapply(1:x,function(y) 1:y) %>% unlist()

  # regular format
  #"0OMEGA HAS SIMPLE DIAGONAL FORM WITH DIMENSION:   2"                                                                      
  #"0SIGMA HAS SIMPLE DIAGONAL FORM WITH DIMENSION:   1" 
  
  ## when BLOCK exists:
  #"0OMEGA HAS BLOCK FORM:"                      "
  block = c(FALSE,FALSE)
  if(any(grepl("0OMEGA HAS BLOCK FORM:",txt1))) block[1] = TRUE
  if(any(grepl("0SIGMA HAS BLOCK FORM:",txt1))) block[2] = TRUE

  if(any(block)){
     
     # These assume $ is the only metacharacter requiring escape
     
     # locpk = lst[grep("[$]", lst)]
     # loc1 = locpk[c(grep("[$]PK",locpk), grep("[$]PRED",locpk))[1]][1] %>% str_squish()
     # loc2 = locpk[c(grep("[$]PK",locpk), grep("[$]PRED",locpk))[1]+1][1] %>% str_squish()
     # loc3 = locpk[grep("[$]ERROR",locpk)][1] %>% str_squish()
     # loc4 = locpk[grep("[$]ERROR",locpk)+1][1] %>% stringr::word() 
     # 
     # loc1 = grep(paste0("[$]",substring(loc1,2)) ,lst)+1
     # loc2 = grep(paste0("[$]",substring(loc2,2)) ,lst)-1
     # loc2 = loc2[whichClosestToZero(abs(loc1 - loc2))] # was Hmisc::whichClosest before 0.3.2
     # loc3 = grep(paste0("[$]",substring(loc3,2)) ,lst)+1
     # loc4 = grep(paste0("[$]",substring(loc4,2)) ,lst)-1 
     # loc4 = loc4[whichClosestToZero(abs(loc3 - loc4))]
     
     # Better to treat entire string as static
     # For "$THETA  (-9,-6.16,5) ; 1. Tumor Growth Rate Constant; 1/week; LOG" 
     # str_squish removes second space following THETA

     # find all the first lines of records
     locpk = lst[grep("$", lst, fixed = TRUE)]
     
     # survey these for either $PK or $PRED
     loc0 <- grep('([$]PK)|([$]PRED)', locpk)
     
     # locations must be singular, positive, and definite
     stopifnot(unambiguous(loc0))
     
     # define start and end of pk/pred in lst as 
     # all material following loc0
     # up to but not including the location of the next record in locpk
     
     stopifnot(length(locpk) >= loc0 + 1L)
 
     # identify relevant text
     tok1 <- locpk[[loc0]]
     tok2 <- locpk[[loc0 + 1]]
     
     # find these tokens in the original text (whence they came)
     # and select "inner" material
     loc1 <- grep(tok1, lst, fixed = TRUE) + 1L
     loc2 <- grep(tok2, lst, fixed = TRUE) - 1L
     
     # apparently loc2 can have more than one "hit"
     # retain the index closest to loc1
     
     closest <- whichClosestToZero(abs(loc1 - loc2))
     loc2 <- loc2[[closest]]
     
     stopifnot(unambiguous(loc2))
     stopifnot(unambiguous(loc1))
     
     txt2 <- lst[loc1:loc2]
     
     # For the ERROR block, identify relevant text
     
     txt3 <- character(0)
     
     loc00 <- grep('$ERR', locpk, fixed = TRUE) # integer(0) if not found
     
     if(unambiguous(loc00)){
        
        # identify relevant text
        
        tok3 <- locpk[[loc00]]
        tok4 <- locpk[[loc00]] # which must exist
        if(length(locpk) > loc00) tok4 <- locpk[[loc00 + 1L ]] # hopefully so
        
        
        # find these tokens in the original text (whence they came)
        # and select "inner" material
        loc3 <- grep(tok3, lst, fixed = TRUE) + 1L
        loc4 <- length(lst) # safe default
        if(length(locpk) > loc00) loc4 <- grep(tok4, lst, fixed = TRUE) - 1L
        
        # apparently loc4 can have more than one "hit"
        # retain the index closest to loc1
        
        closest <- whichClosestToZero(abs(loc3 - loc4))
        loc4 <- loc4[[closest]]
        
        stopifnot(unambiguous(loc4))
        stopifnot(unambiguous(loc3))
        
        txt3 <- lst[loc3:loc4]
     }
  }
  
  pattern_theta <- "(?<=PLACEHOLDER\\()\\d+"
  pattern_eta <- "(?<=ETA\\()\\d+"
  pattern_eps <- "(?<=EPS\\()\\d+|(?<=ERR\\()\\d+"
  
  quietMax <- function(..., na.rm = FALSE)suppressWarnings(max(..., na.rm = na.rm))
  
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
      ) %>% unlist %>% quietMax
    om = lapply(txt2_modified, function(y) {
           matches <- regmatches(y, gregexpr(pattern_eta, y, perl=TRUE))
           as.numeric(unlist(matches))
      }
      ) %>% unlist %>% quietMax
    sg = lapply(txt3, function(y) {
      matches <- regmatches(y, gregexpr(pattern_eps, y, perl=TRUE))
      as.numeric(unlist(matches))
    }) %>% unlist %>% quietMax
    
  }
    # TTB 2024-10-31 Normally sg would be numeric.
    # Here problematic results are flagged as dummy integer, for removal.

  if(length(sg) == 0)sg <- as.integer(0)
  if(length(sg) > 1) stop('not expecting sg to be longer than 1')
  if(is.na(sg)) sg <- as.integer(0)
  if(sg == 0) sg <- as.integer(0)
  if(is.infinite(sg)) sg <- as.integer(0)

## currently running on block[1] only
## should be sufficient
  
  diag_df = data.frame(parameter = c(
      as.character(sapply(seq_len(th), function(x)paste0('THETA',x))),
      if(sg > 0) paste0('SIGMA', parens(paste0(fr(sg), ',', sr(sg)))) else(character(0)),
      if(om > 0) paste0('OMEGA', parens(paste0(fr(om), ',', sr(om)))) else(character(0))
    )) 
  diag_df %<>% mutate(pclass = parameter %>% substring(., 1, 5), on = 0)
  diag_df %<>% mutate(left = text2decimal(sub(',.*','', parameter)))
  diag_df %<>% mutate(right= text2decimal(sub('[^,]*','', parameter)))
  diag_df %<>% mutate_cond(pclass %in% c('SIGMA','OMEGA'), on = (left == right))
  diag_df %<>% select(-left, -right)
  
  # TTB 2024-10-31 remove dummy value of sigma, if present.  See above.
  # if(identical(sg, integer(1))){
  #    diag_df %<>% filter(pclass != 'SIGMA')
  # }
  diag_df
}


#' Row indices for a half matrix
#' 
#' Return the row indices for the lower triangle (including diagonal)
#' of a square matrix, given its order (length of diagonal).
#' 
#' @export
#' @keywords internal
#' @family lst
#' @param x integer or numeric giving the order (one dimension) of a square matrix
#' @param ... ignored
#' @importFrom nonmemica half
#' @examples
#' rowdex(0)
#' rowdex(3)
#' 
rowdex <- function(x, ...){
   y <- half(diag(x))
   nms <- names(y)
   indices <- strsplit(nms, '\\.')
   rows <- sapply(indices, `[[`, 1)
   rows <- as.integer(rows)
   rows
}

#' Column indices for a half matrix
#' 
#' Return the column indices for the lower triangle (including diagonal)
#' of a square matrix, given its order (length of diagonal).
#' 
#' @export
#' @keywords internal
#' @family lst
#' @param x integer or numeric giving the order (one dimension) of a square matrix
#' @param ... ignored
#' @importFrom nonmemica half
#' @examples
#' coldex(0)
#' coldex(3)
#' 
coldex <- function(x, ...){
   y <- half(diag(x))
   nms <- names(y)
   indices <- strsplit(nms, '\\.')
   cols <- sapply(indices, `[[`, 2)
   cols <- as.integer(cols)
   cols
}

