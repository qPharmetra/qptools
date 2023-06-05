
nm_runrecord = function(runs = c("run1", "run2"),
                         path = getOption("nmDir"), 
                         file.lst = getOption("nmFileLst"),
                        file.ext = getOption("nmFileExt"), 
                        cn.sig=3, 
                        index) 
{
  ## note that the index can only be a single number
  ## or a number equal to the length of the ok.runs
  
  if (length(runs) < 2 || any(sapply(runs, class) != "character")) {
    message("argument 'runs' needs to be a character vector of at least length 2")
  }
  ok.runs = sapply(runs, 
                   function(run) file.exists(file.path(path,paste(run, file.lst,sep=".")))
  )
  if (sum(ok.runs) <= 1) {
    message("none or only one parseable run.lst found. No model building table created.")
    return()
  }

  ## now ok.runs becomes the runs that are ok
  ok.runs = runs[ok.runs]
  
  # number of estimation methods per run
  n_est_methods = sapply(1:length(ok.runs), function(x, path, file.ext, ok.runs)
    length(read_ext(
      ok.runs[x], path = path, file.ext = file.ext
    ))
    , path = path, file.ext = file.ext, ok.runs = ok.runs)
  if (missing(index))
    index = n_est_methods
  if (!missing(index) &
      length(index) != length(ok.runs)) {
    message(
      "index supplied not of same length as number of parseable runs. Defaulting to last estimation method of each run."
    )
    index = n_est_methods
  }
  
  lst = sapply(ok.runs, function(x, path, file.lst) 
    read_lst(x, path = file.path(path), file.lst = file.lst)
    , path = path, file.lst = file.lst)
  ext = sapply(ok.runs, function(x, path, file.ext) 
    read_ext(x, path = file.path(path), file.ext = file.ext)
    , path = path, file.ext = file.ext)
  estimated = lapply(ext, function(x) {
    msel = x %>% dplyr::filter(ITERATION<0) %>% select(-ITERATION) %>% select(-contains("OBJ")) 
    nth = sum(msel[2,]!=1e+10 & grepl("THETA", names(msel)))
    nom = sum(msel[2,]!=1e+10 & grepl("OMEGA", names(msel)))
    nsg = sum(msel[2,]!=1e+10 & grepl("SIGMA", names(msel)))
    return(c(nth=nth,nom=nom,nsg=nsg, npar=nth+nom+nsg))
  })
  
  ## create estimation method short hands
  meth = lapply(str_split(names(ext),"[.]"), function(x) x[2])
  
  generic_methods = data.frame(full=c(
    "Iterative Two Stage",
    "Importance Sampling",
    "Importance Sampling assisted by Mode a Posteriori",
    "Stochastic Approximation Expectation-Maximization",
    "Objective Function Evaluation by Importance Sampling",
    "MCMC Bayesian Analysis",
    "First Order Conditional Estimation with Interaction",
    "First Order Conditional Estimation")
  , short = c("its","imp","impmap","saem", "imp-e","bayes","focei","foce")
  )
  meth = lapply(meth, function(x) trimws(gsub('\\(.*?\\)', '',x)))
  meth = lapply(meth, function(x,gm) gm$short[gm$full==x], gm=generic_methods)

  base = lapply(lst, function(x) x[grep("Based on:", x)])
  base = lapply(base, function(x) 
    extract.number(sub(".*Based on: ([A-Z,a-z,0-9]+)","\\1", x)[1])
  )
  
  dta = lapply(lst, function(x) 
    str_split(stringr::str_squish(x[grep("[$]DATA", x)]), " ")[[1]][-1])
  ignores = lapply(dta, function(x) paste(x[-1], collapse = " "))
  dta = lapply(dta, function(x) x[1])

  Description = lapply(lst, function(x) 
    substring(x[grep("Description:", x) + 1], 7))
  Description = lapply(Description, function(x) 
    ifelse(length(x) == 0, "No Description", x))
  
  ofv = sapply(1:length(ok.runs), function(x, path, ok.runs, index, file.lst) {
    ofv = get_ofv(ok.runs[x], path = path, file.ext = file.ext)[[index[x]]]
    return(ofv)
  }, path = path, ok.runs=ok.runs, index=index, file.lst = file.lst
  )
  
  ## i think this line can be dropped
  if(F) if (is.list(ofv)) ofv = unlist(lapply(ofv, function(x) x[length(x)]))

  cn = sapply(1:length(ok.runs), function(x, path, file.ext, ok.runs, index)
    nm_condition_number(ok.runs[x], path = path, file.ext = file.ext)[[index[x]]]
    , path = path, file.ext = file.ext, ok.runs=ok.runs, index=index
  )
  cn = sapply(cn, function(x){
    as.character(
    ifelse(is.null(x), "-", ifelse(as.numeric(x)>1e4, ">10,000",round(x,1)))
    )})
 
  nobs = sapply(lst, function(x)
    extract.number(gsub("TOT. NO. OF OBS RECS:", "", x[grep("TOT. NO. OF OBS RECS:",x)]))
  )
  nids = sapply(lst, function(x)
    extract.number(gsub("TOT. NO. OF INDIVIDUALS:","",x[grep("TOT. NO. OF INDIVIDUALS:",x)]))
  )
  mins = sapply(lst, function(x)
    as.numeric(x[grep("0MINIMIZATION",x)] == "0MINIMIZATION SUCCESSFUL")
  )
  rerr = sapply(lst, function(x){
    y=0
    if(length(x[grep("TERMINATED",x)+1])>0) 
      y = as.numeric(x[grep("TERMINATED",x)+1] == " DUE TO ROUNDING ERRORS (ERROR=134)")
    return(y)
  }
  )
  
  dOFV = data.frame(Run = extract.number(ok.runs)
                    , Ref = unlist(base)
                    , OFV = ofv
                    )
  dOFV$dOFV = as.numeric(with(dOFV,c(NA, ofv[-1] - ofv[match(Ref,Run)][-1])))
  dOFV = cbind(dOFV
               , data.frame(meth=unlist(meth)
                            , min = as.numeric(unlist(mins))
                            , rerr = rerr
                            , cn = cn
                            , data=unlist(dta)
                            , nids = nids
                            , nobs = nobs
                            , nth = unlist(lapply(estimated, function(x) x["nth"]))
                            , nom = unlist(lapply(estimated, function(x) x["nom"]))
                            , nsg = unlist(lapply(estimated, function(x) x["nsg"]))
                            , npar = unlist(lapply(estimated, function(x) x["npar"]))
                            , Description = unlist(Description)
               )
  )
  row.names(dOFV) = seq(nrow(dOFV))
  dOFV
}

#nm_runrecord(runs=paste0("run",1250:1298), path = getOption("nmDir"))
