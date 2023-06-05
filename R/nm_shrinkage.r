nm_shrinkage = function(run,
                        path = getOption("nmDir"),
                        file.lst = getOption("nmFileLst"),
                        remove_at_sign = TRUE
)
{
  lst = read_lst(run = run, path = path, file.lst = file.lst)
  
  my_table = data.frame(
  property = c(
    "ETABAR:",
    "SE:",
    "N:",
    "P VAL.:",
    "ETASHRINKSD",
    "ETASHRINKVR",
    "EBVSHRINKSD",
    "EBVSHRINKVR",
    "EPSSHRINKSD",
    "EPSSHRINKVR"
  ))
  
  ## limit list file area of observation
  mtext = lst[grep("ETABAR:", lst):grep("EPSSHRINKVR", lst)]
  
  strt = unlist(sapply(my_table$property, function(y,lst) grep(pattern=y, lst),lst=mtext))
  my_table$start=strt
  my_table$end=c(strt[-1]-1,strt[length(strt)])
  
  ## carve out elements from start to end
  output = apply(my_table[,-1],1,function(x,mtext) {
    as.character(sapply(mtext[x[1]:x[2]], function(y) substring(y,16)))
  }, mtext=mtext)
  
  ## break each up by number
  output = lapply(output, function(x)
    str_split(stringr::str_squish(x), " ") %>% unlist())
  output = lapply(output, as.numeric)
  
  names(output) = c(my_table$property[1:4],paste0(my_table$property[5:10],"(%)"))
  
  output_df = do.call("rbind", lapply(output[1:8], function(x){
    x = as.data.frame(matrix(x,nrow=1))
  names(x)=paste0("ETA",seq(ncol(x)))
  return(x)
  }))

  return(list(eta = output_df, eps=output[9:10]))

}

nm_shrinkage("run15")