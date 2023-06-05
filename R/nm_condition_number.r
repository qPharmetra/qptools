
nm_condition_number = function(run,
                               path = getOption("nmDir"),
                               file.ext = getOption("qpFileExt")
)
{
  ext_processed = nm_process_ext(run = run, path = path, file.ext = file.ext)
  if(!any(is.element(names(ext_processed[[1]]), "cond"))) {
    return(lapply(ext_processed, function(x) return(NULL)))
  }
  cn = lapply(ext_processed, function(x) as.numeric(x$cond[1]))
  return(cn)
}

#nm_condition_number(run = "run5")
#nm_condition_number(run = "run15")
#nm_condition_number(run = "run1296")
