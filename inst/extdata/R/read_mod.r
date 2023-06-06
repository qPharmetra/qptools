read_mod = function (run,
                     path = getOption("nmDir"),
                     file.mod = getOption("nmFileMod"))
{
  theRun = paste(run, gsub("[.]", "", file.ext), sep = ".")
  ctl = scan(
    file = file.path(path, theRun),
    what = "character",
    sep = "\n",
    quiet = TRUE
  )
  return(ctl)
}
