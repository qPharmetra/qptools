nm_parse_dollar_data = function(run,
                                path = getOption("nmDir"),
                                file.lst = getOption("nmFileLst"),
                                remove_at_sign = TRUE
)
{
  lst = read_lst(run = run, path = path, file.lst = file.lst)
  dta = str_split(stringr::str_squish(lst[grep("[$]DATA", lst)]), " ")[[1]][-1]
  dta = dta[[1]]
  
  ignores = str_split(stringr::str_squish(lst[grep("IGNORE", lst)]), " ") %>%
    unlist()
  ignores = ignores[grep("IGNORE", ignores)]
  
  accepts = str_split(stringr::str_squish(lst[grep("ACCEPT", lst)]), " ") %>%
    unlist()
  accepts = accepts[grep("ACCEPT", accepts)]

  nm_parse_2r = function(nmtext)
  {
    nmtext = gsub("[.]GT[.]", ">", nmtext)
    nmtext = gsub("[.]GE[.]", ">=", nmtext)
    nmtext = gsub("[.]LT[.]", "<", nmtext)
    nmtext = gsub("[.]LE[.]", "<=", nmtext)
    nmtext = gsub("[.]EQ[.]", "==", nmtext)
    nmtext = gsub("[.]NE[.]", "!=", nmtext)
    nmtext = gsub("ACCEPT=", "", nmtext)
    nmtext = gsub("IGNORE=", "", nmtext)
    nmtext = substring(nmtext, length(nmtext))
    return(nmtext)
  }
  
  glue_operators = function(x)
  {
    x = stringr::str_replace(x, "[(]+", "")
    x = stringr::str_replace(x, "[)]+", "")
    x = paste(sapply(x, nm_parse_2r), collapse = " & ")
    x
  }
  if(remove_at_sign) ignores = ignores[!grepl("@",ignores)]
  ignores_glued = if(is.null(ignores)) NULL else glue_operators(ignores)
  accepts_glued = if(is.null(accepts)) NULL else glue_operators(accepts)
  
  return(list(data = dta, ignores = ignores_glued, accepts = accepts_glued))
}

#nm_parse_dollar_data("run15")
#nm_parse_dollar_data("run1298")

