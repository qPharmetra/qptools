#' Unzip a NONMEM File
#'
#' Unzips a NONMEM file, by default the xml output
#' of a NONMEM run.  Uses 7z decompression.
#'
#' @export
#' @keywords internal
#' @family nm
#' @param run character (run name)
#' @param extension character: extension to append to run
#' @param filename character: supersedes run, extension
#' @param path path to directory enclosing the NONMEM run directory
#' @param tempdir character: path to temporary working directory if \code{temp} is true
#' @param temp  whether to unzip to a temporary directory
#' @param outdir character: one of \code{path} or \code{tempdir}
#' @param zipped character: path and source filename, supersedes extension, filename, and path
#' @param call character: system unzip invocation

nm_unzip <- function(
   run,
   rundir = normalizePath(getOption('nmDir',getwd())),
   path = file.path(rundir,run),
   extension = ".xml",
   filename = paste0(run, fxs(extension, '.   ')),
   zipped = file.path(path, filename),
   tmpdir = tempdir(),
   temp = FALSE,
   outdir = ifelse(temp, tmpdir, dirname(zipped)),
   call = getOption("unzip.call"),
   quiet = TRUE,
   ...
)
{
   if(!quiet) cat("path:", path, "\n")
   if(!quiet) cat("file:", zipped, "\n")
   if(temp) stopifnot(file.exists(tmpdir))

   command <- paste0(sprintf(call, zipped), ' -o', outdir)
   if(!quiet) cat("call:", command, "\n")
   res <- system(command, ignore.stdout = quiet, ignore.stderr = quiet)
   unzipped <- file.path(outdir, filename)
   if(!file.exists(unzipped)) stop('cannot find ', unzipped)
   invisible(unzipped)
}

