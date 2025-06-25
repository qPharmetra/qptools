globalVariables('num')

#' Read Generic NONMEM File
#' 
#' Reads generic NONMEM file with particular extension.
#' Generic, with method \code{\link{read_gen.character}}
#' 
#' @export
#' @keywords internal
#' @family gen
#' @param x object of dispatch
#' @param ... passed
read_gen <- function(x, ...)UseMethod('read_gen')

#' Read NONMEM File for Character
#' 
#' Reads NONMEM file for class character.
#' If length of x is greater than one, it is collapsed.
#' If x is a file, possibly in \code{directory}, it is read with \code{\link{read_gen.file}}.
#' If x implies a zipped file, possibly in \code{directory}, it is unzipped first.
#' If x is a directory, possibly in \code{directory}, it is read with \code{\link{read_gen.run}}.
#' If an unzipped version of the file already exists in the target directory (local or temporary) it is removed before unzipping proceeds.
 
#' @export
#' @family gen
#' @importFrom utils file_test
#' @param x character: a file path, or the name of a run in 'directory', or file content
#' @param extension character: a file extension indicating desired file type
#' @param clue character: a text fragment that ought to occur in files with this extension
#' @param directory character: optional location of x
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the occur in a temporary directory?
#' @param nested is the file nested within the run directory?
# @param zipped is the file zipped using 7z?
#' @param ... passed arguments
#' @return length-one character of file contents, classified like 'extension'
#' @examples
#'  library(magrittr)
#'  options(nmDir = getOption('qpExampleDir'))
#'  'example1' %>% read_gen('xml')
#'  'example1' %>% read_gen('cov')
#'  'example1' %>% read_gen('lst') # also unnested!
#'  'example1.lst' %>% read_gen(nested = FALSE) # also nested!
#' #'example1' %>% read_gen('ctl') # should not work!
#'  'example1' %>% read_gen('ctl', nested = FALSE)
#'  'example1' %>% read_gen('ext')
#'  'example1.cov' %>% read_gen('ext') # mistake!
#'  'example1.cov' %>% read_gen('cov')
#'  'example1.cov' %>% read_gen
#'  'example1.cov' %>% file.path(getOption('qpExampleDir'), 'example1', .) %>% read_gen
#'  'example1.cov.7z' %>% read_gen
#' 

read_gen.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = NULL,
      quiet = TRUE, 
      clean = TRUE,
      nested = TRUE,
      clue = NULL,
#      zipped = NULL,
      ...
){
   
   # x could be ...
   # example1
   # example1.lst
   # dir/example1.lst
   # dir/example1/example1.lst
   # example1.cov
   # example1.cov.7z
   # dir/example1/example1.cov
   # dir/example1/example1.cov.7z
   # <the contents of an x-like file>
   
   # always remove 7z, as it will be checked anyway
   x <- sub('\\.7z$', '', x)
   
   # try to determine an extension
   if(is.null(extension)){
      suppressWarnings( # @ 0.3.3
      base <- basename(x)
      )
      base <- sub('\\.7z$','', base)
      extension <- sub('^.+\\.([^.]+)$', '\\1', base)
      if(identical(base, extension)){extension <- ''}
   }
   
   # default clue as necessary
   if(is.null(clue)) clue <- 'qptools_no_clue'
   
   # make sure x is length-one
   if(length(x) > 1) x <- paste(x, collapse = '\n')
  
   # verify arguments
   stopifnot(is.character(x), length(x) == 1)
   stopifnot(is.character(extension), length(extension) == 1)
   stopifnot(is.character(directory), length(directory) == 1)
   stopifnot(is.character(clue), length(clue) == 1)
   stopifnot(is.logical(quiet), length(quiet) == 1)
   stopifnot(is.logical(clean), length(clean) == 1)
   stopifnot(is.logical(nested), length(nested) == 1)
  # stopifnot(is.logical(zipped), length(zipped) == 1)

   # create the resources implied by x
   token = paste0('\\.',extension, '$')
   
   # by stripping any extension from x, we can try to recover a run name
   # (or x may already be a run name)
   suppressWarnings( # @ 0.3.3
   run <- sub(token, '', basename(x))
   )
   
   # x may itself be a full path to an object
   # x may be a a file in a run directory
   filepath <- file.path(directory, run, x)
   if(!nested) filepath <- file.path(directory, x)
   
   # x may be a directory (run) in directory
   dirpath <- file.path(directory, x)
   
   # x may exist solely in zipped form
    zpf <- function(x)paste0(x, '.7z')
   
   # we are expecting that x is exactly one of: text, file, or directory
   isText <- FALSE
   isFile <- FALSE
   isDir <- FALSE
   
   
   if(grepl(clue, x)) isText <- TRUE
   
   suppressWarnings({
   
   try(silent = TRUE, if(file_test('-f', x))             isFile <- TRUE)
   try(silent = TRUE, if(file_test('-f', filepath))      isFile <- TRUE)

   try(silent = TRUE, if(file_test('-f', zpf(x)))        isFile <- TRUE)
   try(silent = TRUE, if(file_test('-f', zpf(filepath))) isFile <- TRUE)
   
   try(silent = TRUE, if(file_test('-d', x))              isDir <- TRUE)
   try(silent = TRUE, if(file_test('-d', dirpath))        isDir <- TRUE)
   
   })
   
   if(sum(isText, isFile, isDir) == 0){
      message('input assumed to be text')
      isText <- TRUE
   }
   if(sum(isText, isFile, isDir) > 1){
      stop('input not clearly xml, file, or directory')
   }
   if(isText) class(x) <- 'text'
   if(isFile) class(x) <- 'file'
   if(isDir)  class(x) <- 'run'
   read_gen(
      x, 
      extension = extension,
      directory = directory, 
      quiet = quiet, 
      clean = clean, 
      nested = nested,
   #   zipped = zipped,
      ...
   )
}


