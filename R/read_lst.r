read_lst = function(run,
                    path = getOption("nmDir"),
                    file.lst = getOption("nmFileLst"))
{
  lstFileName = file.path(path, paste(run, file.lst, sep = "."))
  out = invisible(scan(
    file = lstFileName,
    what = "character",
    sep = "\n",
    quiet = T
  ))
  return(out)
}

#read_lst("run15")

read_out
