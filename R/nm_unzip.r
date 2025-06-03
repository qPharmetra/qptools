#' Unzip a NONMEM File
#'
#' Unzips a NONMEM file, by default the xml output
#' of a NONMEM run.  Uses 7z decompression.
#'
#' @export
#' @keywords internal
#' @family nm
#' @param x character (run name)
#' @param extension character: extension to append to run
#' @param filename character: supersedes run, extension
#' @param path path to directory enclosing the NONMEM run directory
#' @param tempdir character: path to temporary working directory if \code{temp} is true
#' @param temp  whether to unzip to a temporary directory
#' @param outdir character: one of \code{path} or \code{tempdir}
#' @param zipped character: full path to zipped file (7z extension is optional); supersedes other arguments if supplied
#' @param call character: system unzip invocation
#' @return invisible path to unzipped file
#' @examples
#' options(nmDir = getOption('qpExampleDir'))
#' dir <- getOption("qpExampleDir")
#' unz <- nm_unzip('example1')
#' unz
#' unlink(unz)
#' run <- 'example1'
#' file <- 'example1.xml'
#' zipped <- 'example1.xml.7z'
#' path <- file.path(dir, run, file)
#' zpath <-file.path(dir, run, zipped)
#' file.exists(path)
#' file.exists(zpath)
#' to <- nm_unzip(zipped = path)
#' file.exists(to)
#' unlink(to)
#' to <- nm_unzip(zipped = zpath)
#' file.exists(to)
#' unlink(to)

nm_unzip <- function(
   x,
   rundir = normalizePath(getOption('nmDir',getwd())),
   path = file.path(rundir,x),
   extension = ".xml",
   filename = paste0(x, fxs(extension, '.   ')),
   zipped = file.path(path, filename),
   tmpdir = tempdir(),
   temp = FALSE,
   outdir = ifelse(temp, tmpdir, dirname(zipped)),
   call = getOption("unzip.call"),
   quiet = TRUE,
   ...
)
{
   if(!quiet) cat("file:", zipped, "\n")
   if(temp) stopifnot(file.exists(tmpdir))
   zipped <- sub('\\.7z$', '',zipped) # strip 7z
   unzipped <- file.path(outdir, basename(zipped))
   if(file.exists(unzipped)){
      if(!quiet) message('file exists: ', unzipped)
   } else {
       command <- paste0(sprintf(call, zipped), ' -o', outdir) # supply 7z
       if(!quiet) cat("call:", command, "\n")
       res <- system(command, ignore.stdout = quiet, ignore.stderr = quiet)
   }
   if(!file.exists(unzipped)) stop('cannot find ', unzipped)
   invisible(unzipped)
}

