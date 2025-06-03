globalVariables(c('group', 'xValue', 'variable'))
#' Graph a Runrecord
#' 
#' Graphs a runrecord.
#' See \code{\link{nm_runrecord}}.
#' 
#' @export
#' @family runrecord
#' @return ggplot
#' @param x character vector of run names, e.g. c('run1','run2')
#' @param directory path to working directory
#' @param keep.cols character: columns to keep
#' @param alias named vector of aliases to substitute
#' @param index integer indicating choice of estimation method (defaults to last)
#' @param extension length-character indicating extensions for ext and lst files
#' @param nested length-two logical indicating whether ext and lst files are nested in run directory
#' @param dot.size dot size
#' @param text.size text size
#' @param yLimits numeric vector of length 2 given the limits of the y axis
#' @param ... passed to other functions
#' @importFrom dplyr everything filter 
#' @importFrom tidyr pivot_longer
#' @importFrom utils read.table
#' @examples
#' 
#' nm_runrecord_graph(
#'   c('run101', 'run102', 'run103', 'run104', 'run105'),
#'   directory = getOption('qpExampleDir')
#' )


nm_runrecord_graph <- function (
   x, 
   directory = getOption("nmDir"), 
   keep.cols = c("ID","DV", "CWRES", "PRED", "IPRED", "TIME", "EVID"), 
   alias = list(DV = "CONC", TIME = "TIME"), # DV and TIME maybe 
   index = NULL,
   extension = c(
      getOption("nmFileExt", 'ext'), 
      getOption("nmFileLst", 'lst')
   ),
   nested = c(TRUE, FALSE),
   dot.size = 1, 
   text.size = 1,
   yLimits = NULL,
   ...
) 
{
  stopifnot(is.logical(nested))
  nested <- rep(nested, length.out = 2)
  lookin <- directory
  if(nested[[2]]) lookin <- file.path(directory, x)
  ok.runs = sapply(
     x, 
    function(run) file.exists(
       file.path(
          lookin,
          paste(
             run,
             extension[[2]], 
             sep="."
          )
       )
    )
  )
  
  ## now ok.runs becomes the runs that are ok
  ok.runs = x[ok.runs]
  
  runs = ok.runs
  myOrder = runs
  out = lapply(
     as.list(runs), 
     function(x, mypath, ...){
        get_xpose_tables(x, directory = mypath, ...)
     },
   mypath = directory,
   ...
)
    
  names(out) = runs
  
  ## check for aliases (e.g. CONC=DV and/or TAFD=TIME)
  if (any(unlist(lapply(out, function(x, keep.cols) 
    length(setdiff(keep.cols, names(x))) > 0, keep.cols = keep.cols))))
    {
    out = lapply(out, function(x, alias) {
      if (length(x[, alias$DV]) > 0) x$DV = x[, alias$DV]
      if (length(x[, alias$TIME]) > 0 & length(x$TIME) == 0) x$TIME = x[, alias$TIME]
      return(x)
    }, alias = alias)
  }

  #if(F) out = out %>% select(everything(vars=keep.cols))
  
  out = lapply(seq(length(runs)), function(x, out, keep.cols) 
    {
    X = out[[x]][, keep.cols]
    X$run = names(out)[x]
    return(X)
  }, out = out, keep.cols = keep.cols)
  
  ## keep the ones that actually have an output file
  msel = unlist(lapply(out, is.data.frame))
  out = out[msel]
  
  out = do.call("rbind", out)
  out = out %>% dplyr::filter(EVID == 0)
  
  # if (log) {
  #   out$PRED = log10(out$PRED)
  #   out$TIME = log10(out$TIME)
  #   out$IPRED = log10(out$IPRED)
  #   out$DV = log10(out$DV)
  # }

  molten = tidyr::pivot_longer(out, cols =  c("TIME", "PRED", "IPRED"), names_to = "xVariable", values_to = "xValue")    
  molten = tidyr::pivot_longer(molten, cols = c("DV", "CWRES"), names_to = "variable", values_to = "value")
  molten$group = paste(molten$variable, molten$xVariable, sep = "~")
  molten = molten %>% dplyr::filter(!group %in% c("DV~TIME", "CWRES~IPRED"))
  
  molten$variable = as.character(molten$variable)
  
  ofv = sapply(
     runs[msel], 
     function(x, mypath, ...) get_ofv(x,directory = mypath, ...)[1], 
     mypath = directory,
     ...
  )
  
  ofv = as.vector(ofv)
  
  # number of estimation methods per run
  lookin <- directory
  if(nested[[1]]) lookin <- file.path(directory, x)
  n_est_methods = sapply(
     1:length(ok.runs), 
     function(x, directory, extension, ok.runs, nested){
        length(
           as.list(
              read_ext(
                ok.runs[x],
                directory = directory, 
                extension = extension,
                nested = nested
              ) 
           )
        )
    }
    , 
    directory = directory, 
    extension = extension[[1]], 
    nested = nested[[1]],
    ok.runs = ok.runs
  )
  
  if (is.null(index)) index = n_est_methods
  if (!missing(index) & length(index) != length(ok.runs)) {
    message(
      "index supplied not of same length as number of parseable runs. Defaulting to last estimation method of each run."
    )
    index = n_est_methods
  }
  
  ## get the OFV fr each run conditional on index (which estimation method to use)
  ofv = sapply(
    1:length(ok.runs), 
    function(x, directory, ok.runs, index, extension, nested) {
      ofv = get_ofv(
         ok.runs[x], 
         directory = directory, 
         extension = extension,
         nested = nested,
         quiet=TRUE
      )[[index[x]]]
      return(ofv)
    }, 
    directory = directory, 
    ok.runs=ok.runs, 
    index=index, 
    extension = extension[[1]],
    nested = nested[[1]]
  )
  
  ## create OFV info by run in 'molten'data format
  tmp = molten[duplicated(molten$run) == FALSE, ]
  tmp = rbind(tmp, tmp)
  tmp$xValue = rep(0:1, ea = length(runs[msel]))
  tmp$value = rep(0:1, ea = length(runs[msel]))
  tmp$group = "run.info"
  tmp$variable = rep(paste("OFV", ofv), times = nrow(tmp)/length(runs[msel]))
  
  molten = rbind(molten, tmp)
  molten$variable[molten$group == "main.info"]
  molten$run = factor(molten$run, levels = myOrder)
  size = length(runs[msel])
  
  if(is.null(yLimits)) yLimits=c(-1,1)*ceiling(max(abs(molten$value[grepl("CWRES", molten$group)])))
  
  ggplot2::ggplot(data = molten %>% dplyr::filter(!grepl("DV", group))
                  , mapping=aes(x=xValue,y=value)) +
    #geom_point(data = . %>% dplyr::filter(grepl("DV", group)), col = "slategrey") +
    geom_point(data = . %>% dplyr::filter(grepl("CWRES", group)), col = "slategrey",pch=16) +
    geom_smooth(data = . %>% dplyr::filter(grepl("CWRES", group)), col = "navyblue", se=T) +
    geom_label(data = . %>% dplyr::filter(group=="run.info"), x=0.5,y=0, aes(label=variable), size={13/length(ok.runs)}) +
    facet_grid(run~group, scales = "free_x") +
    theme(aspect.ratio = 1)+
    coord_cartesian(ylim=yLimits)
  
}
