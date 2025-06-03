#' Update Glossaries
#'
#' Updates glossaries in latex-based report. Changes to the specified directory,
#' and should change back even if an error occurs.
#'
#' @param dir path to directory containing the report
#' @param base basename for the report
#' @param command defaults to 'makeindex'
#' @param s default -s argument (*.ist)
#' @param t default -t argument (*.glg)
#' @param o default -o argument (*.gls)
#' @param p default -p argument (*.glo)
#' @param args arguments to command; overrides s, t, o, p
#' @param call text of system call; overrides command and args
#' @param quiet suppress messages
#' @param ... ignored
#' @return Used for side effects.
#' @export

latex_update_glosssaries <- function(
   dir = '.',
   base = 'Report',
   command = 'makeindex',
   s = paste0('-s ', base, '.ist'),
   t = paste0('-t ', base, '.glg'),
   o = paste0('-o ', base, '.gls'),
   p = paste0(''   , base, '.glo'),
   args = paste(s, t, o, p ),
   call = paste(command, args),
   quiet = TRUE,
  ...
)
{
   here = getwd()
   setwd(dir)
   if(!quiet) cat("path:", getwd(), "\n")
   if(!quiet) cat("call:", call, "\n")
   arg <- c(
      list(
         command = call,
         ignore.stdout = quiet,
         ignore.stderr = quiet
      ),
      list(...)
   )
   arg <- arg[names(arg) %in% names(formals(system))]
   res <- tryCatch(do.call(system, arg),finally = setwd(here))
   invisible(res)
}
