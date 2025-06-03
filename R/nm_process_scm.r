globalVariables(c('V1','V2','V3','V4','V5','V6','V7','V8','V9','Step','step','direction','chosen','Chosen','pvalue','deltadf','significant'))

#' Parse SCM Output
#' 
#' Reads and processes SCM output file such that the output can be directly copied into Microsoft products and LaTeX typesetting.
#' 
#' @param directory full directory path where scmlog files reside
#' @param scmlog name of scm log of interest
#' @param ... ignored
#' @return data.frame
#' @export
#' @importFrom dplyr rename
#' @importFrom dplyr select
#' @importFrom dplyr group_by
#' @importFrom dplyr slice
#' @importFrom dplyr ungroup
#' @importFrom dplyr mutate_at
#' @importFrom magrittr %>%
#' @importFrom readr read_fwf
#' @importFrom readr fwf_positions
#' @examples
#' library(magrittr)
#' library(dplyr)
#' library(knitr)
#' library(yamlet)
#' path = file.path(getOption("qpExampleDir"),"scm_example2")
#' nm_process_scm(path)
#' nm_process_scm(path) %>% 
#'   filter(chosen == 1) %>%                      # summary
#'   select(step, model, direction, pvalue) %>%
#'   alias %>%                                    # labels as column names
#'   resolve %>%                                  # substitute guide values 
#'   kable
#'  # model:
#' path %>% nm_process_scm %>% filter(chosen == 1) %>%
#'    select(model)

nm_process_scm <- function (directory, scmlog = "scmlog.txt", ...) {
  stopifnot(length(directory) == 1)
  stopifnot(is.character(directory))
  
  x <- readLines(file.path(directory, scmlog))
  
  # step  model  ofvbase    ofvtest       dofv       goal  deltadf significant             pvalue chosen direction
  #    1      1  CLAGE-5  -5494.546  -8791.872 3297.32607   6.6349       1           1 0.0000e+00      0         +
  #    2      1 CLGNDR-2  -5494.546  -9557.268 4062.72165   6.6349       1           1 0.0000e+00      1         +
  
  b <- grepl('Starting backward search',x)
  stopifnot(sum(b) <= 1)
  
  bs <- cumsum(b)
  tb=x[bs==1]
  tf=x[bs==0]
  
  f <- scm_search(x[bs == 0], direction = 1)
  b <- scm_search(x[bs == 1], direction = -1)
  
  if(nrow(b)){
    b$step <- b$step + max(f$step)
    f <- bind_rows(f,b)
  } 
  
  x <- f
  
  attr(x$step, 'label') <- 'Step'
  attr(x$model, 'label') <- 'Model'
  attr(x$ofvbase, 'label') <- 'Base Objective Function Value'
  attr(x$ofvtest, 'label') <- 'Test Objective Function Value'
  attr(x$dofv, 'label') <- 'Delta Objective Function Value'
  attr(x$goal, 'label') <- 'Reference Delta Objective Function Value'
  attr(x$deltadf, 'label') <- 'Delta Degrees of Freedom'
  attr(x$significant, 'label') <- 'Significant'
  attr(x$significant, 'guide') <- list(no = 0, yes = 1)
  attr(x$pvalue, 'label') <- 'Test P-value'
  attr(x$chosen, 'label') <- 'Effect Was Selected'
  attr(x$chosen, 'guide') <- list(no = 0, yes = 1)
  attr(x$direction, 'label') <- 'Search Type'
  attr(x$direction, 'guide') <- list(Addition = 1, Deletion = -1)
  class(x) <- union('decorated', class(x))
  class(x) <- union('scm', class(x))
  return(x)
}

scm_search <- function(x, direction, ...){
  step <- grepl('^MODEL', x)
  step <- cumsum(step)
  x <- x[step > 0]
  step <- step[step > 0]
  x <- split(x, f = step)
  x <- lapply(x, scm_step, direction = direction, ...)
  for(s in seq_along(x)){
    if(nrow(x[[s]])) x[[s]]$step <- s
  }
  x <- do.call(bind_rows, x, ...)
  x
}


scm_step <- function(x, direction, ...){
  
  chosen <- grepl('Parameter-covariate relation', x)
  chosen <- cumsum(chosen)
  stopifnot(all(chosen <= 1))
  select <- scm_chosen(x[chosen == 1])
  
  y <- scm_table(x[chosen == 0], direction = direction, ...)
  
  if(nrow(y)){
    y$chosen[y$model == select] <- 1
    stopifnot(sum(y$chosen) <= 1)
  }
  y
}

scm_table <- function(x, direction, ...){
  x <- x[x != '']             # can't be empty
  x <- x[!grepl('^\\s', x)]   # can't start with whitespace
  x <- x[!grepl('^-', x)]     # can't start with dash
  x <- x[!grepl('MODEL', x)]  # drop header, expect 10 columns
  if(length(x) == 0) return(
    data.frame(
      step = integer(0),
      model = character(0),
      ofvbase = numeric(0),
      ofvtest = numeric(0),
      dofv = numeric(0), 
      goal = numeric(0),
      deltadf = integer(0), 
      significant = integer(0),
      pvalue = numeric(0), 
      chosen = integer(0), 
      direction = character(0)
    )
  )
  #if(length(x) == 1) x <- paste0(x,'\n')
  # paste unconditionally to work around error in readr 1.1.1 (1.3.1 okay)
  x <- paste0(x,'\n') 
  z <- read_fwf(
    x,
    col_positions = fwf_positions(
      col_names = c( 
        'model','test',  'ofvbase',  'ofvtest',  
        'dofv','gt' , 'goal',  'deltadf',
        'significant', 'pvalue'
      ),
      start = c(1, 18, 22, 35, 48, 69, 72, 82, 87, 99),
      end =   c(   17, 21, 34, 47, 68, 71, 81, 86, 98, NA)
    ),
    col_types = c('ccnnncnicn')
  )
  
  z <- data.frame(z)
  z$gt <- NULL
  z$step <- 0L
  z$chosen <- 0L
  z$direction <- direction
  z <- z[,c(
    'step','model','ofvbase','ofvtest',
    'dofv','goal','deltadf','significant',
    'pvalue', 'chosen','direction'
  )]
  z$significant <- as.integer(!is.na(z$significant))
  z
}


scm_chosen <- function(x, ...){
  if(!length(x)) return('')
  x <- x[[1]]
  x <- sub('[^:]+: +','', x)
  x <- sub('-','', x)
  x
}
