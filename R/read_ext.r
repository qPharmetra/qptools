read_ext = function (run
                     , path = getOption("nmDir")
                     , file.ext = getOption("qpFileExt"), 
          quiet = TRUE) 
{
  x = invisible(scan(
    file = file.path(path, run, paste(run,file.ext, sep = ".")),
    what = "character",
    sep = "\n",
    quiet = quiet)
  )
  
  loc = grep("TABLE NO", x)
  idx = 0
  if (length(loc) == 1) 
    idx = 1
  loc = matrix(c(loc, c(loc[-1] - 1, length(x))), nrow = 2, 
               byrow = TRUE)
  loc
  x = apply(loc, 2, function(loc, x) x[loc[1]:loc[2]], x = x)
  if (idx == 1) {
    x = list(x[, 1])
  }
  xnam = lapply(x, function(y) Hmisc::unPaste(y[1], sep = ":"))
  names(x) = lapply(xnam, function(x) substring(x[2], 2))
  parse.table <- function(y) {
    y = y[-1]
    dfnames = unlist(Hmisc::unPaste(substring(y[1], 2), sep = "\\s+"))
    y = y[-1]
    yy = lapply(y, function(z) Hmisc::unPaste(substring(z, 2), sep = "\\s+"))
    yy = do.call("rbind", yy)
    yy = data.frame(yy[, -1])
    names(yy) = dfnames
    return(yy)
  }
  return(lapply(x, parse.table))
}
