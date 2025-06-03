#' Load a Specific Package Version
#' 
#' Loads a specific package version.
#' 
#' @param package package name, possibly unquoted
#' @param version minimum allowed version
#' @param help passed to \code{\link{library}}
#' @param pos passed to \code{\link{library}}
#' @param lib.loc passed to \code{\link{library}}
#' @param character.only passed to \code{\link{library}}
#' @param logical.return passed to \code{\link{library}}
#' @param warn.conflicts passed to \code{\link{library}}
#' @param quietly passed to \code{\link{library}}
#' @param verbose passed to \code{\link{library}}
#' @param mask.ok passed to \code{\link{library}}
#' @param exclude passed to \code{\link{library}}
#' @param include.only passed to \code{\link{library}}
#' @param attach.required passed to \code{\link{library}}
#' @importFrom utils compareVersion packageVersion
#' @export
#' @keywords internal
#' @examples
#' LIBRARY(knitr, '0.9.0')

LIBRARY <-function(
   package, 
   version=0, 
   help, 
   pos = 2, 
   lib.loc = NULL,
   character.only = TRUE, 
   logical.return = FALSE,
   warn.conflicts, quietly = FALSE,
   verbose = getOption("verbose"),
   mask.ok, 
   exclude, 
   include.only,
   attach.required = missing(include.only)
){
   package <-as.character(substitute(package))
   base::library(
      package, 
      help = help, 
      pos = pos, 
      lib.loc = lib.loc,
      character.only = character.only, 
      logical.return = logical.return,
      warn.conflicts = warn.conflicts, 
      quietly = quietly,
      verbose = verbose,
      mask.ok = mask.ok, 
      exclude = exclude,
      include.only = include.only,
      attach.required = attach.required
   )
   pver <-packageVersion(package)
   if(compareVersion(as.character(pver),as.character(version)) < 0)stop("Version ", version, " of'", package,"'required, but only ", pver, " is available")
   invisible(pver)
}
