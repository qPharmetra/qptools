nm_runrecord_graph = function (runs
                               , path = getOption("nmDir")
                               , keep.cols = c("ID","DV", "CWRES", "PRED", "IPRED", "TIME", "EVID")
                               , alias = list(DV = "CONC",TIME = "TAFD") # DV and TIME may be 
                               , dot.size = 1
                               , text.size = 1
                               , log = FALSE) 
{
  myOrder = runs
  out = lapply(as.list(runs), function(x, mypath) 
    get.xpose.tables(run = x, path = mypath), mypath = path)
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
  ########## STOPPED here
  if(F) out = out %>% select(everything(vars=keep.cols))
  
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
  out = out %>% filter(EVID == 0)
  
  # if (log) {
  #   out$PRED = log10(out$PRED)
  #   out$TIME = log10(out$TIME)
  #   out$IPRED = log10(out$IPRED)
  #   out$DV = log10(out$DV)
  # }

  molten = pivot_longer(out, cols =  c("TIME", "PRED", "IPRED"), names_to = "xVariable", values_to = "xValue")    
  molten = pivot_longer(molten, cols = c("DV", "CWRES"), names_to = "variable", values_to = "value")
  molten$group = paste(molten$variable, molten$xVariable, sep = "~")
  molten = molten %>% filter(!group %in% c("DV~TIME", "CWRES~IPRED"))
  
  molten$variable = as.character(molten$variable)
  
  ofv = as.vector(sapply(runs[msel], function(x, mypath) 
    get.ofv(x,path = mypath)[1], mypath = path))
  #cat(ofv)
  
  ## create OFV info by run in 'molten'data format
  tmp = molten[duplicated(molten$run) == FALSE, ]
  tmp = rbind(tmp, tmp)
  tmp$xValue = rep(0:1, ea = length(runs[msel]))
  tmp$value = rep(0:1, ea = length(runs[msel]))
  tmp$group = "run.info"
  tmp$variable = rep(ofv, times = nrow(tmp)/length(runs[msel]))
  
  molten = rbind(molten, tmp)
  molten$variable[molten$group == "main.info"]
  molten$run = factor(molten$run, levels = myOrder)
  size = length(runs[msel])
  myXscale = if (log) 
    xscale.components.log10
  else lattice::xscale.components.default
  
  if(F){  ## tryout ggplot2 version - much harder than I thought
  molten %>%
    ggplot(aes(x=xValue,y=value)) +
    geom_point(data = . %>% filter(grepl("DV",group))
               , aes(x=xValue, y = value), col = "slategrey") +
    facet_grid(run~group) 
  }
  
  latticeExtra::useOuterStrips(
    lattice::xyplot(
      value ~ xValue | group * run,
      data = molten,
      aspect = 1,
      DATA = molten,
      scales = list(relation = "free", cex = 1 / sqrt(size)),
      par.strip.text = list(cex = 2 / sqrt(size)),
      dotSize = dot.size / sqrt(size),
      textSize = 2 * text.size / sqrt(size),
      panel = function(x,
                       y,
                       subscripts,
                       DATA,
                       dotSize,
                       textSize,
                       ...)
      {
        func = unique(DATA$group[subscripts])
        if (grepl("DV", func))
          panel.residual(x, y, ..., cex = dotSize)
        if (grepl("CWRES", func))
          panel.cwres(x, y, ..., cex = dotSize)
        if (grepl("run.info", func)) {
          panlim = lattice::current.panel.limits()
          lattice::ltext(0.5, 0.5, paste("OFV", unique(as.character(
            round(as.numeric(DATA$variable[subscripts]),
                  1)
          ))), cex = textSize)
        }
      },
      ylab = list("Residual or Predicted", cex = 1),
      xlab = list("x Variable", cex = 1),
      par.settings = latticeExtra::ggplot2like(),
      xscale.components = myXscale
    )
  )
  
}
