load_modeled_dataset = function(run, path=getOption("nmDir"))
{
  info = nm_parse_dollar_data(run=run, path = path)
  cat("path:    ",path, "\n")
  cat("dataset: ",info$data, "\n")
  cat("IGNORE:  ",ifelse(is.null(info$ignores), "NA", info$ignores), "\n")
  cat("ACCEPT:  ",ifelse(is.null(info$accepts), "NA", info$accepts), "\n")
  my_path = file.path(getOption("nmDir"),info$data)
  
  ignores = if(!is.null(info$ignores)) paste0("!{", info$ignores, "}") else NULL
  accepts = if(!is.null(info$accepts)) paste0( "{", info$accepts, "}") else NULL
  cat("apply:    ", paste0("filter(", paste(ignores, accepts, collapse = "|",sep=""),")\n"))
  
  return(yamlet::io_csv(my_path)) 
}

#my_data = load_modeled_dataset(run = "run15")
#model_dataset = load_modeled_dataset("run1298")

## we can apply the filter automatically but this is NOT implemented as when the NONMEM
## dataset and $DATA have conflicting names it will throw an error
## user is encouraged to apply this self
