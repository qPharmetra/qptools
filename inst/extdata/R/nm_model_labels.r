#mod = read.mod(run="run1298") ## not necessary?

nm_model_labels = function(run,
                           path = getOption("nmDir"),
                           file.lst = getOption("nmFileLst"))
{
  lst = read_lst(run = run, path = path, file.lst = file.lst)
  th = grep("[$]THETA", lst)
  om = grep("[$]OMEGA", lst)
  sg = grep("[$]SIGMA", lst)
  est = grep("[$]EST", lst)
  if (length(th) != (om[1] - min(th)))
    th = th[1]:(om[1] - 1)
  if (length(om) != (sg[1] - min(om)))
    om = om[1]:(sg[1] - 1)
  if (length(sg) != (est[1] - min(sg)))
    sg = sg[1]:(est[1] - 1)
  
  pars_c = c(lst[th], lst[om], lst[sg])
  
  initial = list(THETA = lst[(grep("0INITIAL ESTIMATE OF THETA:", lst) +
                                2):(grep("0INITIAL ESTIMATE OF OMEGA:", lst) - 1)],
                 OMEGA = lst[(grep("0INITIAL ESTIMATE OF OMEGA:", lst) +
                                1):(grep("0INITIAL ESTIMATE OF SIGMA:", lst) - 1)],
                 SIGMA = lst[(grep("0INITIAL ESTIMATE OF SIGMA:", lst) +
                                1):(grep("0SIGMA", lst)[2] - 1)])
  initial$THETA = data.frame(do.call("rbind", str_split(str_trim(initial$THETA), "    ")))
  names(initial$THETA) = c("lower", "initial", "upper")
  initial$THETA$level = "THETA"
  initial$THETA$order = seq(nrow(initial$THETA))
  
  initial$OMEGA = str_split(initial$OMEGA, "[ ]+")
  initial$OMEGA = initial$OMEGA[lapply(initial$OMEGA, length) == 2]
  initial$OMEGA = data.frame(initial = unlist(lapply(initial$OMEGA, function(x)
    x[2])))
  initial$OMEGA$level = "OMEGA"
  initial$OMEGA$order = seq(nrow(initial$OMEGA))
  
  initial$SIGMA = str_split(initial$SIGMA, "[ ]+")
  initial$SIGMA = initial$SIGMA[lapply(initial$SIGMA, length) == 2]
  initial$SIGMA = data.frame(initial = unlist(lapply(initial$SIGMA, function(x)
    x[2])))
  initial$SIGMA$level = "SIGMA"
  initial$SIGMA$order = seq(nrow(initial$SIGMA))
  
  initial = bind_rows(initial$THETA, initial$OMEGA, initial$SIGMA) %>%
    mutate(
      lower = str_trim(lower),
      upper = str_trim(upper),
      initial = str_trim(initial)
    )
  if (F)
    initial
  
  ##
  pars = data.frame(input = pars_c) %>%
    mutate(level = substring(stringr::word(input), 2)) %>%
    mutate_cond(level=="", level=NA) %>%
    mutate(level=locf(level)) %>%
    group_by(level) %>%
    mutate(order = cumsum(level == level))  %>%
    ungroup()
  
  ## fix missing THETA or OMEGA labels
  pars = pars %>%
    mutate_cond(substring(input,1,1) != "$", input = paste0("$", level, " ", input))
  
  pars = suppressMessages( 
    pars %>%
    mutate(fixed = as.numeric(grepl("FIX", input))) %>%
    left_join(initial) # initial estimates from the lst file
  )
  
  label_df = pars %>%
    select(level, order) %>%
    mutate(label = NA,
           unit = NA,
           trans = NA)
  
  str_lab = function(x, i)
    str_trim(x[i])
  
  label_df$label[pars$level == "THETA"] =
    unlist(lapply(str_split(pars$input[pars$level == "THETA"], ";"), str_lab, i = 2))
  label_df$label[pars$level == "OMEGA"] =
    unlist(lapply(str_split(pars$input[pars$level == "OMEGA"], ";"), str_lab, i = 2))
  label_df$unit[pars$level == "THETA"] =
    unlist(lapply(str_split(pars$input[pars$level == "THETA"], ";"), str_lab, i = 3))
  label_df$trans[pars$level == "THETA"] =
    unlist(lapply(str_split(pars$input[pars$level == "THETA"], ";"), str_lab, i = 4))
  
  pars = suppressMessages(
    pars %>%
     left_join(label_df) %>%
    as.data.frame()
  )
  
  ## pull THETA OMEGA SIGMA
  ext = nm_process_ext(run = run, path = path, file.ext = "ext")
  ext = ext[[1]]
  ext$Parameter = row.names(ext)
  
  ext = ext %>%
    mutate(level = stringr::str_extract(Parameter,pattern = "[a-zA-Z]*")) %>%
    mutate(Parameter = sub("[,]", ".", sub("[)]", "", (sub("[(]","", Parameter))))) %>%
    mutate(index = extract.number(Parameter)) %>%
    mutate(order = swap(level, c("THETA", "OMEGA", "SIGMA"), 1:3)) 
  
  ext$ord = swap(ext$level, c("THETA", "OMEGA", "SIGMA"), 1:3)
  ext$ord = paste(ext$ord, format(ext$index), sep = ".")
  
  par_df = do.call("rbind", 
                   lapply(str_split(substring(ext$Parameter,6),"[.]"), 
                          function(x) data.frame(left=x[1],right=ifelse(length(x)==1,0,x[2])))
  ) %>%
    mutate(Parameter = ext$Parameter,level=ext$level, order=ext$order, ord = ext$ord, placeLabel=rep(0,nrow(.))) %>%
    mutate_cond(level=="THETA" | left==right, placeLabel=1) %>%
    arrange(order, ord) %>%
    mutate(order=0) %>%
    group_by(level) %>%
    mutate_cond(placeLabel==1, order=as.numeric(cumsum(level==level))) %>%
    ungroup() #%>%
    # mutate_cond(!grepl("[.]",ord), ord=paste0(ord, ".0"))
     
  pars_final = suppressMessages(
    pars %>%
    left_join(par_df %>% filter(placeLabel==1) %>% select(level,order,ord)) 
  )
  
  ## fix order in sync with nm_params_table()
  pars_final = pars_final %>%
    group_by(level) %>%
    mutate(order=cumsum(level==level)) %>%
    ungroup()
  
  return(pars_final)
}

if(F) nm_model_labels("run15")
if(F) nm_model_labels("run1298")

## examples extraction of words and digits
if (F)
{
  str_extract_all("Klaas has 14 Silly things worth 0$", pattern = "[[:alpha:]]+")
  str_extract_all("Klaas has 14 Silly things worth 0$", pattern = "[[:digit:]]+")
}
getOption("nmDir")