globalVariables(c('myFun','ci','out','thn','omn','sgn','len','ok','nms','start','end','boot_base','bootnames','transformations','theCIs','component','b_lower_ci','b_upper_ci'))
#' Create Parameter Table from NONMEM Bootstrap
#' 
#' Creates parameter table from NONMEM bootstrap procedure.
#' @param bootstrap A bootstrap object of class 'bootstrap' created by read_bootstrap.
#' @param probs The confidence interval coverage.
#' @param stat a list with at least option 'central' which is for a central tendency function of the distribution (e.g. median, mean)
#' @param digits number of significant digits in output; passed to \code{\link{formatted_signif}}
#' @param latex passed to \code{\link{formatted_signif}}
#' @param align.dot passed to \code{\link{formatted_signif}}
#' @param transformations a list with elements log or logit, that, in turn, are numeric vectors representating the THETA numbers that are logged or logit-transformed, respectively.
#' @return A data.frame with the bootstrap estimate. Check the output as assumptions are used for assignment of column 'parameter' and these may not fully match for OMEGA and SIGMA, which is especially untested for complex BLOCK OMEGA structures, and when IOV is coded via REPLACE.
#' @importFrom magrittr %>% %<>%
#' @importFrom dplyr mutate
#' @importFrom stats quantile
#' @importFrom utils tail
#' @importFrom tibble tibble
#' @export 
#' @examples
#' library(magrittr)
#' library(dplyr)
#' boot_dir = getOption("nmDir") %>% file.path(., "bootstrap")
#' fn_boot = "raw_results_run105bs.csv"
#' myBoot = read_bootstrap(
#'  directory = boot_dir,
#'  filename = fn_boot,
#' )
#' myBoot %>% tabulate_bootstrap
#' myBoot %>% tabulate_bootstrap(transformations=list(log=c(1,4),logit=c(6,7)))
#'
#' # merge bootstrap results in
#' param105 = "run105" %>% nm_params_table() %>% lol
#' theBoots = myBoot %>% tabulate_bootstrap()
#' param105 %<>% left_join(theBoots %>% filter(parameter !="ofv") %>% select(parameter,b_central,b_CI))
#' param105 %>% select(parameter,estimate, se_est, CI95, shrinksd, b_central,b_CI)

tabulate_bootstrap <- function(
    bootstrap,
    probs = 0.95,
    stat = list(central=median),
    digits = 3,
    latex = FALSE,
    align.dot = FALSE,
    transformations = NULL
) {
  myFun <- function(x, type)
  {
    switch(
      type,
      log = exp(x),
      log10 = 10 ^ x,
      logit = logit_inv(x)
    )
  }
  stopifnot(class(bootstrap)=="bootstrap")
  stopifnot(length(probs) == 1)
  ci = c((1 - probs) / 2, (probs + 1) / 2)
  
  boot_base = bootstrap$boot_base
  boot_base = do.call("cbind",boot_base) %>% tibble()
  
  ## apply transformations
  if (!is.null(transformations))
    if (is.list(transformations))
    {
      len = length(transformations)
      if((lapply(transformations,length) %>% unlist %>% max)>bootstrap$structure %>% filter(component=="theta") %$% end)
      {
        message("if specified, transformations must be a list of log (non-zero positive numbers) and/or logit (non-zero positive numbers) with the max of those numbers not exceeding the number of THETAs. Exiting without result.")
        return()
      }
      for (x in seq(len))
      {
        ok = transformations[[x]]
        nms = names(transformations)[x]
        boot_base[,ok] = myFun(boot_base[,ok], nms)
      }
    }
  
  
  bootnames = names(boot_base)
  ok = grep("[.]",bootnames)
  result = lapply(regmatches(bootnames, regexec("X(\\d+)\\.+(.*)", bootnames, perl=TRUE)), function(x) tail(x,-1))
  thn=bootstrap$bootstrap$theta%>%names%>%length
  omn=bootstrap$bootstrap$omega%>%names%>%length
  sgn=bootstrap$bootstrap$sigma%>%names%>%length
  ok = grep("[.]",bootnames)
  
  out = data.frame(index=1:length(result))
  out %<>% mutate(parameter = c(paste0("THETA",seq(thn)),
                             paste0("OMEGA(",seq(omn),",",seq(omn),")"),
                             paste0("SIGMA(",seq(sgn),",",seq(sgn),")"),
                             "ofv"),
                  pclass = c(rep("THETA", length=thn),
                             rep("OMEGA",length=omn),
                             rep("SIGMA",length=sgn),
                             "OFV")
  )
  
  out$Descriptor = c("")
  out$Descriptor[ok] = lapply(result[ok],function(x)x[2]) 
  out$Descriptor[nrow(out)] = "OFV"
  
  out$est_original = boot_base[1,] %>% unlist()
  out$b_central = apply(boot_base[-1,],2,stat$central)
  theCIs = apply(
    boot_base[-1, ], 2, quantile, probs = ci
  )
  out$b_lower_ci = theCIs[1,]
  out$b_upper_ci = theCIs[2,]
  out %<>% mutate(b_CI = paste(
    b_lower_ci %>%
      formatted_signif(
        digits = digits,
        latex = latex,
        align.dot = align.dot
      ),
    "-",
    b_upper_ci %>%
      formatted_signif(
        digits = digits,
        latex = latex,
        align.dot = align.dot
      )
  ))
  out %<>% mutate(probs = probs)
  out %<>% mutate(transformed = "no")
  out$transformed[match(transformations %>% unlist %>% as.numeric(), out$index)] =
    lapply(1:length(transformations), function(x, trans)
      rep(names(trans)[x], length(trans[[x]])), trans =
        transformations) %>% unlist
  out
  out$parameter %<>% as_nms_nonmem
  class(out) = "data.frame"
  return(out)
}
