#path=getOption("nmDir")

nm_params_table = function (run, 
                            path = getOption("nmDir"), 
                            file.ext = getOption("nmFileExt"),
                            runIndex,  
                            return.all = FALSE,
                            add_label = TRUE,
                            digits=1) 
{
  theExt = nm_process_ext(run = run, path = path, file.ext = file.ext)
  theTab = lapply(theExt, function(x) {
    x$Parameter = row.names(x)
    x$Parameter = sub("[,]", ".", sub("[)]", "", (sub("[(]","", x$Parameter))))
    return(x)
  })
  runIndex = if (missing(runIndex)) length(theTab) else runIndex 
  theTab = theTab[[runIndex]]
  
  theTab$index = extract.number(theTab$Parameter)
  theTab$level = stringr::str_extract(theTab$Parameter,pattern = "[a-zA-Z]*")
  
  parTab = theTab[theTab$level %in% c("THETA", "SIGMA", "OMEGA"), ]
  parTab$ord = swap(parTab$level, c("THETA", "OMEGA", "SIGMA"), 1:3)
  parTab$ord = paste(parTab$ord, format(parTab$index), sep = ".")
  parTab = parTab[order(parTab$ord), ]
  parTab = reorder(parTab, "Parameter")
  
  parTab = parTab %>%
    group_by(level) %>%
    mutate(order=cumsum(level==level)) %>%
    ungroup()
  
  if (!"se" %in% names(parTab)) {
    parTab$se = NA
    parTab$prse = NA
  }
  
  ## drop things from the ext file we will never use for parameter table
  if(is.element("eigen_cor",names(parTab))) parTab = parTab %>% select(-eigen_cor)
  if(is.element("cond",names(parTab))) parTab = parTab %>% select(-cond)
  if(is.element("part_deriv_LL",names(parTab))) parTab = parTab %>% select(-part_deriv_LL)
  
  ## find transformations in control stream
  label_df = nm_model_labels(run = run, path = path, file.lst = getOption("qpFileLst"))
  
  if(add_label) ## if labelling is not correct and throws an error, can toggle it off here
    parTab = parTab %>% 
    select(-order) %>%
    left_join(label_df %>%select(-fixed), by=c("level","ord"))
  if(F) parTab %>% as.data.frame()
  
  ## make selected table compenents numeric
  parTab = parTab %>% mutate_at(
    .vars = c("estimate","se", "om_sg", "se_om_sg", "fixed"), 
    .funs = as.numeric)
  
  parTab$prse = NA
  msel = parTab$fixed==0
  parTab$prse[msel] = parTab$se[msel]/parTab$estimate[msel] * 100
  
  parTab$Run = rep(run, nrow(parTab))
  
  return(parTab)

}

#nm_params_table(run="run15")
#nm_params_table(run="run1298")
#nm_params_table(run="example2", path = getOption("qpExampleDir"))
