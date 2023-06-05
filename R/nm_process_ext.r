###process the ext file further

#run = "run1298"
#options(qpFileExt = "ext")

nm_process_ext = function(run,
                       path = getOption("nmDir"),
                       file.ext = getOption("nmFileExt"),
                       keep="final") # final or trail
{
  my_names = data.frame(
    names = c(
    "estimate",
    "se",
    "eigen_cor",
    "cond",
    "om_sg",
    "se_om_sg",
    "fixed",
    "term",
    "part_deriv_LL")
    , ITERATION = seq(-1000000000,-1000000008)
  )
  
  ext = read_ext(run = run, path = path, file.ext = file.ext)
  if(keep=="trail") {ext = lapply(ext, function(x) x %>% filter(ITERATION>0)); return(ext)}
  tab = lapply(ext, function(x) x %>% filter(ITERATION <= -1000000000))
  tab = lapply(tab, function(x) {
    #y=as.numeric(unlist(x$ITERATION))
    apply(x,2,as.numeric)
    #return(cbind(x,y))
  }
  )
  tab = suppressMessages(
    lapply(tab, function(x, my_names) x %>% 
                 as.data.frame() %>% 
                 left_join(my_names) 
               , my_names=my_names
    )
  )
  tab = lapply(tab, function(x) t(x) %>% as.data.frame())
  tab = lapply(tab, function(x) {names(x) = x["names", ]; return(x)})
  
  tab = lapply(tab, function(x) {
    return(x[-c(1,nrow(x)+c(-1,0)),])
  })
  return(tab)
}

#nm_process_ext("run1298")
#nm_process_ext("run1298", keep = "trail")
#nm_process_ext(run="example2", path = getOption("qpExampleDir"))

# The stochastic iterations of the SAEM analysis are given negative values. These are followed by positive iterations of the accumulation phase.
# 3) Iteration -1000000000 (negative one billion) indicates that this line contains the final result (thetas, omegas, and sigmas, and objective function) of the particular analysis. For BAYES analysis, this is the mean of the non-negative iterations (stationary samples) listed before it.
# 4) Iteration -1000000001 indicates that this line contains the standard errors of the final population parameters. For BAYES, it is the sample standard deviation of the stationary samples.
# 5) Iteration -1000000002 indicates that this line contains the eigenvalues of the correlation matrix of the variances of the final parameters.
# 6) Iteration -1000000003 indicates that this line contains the condition number , lowest, highest, Eigen values of the correlation matrix of the variances of the final parameters.
# 7) Iteration -1000000004 indicates this line contains the OMEGA and SIGMA elements in standard deviation/correlation format
# 8) Iteration -1000000005 indicates this line contains the standard errors to the OMEGA and SIGMA elements in standard deviation/correlation format
# 9) Iteration -1000000006 indicates 1 if parameter was fixed in estimation, 0 otherwise
# 10) Iteration -1000000007 lists termination status (first item) followed by termination codes. See I.55 $EST: Additional Output Files Produced under root.xml (NM72) for interpreting the codes.
# 11) Iteration -1000000008 lists the partial derivative of the log likelihood (-1/2 OFV) with respect to each estimated parameter. This may be useful for using tests like the Lagrange multiplier test.

