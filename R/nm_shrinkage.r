globalVariables(c('xxx','tmp_eta', 'tmp_eps', 'lst', 'lst_est','result','tags','tag1','type','values','tags_df','mtext', 'etashrink', 'epsshrink','etabar_start', 'etabar_end','parameter'))
#' Get NONMEM Shrinkage Estimates
#' 
#' Gets NONMEM shrinkage estimates from the LST file.
#' 
#' @export
#' @family lst
#' @param x character: a file path, or the name of a run in 'directory', or lst content
#' @param directory character: optional location of x
#' @param extension length-two character: extensions identifying ext and lst files
#' @param nested length-two logical: are the ext and lst files nested within the run 
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param clue a text fragment expected to occur in cov files
#' @param keep_stat a text fragment indicating whether to take shrinkage variance ('VR') of standard deviation ('SD', default). 
#' @param keep_type a text fragment indicating whether to take shrinkage 'EBV' or 'ETA' (default)
#' @param ... passed arguments
#' @importFrom stringr str_split str_squish
#' @importFrom magrittr %>% %<>% %$%
#' @return data.frame
#' @examples
#' dir <- getOption("qpExampleDir")
#' options(nmDir = dir)
#' # nm_shrinkage('example1') # old-style lst file not supported
#' nm_shrinkage('run103')
#' nm_shrinkage('run105')


nm_shrinkage <- function(
  x,
  directory = getOption("nmDir", getwd()),
  extension = c(
    getOption("nmFileLst", 'ext'),
    getOption("nmFileLst", 'lst')
  ),
  nested = c(TRUE, FALSE),
  quiet = TRUE,
  clean = TRUE,
  clue = '\\$PROB',
  keep_stat = "SD",
  keep_type = "ETA",
  ...
){
  stopifnot(is.logical(nested))
  nested <- rep(nested, length.out = 2)
  myRun = x
  lst = read_lst(
    x,
    directory = directory,
    extension = extension[[2]],
    quiet = quiet,
    clean = clean,
    nested = nested[[2]],
    clue = clue
  )
  lst_est = nm_lst_by_est_method(lst)
  nms = nm_methods(lst)
  lst <- strsplit(lst, '\n')[[1]]
  
  ## limit list file area of observation
  etabar_start = lapply(lst_est, function(x)
    grep("etabar:", tolower(x)))
  etabar_end = lapply(lst_est, function(x)
    grep("epsshrinkvr", tolower(x)))
  
  result = lapply(
     1:length(etabar_start), 
     function(
       x,
       etabar_start,
       etabar_end,
       lst_est,
       lst,
       myRun
     ){
    if (length(etabar_start[[x]]) == 0) {
      on = find_diag_template(
         myRun, 
         directory = directory, 
         extension = extension,
         quiet = quiet,
         clean = clean,
         nested = nested,
         clue = clue,
         ...
      )
      on %<>%
        filter(on == 1) %>%
        select(parameter,pclass,on) %>%
        mutate(shrinksd = NA, shk = NA) %>%
        mutate(type = "EPS") %>%
        mutate_cond(pclass == "OMEGA", type = "ETA")
      on %>% select(parameter, pclass, on, type, shrinksd)
    }
    else {
      mtext = lst_est[[x]] [etabar_start[[x]]:etabar_end[[x]]] %>% str_squish
      
      tags = c(
        "ETABAR:",
        "SE:",
        "N:",
        "VAL",
        "ETASHRINKSD",
        "ETASHRINKVR",
        "EBVSHRINKSD",
        "EBVSHRINKVR",
        "EPSSHRINKSD",
        "EPSSHRINKVR"
      )
      tags_df = data.frame(tag1 = sapply(tags, function(x, mtext)
        grep(x, mtext), mtext = mtext))
      tags_df %<>% mutate(tag2 = c(tag1[-1] - 1, length(mtext)))
      tags_df %<>% mutate(names = tags)
      tags_df %<>% mutate(stat = "", type = "")
      tags_df %<>% mutate_cond(grepl("SHRINK", names), stat = substring(names, 10, 11))
      tags_df %<>% mutate_cond(grepl("SHRINK", names), type = substring(names, 1, 3))
      
      tags = sapply(1:nrow(tags_df), function(x, tags_df, mtext)
        mtext[tags_df$tag1[x]:tags_df$tag2[x]] %>%
          gsub("[A-Za-z]+", "", .) %>% gsub(":", "", .) %>% gsub("[(%)]+", "", .),
        mtext = mtext, tags = tags_df)
      tags_df %<>% mutate(values = tags)
      ## apply focus
      tags_df %<>% filter(stat == keep_stat &
                            type %in% c("EPS", keep_type))
      
      tmp_eta = tags_df %>% filter(stat == keep_stat &
                                     type == keep_type) %$% values %>% str_squish %>%
        unPaste(., sep = " ") %>% unlist
      tmp_eta = sapply(1:length(tmp_eta), function(i, tmp)
        substring(tmp[i], 1, 6), tmp = tmp_eta) %>% asNumeric() *
        sapply(1:length(tmp_eta), function(i, tmp)
          substring(tmp[i], 7, 9), tmp = tmp_eta) %>% asNumeric() %>% 10 ^ .
      tmp_eps = tags_df %>% filter(stat == keep_stat &
                                     type == "EPS") %$% values %>% str_squish %>%
        unPaste(., sep = " ") %>% unlist
      tmp_eps = sapply(1:length(tmp_eps), function(i, tmp)
        substring(tmp[i], 1, 6), tmp = tmp_eps) %>% asNumeric() *
        sapply(1:length(tmp_eps), function(i, tmp)
          substring(tmp[i], 7, 9), tmp = tmp_eps) %>% asNumeric() %>% 10 ^ .
      
      omn = length(tmp_eta)
      sgn = length(tmp_eps)
      # simple internal functions to get the lower traingle of the cov blocks
      fr = function(x) sapply(1:x,function(y)rep(y,times=y)) %>% unlist()
      sr = function(x) sapply(1:x,function(y) 1:y) %>% unlist()
      xxx = data.frame(parameter = c(
        paste0("SIGMA(", fr(sgn), ",", sr(sgn), ")"),
        paste0("OMEGA(", fr(omn), ",", sr(omn), ")")
      )) %>%
        mutate(pclass = parameter %>% substring(., 1, 5), on = 0)
      xxx %<>% mutate(idx = c(fr(sgn)*10+sr(sgn),fr(omn)*10+sr(omn))) 
      xxx %<>% mutate(on=as.numeric((idx%%11)==0)) %>% select(-idx)
      xxx %<>% filter(on == 1) 
      xxx %<>% mutate(type = "EPS")
      xxx %<>% mutate_cond(substring(parameter, 1, 5) == "OMEGA", type = "ETA")
      
      
      xxx %<>% mutate(shrinksd = 0)
      xxx %<>% mutate_cond(type == keep_type, shrinksd = tmp_eta)
      xxx %<>% mutate_cond(type == "EPS", shrinksd = tmp_eps)
      xxx
    }
  },
  lst = lst,
  lst_est = lst_est,
  etabar_start = etabar_start,
  etabar_end = etabar_end,
  myRun = myRun)
  names(result) = nms
  return(result)
}
