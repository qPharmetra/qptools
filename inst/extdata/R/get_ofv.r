get_ofv = function(run,
                   path = getOption("nmDir"),
                   file.ext = getOption("nmFileExt"),
                   digits = 1)
{
  lapply(read_ext(run = run, path = path, file.ext = file.ext), function(x)
    x %>% filter(ITERATION == -1000000000) %>% 
      .[, ncol(.)] %>% 
      unlist %>% 
      as.numeric() %>% 
      round(digits = digits)
  )
}

#get_ofv("run1298",  path = getOption("nmDir"))