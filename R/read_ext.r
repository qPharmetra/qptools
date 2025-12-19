globalVariables(c('ITERATION','eigen_cor','cond','part_deriv_LL','nm_model_labels','level','tab','n','extSum','extList'))
#' Read NONMEM EXT Results
#' 
#' Reads NONMEM EXT results.
#' Generic, with method \code{\link{read_ext.character}}
#' 
#' @export
#' @keywords internal
#' @family ext
#' @param x object of dispatch
#' @param ... passed
read_ext <- function(x, ...)UseMethod('read_ext')

#' Read NONMEM EXT Results for Character
#' 
#' Reads NONMEM EXT results for class character using \code{\link{read_gen.character}}.
#' 
#' @export
#' @family ext
#' @importFrom utils file_test
#' @param x character: a file path, or the name of a run in 'directory', or ext content
#' @param directory character: optional location of x
#' @param extension character: extension identifying ext files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
#' @param clue a text fragment expected to occur in cov files
#' @param ... passed arguments
#' @return length-one character of class 'ext'
#' @examples
#' library(magrittr)
#' options(nmDir = getOption('qpExampleDir'))
#' 'example1' %>% read_ext
#' 'example1.ext' %>% read_ext # same
#' path <- file.path(getOption('qpExampleDir'), 'example1', 'example1.ext.7z')
#' path
#' file.exists(path)
#' path %>% read_ext
#' 'example1' %>% read_ext %>% as.list %>% summary
#' 'example1' %>% get_ext # same
#' 'example1' %>% read_ext %>% nm_condition_number
#' 'example1' %>% nm_condition_number # same
#' 'example1' %>% nm_params_table


read_ext.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = getOption("nmFileExt", 'ext'),
      quiet = TRUE, 
      clean = TRUE,
      nested = TRUE,
      clue = 'ITERATION',
      ...
){
   y <- read_gen(
      x,
      directory = directory,
      extension = extension,
      quiet = quiet,
      clean = clean,
      nested = nested,
      clue = clue,
      ...
   )
   class(y) <- 'ext' # enforced
   y
}

#' Convert EXT to Matrix
#' 
#' Converts class 'ext' to matrix.
#' Alias for \code{\link{as.list.ext}}
#' 
#' @export
#' @family ext
#' @param x ext
#' @param ... ignored
#' @return extList
as.matrix.ext <- function(x, ...)as.list(x, ...)

#' Convert EXT to List
#' 
#' Converts class 'ext' to list.
#' 
#' @export
#' @family ext
#' @param x ext
#' @param ... ignored
#' @return extList
as.list.ext <- function(x, ...){
   # currently x is length 1
   # restore lines
   x <- strsplit(x, split = '\n')
   x <- x[[1]]
   
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
   xnam = lapply(x, function(y) unPaste(y[1], sep = ":"))
   names(x) = lapply(xnam, function(x) substring(x[2], 2))
   parse.table <- function(y) {
      y = y[-1]
      dfnames = unlist(unPaste(substring(y[1], 2), sep = "\\s+"))
      y = y[-1]
      yy = lapply(y, function(z) unPaste(substring(z, 2), sep = "\\s+"))
      yy = do.call("rbind", yy)
      yy = data.frame(yy[, -1])
      names(yy) = dfnames
      return(yy)
   }
   z <- lapply(x, parse.table)
   class(z) <- 'extList'
   z
}

#' Read NONMEM EXT results
#' 
#' Reads NONMEM EXT results for class 'ext'. 
#' Just returns its argument, which is already the result of reading EXT.
#' 
#' @export
#' @keywords internal
#' @family ext
#' @param x class 'ext'
#' @param ... ignored
#' @return character of class 'ext'
read_ext.ext <- function(x, ...) x

