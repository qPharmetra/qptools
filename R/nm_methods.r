globalVariables(c('lst','nested','meth','generic_methods','nested'))

#' Get NONMEM Estimation Methods
#' 
#' Gets NONMEM estimation methods from the LST file.
#' 
#' @export
#' @family lst
#' @param x character: a file path, or the name of a run in 'directory', or lst content
#' @param directory character: optional location of x
#' @param extension length-two character: extensions identifying ext and lst files
#' @param nested length-two logical: are the ext and lst files nested within the run 
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param clue a text fragment expected to occur in cov files
#' @param ... passed arguments
#' @importFrom stringr str_split str_remove
#' @importFrom magrittr %>% 
#' @return string
#' @examples
#' dir <- getOption("qpExampleDir")
#' options(nmDir = dir)
#' nm_methods('run103')

nm_methods.character = function(x,
                      directory = getOption("nmDir", getwd()),
                      extension = c(getOption("nmFileLst", 'ext'),
                                    getOption("nmFileLst", 'lst')),
                      nested = c(TRUE, FALSE),
                      quiet = TRUE,
                      clean = TRUE,
                      clue = '\\$PROB',
                      ...)
{
  nested <- rep(nested, length.out = 2)
  lst = read_lst(
    x,
    directory = directory,
    extension = extension[[2]],
    quiet = quiet,
    clean = clean,
    nested = nested[[2]],
    clue = clue,
    ...
  )
  nm_methods(lst)
}

#' Get NONMEM Estimation Methods 
#' 
#' Gets NONMEM estimation methods 
#' @export
#' @family lst
#' @param x object of dispatch
#' @param ... passed arguments

nm_methods = function(x, ...) UseMethod("nm_methods")

#' Get NONMEM Estimation Methods for LST
#' 
#' Gets NONMEM estimation methods from the LST file.
#' @export
#' @family lst
#' @param x lst (see \code{\link{read_lst}})
#' @param ... passed arguments
#' @return character

nm_methods.lst = function(x,...)
{
  x <- strsplit(x, '\n')[[1]]
  x[grep("#TBLN", x) + 1] %>% str_remove(., " #METH: ")
}

#' Get NONMEM Estimation Methods (Short Version)
#' 
#' Gets NONMEM estimation methods from the LST file and abbreviates them.
#' 
#' @export
#' @family lst
#' @param x character: a file path, or the name of a run in 'directory', or lst content
#' @param directory character: optional location of x
#' @param extension length-two character: extensions identifying ext and lst files
#' @param nested length-two logical: are the ext and lst files nested within the run 
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param clue a text fragment expected to occur in cov files
#' @param ... passed arguments
#' @importFrom stringr str_split str_remove
#' @importFrom magrittr %>% 
#' @return string
#' @examples
#' dir <- getOption("qpExampleDir")
#' options(nmDir = dir)
#' nm_methods_short('run103')

nm_methods_short = function(x,
                            directory = getOption("nmDir", getwd()),
                            extension = c(getOption("nmFileLst", 'ext'),
                                          getOption("nmFileLst", 'lst')),
                            nested = c(TRUE, FALSE),
                            quiet = TRUE,
                            clean = TRUE,
                            clue = '\\$PROB',
                            ...)
{
  nested <- rep(nested, length.out = 2)
  meth = nm_methods(x, ...)
  
  generic_methods = data.frame(
    full = c(
      "Iterative Two Stage",
      "Importance Sampling",
      "Importance Sampling assisted by Mode a Posteriori",
      "Objective Function Evaluation by Importance/MAP Sampling",
      "Stochastic Approximation Expectation-Maximization",
      "Objective Function Evaluation by Importance Sampling",
      "MCMC Bayesian Analysis",
      "First Order Conditional Estimation with Interaction",
      "First Order Conditional Estimation",
      "Conditional Estimation",
      # needed in case of Laplacian
      "Conditional Estimation with Interaction",
      # needed in case of Laplacian
      "First Order"
    )
    ,
    short = c(
      "its",
      "imp",
      "impmap",
      "impmap-e",
      "saem",
      "imp-e",
      "bayes",
      "focei",
      "foce",
      "foce",
      "focei",
      "fo"
    )
  )
  meth = lapply(meth, function(x)
    trimws(gsub('Laplacian ', '', x)))
  meth = lapply(meth, function(x)
    trimws(gsub('\\(.*?\\)', '', x)))
  meth = lapply(meth, function(x, gm)
    gm$short[gm$full == x], gm = generic_methods)
  meth %>% unlist
}