#' Read NONMEM File as Text
#' 
#' Reads NONMEM file for class 'text': length-one character with text content.
#' 
#' @export
#' @keywords internal
#' @family gen
#' @param x length-one character with text content
#' @param extension character: a file extension indicating desired file type
#' @param ... ignored
#' @return character
read_gen.text <- function(
      x, 
      extension,
      ...
){
   stopifnot(is.character(x), length(x) == 1)
   stopifnot(is.character(extension), length(extension) == 1)
   if(extension == '') extension <- 'blank'
   class(x) <- extension
   x
}

#' Read NONMEM File as File
#' 
#' Reads NONMEM file for class 'file'
#' 
#' @export
#' @keywords internal
#' @family gen
#' @param x character: a file path
#' @param extension character: a file extension indicating desired file type
#' @param directory character: optional location of x
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
# @param zipped is the file zipped using 7z?
#' @param ... passed arguments
#' @return length-one character of file contents, classified like 'extension'

read_gen.file <- function(
   x, 
   extension,
   directory, 
   quiet,
   clean,
   nested,
 #  zipped,
   ...
){
   # create the resources implied by x
   token = paste0('\\.',extension, '$')
   
   # by stripping any extension from x, we can try to recover a run name
   # (or x may already be a run name)
   suppressWarnings( # @ 0.3.3
   run <- sub(token, '', basename(x))
   )
   
   # x may itself be a full path to an object
   # x may be a a file in a run directory
   filepath <- file.path(directory, run, x)
   if(!nested) filepath <- file.path(directory, x)

   # x may exist solely in zipped form
   zpf <- function(x)paste0(x, '.7z')
   
   file <- NULL
   
   if(file_test('-f', zpf(filepath))) file <- zpf(filepath)
   if(file_test('-f', filepath))      file <- filepath
   if(file_test('-f', zpf(x)))        file <- zpf(x)
   if(file_test('-f', x))             file <- x
   
   if(is.null(file))stop('cannot find (7z version of) ', x, ' near ', directory)
   
   # now x file is unambiguous, and we "know" if it is zipped.
   test <- scan(file, what = 'character', sep = '\xbc', n = 1, quiet = TRUE)
   zipped <- test == '7z'
   if(zipped) file <- nm_unzip(zipped = file, temp = clean, ...)
   y <- scan(
      file = file,
      what = "character",
      sep = "\n",
      quiet = quiet
   )
   
   y <- paste(y, collapse = '\n')
   class(y) <- 'text'
   z <- read_gen(y, extension = extension, ...)
   z
}

#' Read NONMEM File as Run
#' 
#' Reads a NONMEM file, treating 'x' as a run name.
#' 
#' @param x character: a run name
#' @param extension character: a file extension indicating desired file type
#' @param directory character: optional location of x
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
# @param zipped is the file zipped using 7z?
#' @param ... passed arguments
#' @return length-one character of file contents, classified like 'extension'
#' @export
#' @keywords internal
#' @family gen

read_gen.run = function(
      x, 
      extension,
      directory, 
      quiet,
      clean,
      nested,
 #     zipped,
      ...
){
   # x may be a directory (run) in directory
   dirpath <- file.path(directory, x)
   
   dir <- NULL
   if(file_test('-d', dirpath)) dir <- dirpath
   if(file_test('-d', x)) dir <- x
   
   # now we know dir exists and is a directory and is a run name
   # the file target has the same basename and the indicated extension
   suppressWarnings( # @ 0.3.3
   run <-  basename(x)
   )
   file <- paste0(run, '.', extension)
   
   # since x is a run, dir is a rundir
   # therefore we ignore nested
   # and construct filepath without another reference to run
   #filepath <- file.path(dir, run, file)
   filepath <- file.path(dirname(dir), file)
   if(nested) filepath <- file.path(dir, file)
   
   # fall back to file
   class(filepath) <- 'file'
   
   read_gen(
      filepath,
      extension = extension,
      directory = directory,
      quiet = quiet,
      clean = clean,
      nested = nested,
  #    zipped = zipped,
      ...
   )
   
   
   
   
   
   
}