#' Summarize 'extList'
#' 
#' Summarizes 'extList'. See \code{\link{as.list.ext}}.
#' 
#' The stochastic iterations of the SAEM analysis are given negative values. 
#' These are followed by positive iterations of the accumulation phase.
#'   * Iteration -1000000000 (negative one billion) indicates that this line 
#'   contains the final result (thetas, omegas, and sigmas, and objective function) 
#'   of the particular analysis. For BAYES analysis, this is the mean of the 
#'   non-negative iterations (stationary samples) listed before it.
#'   * Iteration -1000000001 indicates that this line contains the standard 
#'   errors of the final population parameters. For BAYES, it is the sample 
#'   standard deviation of the stationary samples.
#'   * Iteration -1000000002 indicates that this line contains the eigenvalues 
#'   of the correlation matrix of the variances of the final parameters.
#'   * Iteration -1000000003 indicates that this line contains the condition 
#'   number , lowest, highest, Eigen values of the correlation matrix of the 
#'   variances of the final parameters.
#'   * Iteration -1000000004 indicates this line contains the OMEGA and SIGMA 
#'   elements in standard deviation/correlation format.
#'   * Iteration -1000000005 indicates this line contains the standard errors to 
#'   the OMEGA and SIGMA elements in standard deviation/correlation format.
#'   * Iteration -1000000006 indicates 1 if parameter was fixed in estimation, 0 otherwise.
#'   * Iteration -1000000007 lists termination status (first item) followed by 
#'   termination codes. See I.55 $EST: Additional Output Files Produced under 
#'   root.xml (NM72) for interpreting the codes.
#'   * Iteration -1000000008 lists the partial derivative of the log likelihood 
#'   (-1/2 OFV) with respect to each estimated parameter. This may be useful for 
#'   using tests like the Lagrange multiplier test.
#'   
#' @export
#' @family ext
#' @return data.frame
#' @param object class 'extList', as from \code{\link{as.list.ext}}
#' @param final logical: return just the iterations with numbers greater than zero
#' @param ... ignored
#' @importFrom dplyr filter left_join
#'   
summary.extList <-  function(
  object,
  final = FALSE,
  ...
){
   ext <- object
   my_names = data.frame(
      names = c(
         "estimate",
         "se_est",
         "eigen_cor",
         "cond",
         "om_sg",
         "se_om_sg",
         "fix",
         "term",
         "part_deriv_LL")
      , ITERATION = seq(-1000000000,-1000000008)
   )
   
   ## TTB 2025-08-25 
   ## eigen_cor (-1000000002) appears sorted (low to high, excluding zeros)
   ## and is thus not identifiable.  Removed from output as of qptools 4.5.1-13.
   
   my_names <- my_names[my_names$names != 'eigen_cor',]
   drop_eigen <- function(x){
      x <- x[x$ITERATION != -1000000002,]
      x
   }
   ext <- lapply(ext, drop_eigen)
   
   ## which ones are operable?
   msel = lapply(ext, function(x) any(x$ITERATION < {-1e9})) %>% unlist %>% as.logical()
   
   if(final) {
      ext = lapply(ext, function(x) x %>% filter(ITERATION > {-1000000000}))
      return(ext)
   }

   tab <- lapply(1:length(ext), function(x,ext,msel) {
     if(msel[x]) ext[[x]] %>% filter(ITERATION <= -1000000000) else {
       xx = ext[[x]] %>% 
         slice(n()) %>% 
         mutate(ITERATION=-1e9) 
       nms = names(xx)
       xx = matrix(unlist(xx) %>% as.numeric, nrow=1)
       xx %<>% as.data.frame() 
       names(xx) = nms
       xx
     }
   }, ext=ext, msel=msel
   )

   tab <- lapply(
      tab, 
      function(x) {
         if(nrow(x)>2) apply(x,2,as.numeric) else (x)
      }
   )
   tab = suppressMessages(
      lapply(tab, function(x, my_names) {
        x %>% 
                as.data.frame() %>% 
                left_join(my_names) 
      }, my_names=my_names
      )
   )
   tab = lapply(tab, function(x) t(x) %>% as.data.frame())
   tab = lapply(tab, function(x) {names(x) = x["names", ]; return(x)})
   tab = lapply(tab, function(x) {
      return(x[-c(1,nrow(x)+c(-1,0)),])
   })
   return(tab)
}


#' Get Ext Summary
#' 
#' Get ext summary.
#' Generic, with methods \code{\link{get_ext.character}} and \code{\link{get_ext.ext}}.
#' 
#' @export
#' @family ext
#' @param x object of dispatch
#' @keywords internal
#' @param ... passed arguments
get_ext <- function(x, ...)UseMethod('get_ext')

#' Get Ext Summary for Character
#' 
#' Get ext summary for character.
#' 
#' @export
#' @family ext
#' @param x character: a file path, or the name of a run in 'directory', or cov content
#' @param directory character: optional location of x
#' @param extension character: extension identifying cov files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested is the file nested within the run directory?
#' @param clue a text fragment expected to occur in cov files
#' @param final logical: return just the iterations with numbers greater than zero
#' @param ... passed arguments
#' @return list of covariance matrices as data frames
get_ext.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = getOption("nmFileExt", 'ext'),
      quiet = TRUE, 
      clean = TRUE,
      nested = TRUE,
      clue = 'ITERATION',
      final = FALSE,
      ...
){
   y <- read_ext(
      x,
      directory = directory,
      extension = extension,
      quiet = quiet,
      clean = clean,
      nested = nested,
      clue = clue,
      ...
   )
   nms <- names(as.list(y))
   out <- get_ext(y, final = final, ...)
   if(length(nms) == length(out)){
     names(out) <- nms
   }
   return(out)
}

#' Get EXT Summary for EXT
#' 
#' Get EXT Summary for EXT
#' 
#' @export
#' @keywords internal
#' @family ext
#' @param x ext
#' @param final logical: return just the iterations with numbers greater than zero
#' @param ... passed arguments
#' @return list of covariance matrices as data frames
get_ext.ext <- function(x, final = FALSE, ...){
   extList <- as.list(x, ...)
   extSum <- summary(extList, final = final, ...)
   extSum
}

#' Get EXT Summary for extList
#' 
#' Get EXT Summary for extList
#' 
#' @export
#' @keywords internal
#' @family ext
#' @param x ext
#' @param final logical: return just the iterations with numbers greater than zero
#' @param ... passed arguments
#' @return list of covariance matrices as data frames
get_ext.extList <- function(x, final = FALSE, ...){
  extSum <- summary(x, final = final, ...)
  extSum
}


