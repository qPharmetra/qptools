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
#' @param temp: whether to unzip to a temporary directory
#' @param outdir character: one of \code{path} or \code{tempdir}
#' @param zip.filename: character: path and source filename, supersedes extension, filename, and path
#' @param zip.call character: system unzip invocation

nm_unzip <- function(
   run,
   extension = ".xml",
   filename = paste0(run, fxs(extension, '.   ')),
   path = file.path(
      normalizePath(getOption('nmDir',getwd())),
     run
   ),
   tmpdir = tempdir(),
   temp = FALSE,
   outdir = ifelse(temp, tmpdir, path),
   zip.filename = file.path(path, filename),
   zip.call = getOption("unzip.call"),
   quiet = TRUE,
   ...
)
{
   if(!quiet) cat("path:", path, "\n")
   if(!quiet) cat("file:", zip.filename, "\n")
   if(temp) stopifnot(file.exists(tmpdir))

   command = paste0(
      sprintf(
         zip.call,
         zip.filename
      ),
      ' -o',
      outdir
   )
   target = file.path(outdir, filename)

   if(!quiet) cat("call:", command, "\n")
   res <- system(command, ignore.stdout = quiet, ignore.stderr = quiet)
   if(!file.exists(target)) stop('unzip failed: ', res)
   invisible(target)
}

