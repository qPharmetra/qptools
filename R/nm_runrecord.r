globalVariables(c('ITERATION'))

#' Compile NONMEM Run Record
#' 
#' Compiles a NONMEM run record.
#' 
#' @export
#' @return data.frame
#' @family runrecord
#' @importFrom stringr str_split str_squish
#' @importFrom magrittr %>% %<>%
#' @param x character vector of run names, e.g. c('run1','run2')
#' @param directory path to working directory
#' @param extension length-two character: extensions identifying ext and lst files
#' @param nested length-two logical: whether ext and lst files are nested in run directory
#' @param index integer indicating choice of estimation method (defaults to last)
#' @param ... ignored
#' @examples
#' library(magrittr)
#' options(nmDir = getOption('qpExampleDir'))
#' nm_runrecord(runc(100:105))

nm_runrecord <- function(
   x, 
   directory = getOption("nmDir", getwd()),
   extension = c(
      getOption("nmFileExt", 'ext'),
      getOption("nmFileLst", 'lst')
   ),
   nested = c(TRUE, FALSE),
   index = NULL,
   ...
){
  stopifnot(is.logical(nested))
  nested <- rep(nested, length.out = 2)
  ## note that the index can only be a single number
  ## or a number equal to the length of the ok.runs
  
  if (length(x) < 1 || any(sapply(x, class) != "character")) {
    message("argument 'x' needs to be a character vector")
  }
  
  lookin <- directory
  if(nested[[2]]) lookin <- file.path(directory, x)
  ok.runs = sapply(
    x, 
    function(run) file.exists(
      file.path(
        lookin,
        paste(run, extension[[2]], sep=".")
      )
    )
  )
  if (sum(ok.runs) < 1) {
    message("no parseable run.lst found. No model building table created.")
    return()
  }

  ## now ok.runs becomes the runs that are ok
  ok.runs = x[ok.runs]
  
  ext = lapply(
    ok.runs, 
    function(x, directory, extension, nested) read_ext(
      x, 
      directory = directory, 
      extension = extension,
      nested = nested
    )  %>% lapply(., as.matrix)
    , 
    directory = directory, 
    extension = extension[[1]],
    nested = nested[[1]]
  )
  
  if(length(ok.runs) == 1 & length(ext[[1]])==1) {
    message("only one estimation method in one run supplied. A runrecord is futile, and no model building table was created.")
    return()
  }
  
  # flag results that can be 'get_ext'-ed, FALSE means MCMC BAYES-> need special treatment
  get_exted = ext %>% 
    lapply(., function(x) lapply(x,function(y) as.numeric(y[nrow(y),1]) < -999999999))

  ## special case if one ok run is supplied with multiple methods
  single_flag = 0  # if oly one run is specified
  if (length(ok.runs) == 1 & length(ext[[1]])>1) {
    single_flag = 1
    ok.runs = rep(ok.runs, length(ext[[1]]))
    index = seq(length(ok.runs))
  }
  
  methods = lapply(
     ok.runs, 
     function(
      x, 
      ..., 
      D = directory, 
      E = extension, 
      N = nested
     ) nm_methods(
      x, 
      ..., 
      directory = D, 
      extension = E, 
      nested = N
      )
     )
  
  if(single_flag==1) {
    methods = methods[[1]]
    methods = lapply(1:length(methods), function(x, methods) methods[x], methods=methods)
    ext = lapply(1:length(ext[[1]]), function(x,ext) ext[[1]][x], ext=ext)
    get_exted = lapply(1:length(get_exted[[1]]), function(x,get_exted) get_exted[[1]][x], get_exted=get_exted)
  }
  #names(methods) = ok.runs
  
  lst = sapply(
    ok.runs, 
    function(x, directory, extension, nested) read_lst(
      x, 
      directory = directory, 
      extension = extension
    ) %>% strsplit(., split = "\n"), 
    directory = directory, 
    extension = extension[[2]],
    nested = nested[[2]]
  )
  
  par = lapply(
    1:length(ok.runs), 
    function(x, ok.runs, directory, extension, nested, ext, get_exted) 
      lapply(1 : length(ext[[x]]), 
             function(i,x, ok.runs, directory, extension, nested, ext, get_exted)
      {
        if(get_exted[[x]][[i]]) ## if get_ext works as intended
        {
          foo = ok.runs[x] %>% read_ext(.,
            directory = directory, 
            extension = extension,
            nested = nested
          ) %>% as.matrix() 
          ## cut out the right matrix conditional on single or multiple runs:
          if(single_flag==0) foo = foo %>% .[i] else foo = foo %>% .[x]
          #foo = "run105" %>% read_ext %>% as.matrix() %>% .[2]
          bar <- c(
            paste('TABLE NO. 1:', names(foo)),
            paste(paste0(' ',names(foo[[1]])), collapse = ' '),
            paste0('  ', do.call(paste, foo[[1]]))
          )
          hey <- paste(bar, collapse = '\n')
          class(hey) <- 'ext'
          hey %>% get_ext %>% .[[1]]
        } else                  ## if there is nothing to be get_ext-ed
        {
          mat = ext[[x]][[i]] 
          nr = nrow(mat)
          mat = mat[,-1] 
          matnames = dimnames(mat)[[2]]
          mat = mat %>% as.numeric() %>% matrix(., nrow=nr)
          matdf = data.frame(matrix(mat[nrow(mat),], nrow=1)) 
          names(matdf) = matnames 
          matdf %<>% t %>% data.frame
          names(matdf) = "estimate"
          matdf %<>% mutate(se_est=NA,
                            eigen_cor=NA,
                            cond=NA,
                            om_sg=NA,
                            se_om_sg=NA,
                            fix=NA,
                            term=NA,
                            part_deriv_LL=NA)
          matdf
        }
      }, x=x, ok.runs=ok.runs, directory=directory, extension=extension, 
      nested=nested, ext=ext, get_exted=get_exted
      )
    , 
    directory = directory, 
    extension = extension[[1]],
    nested = nested[[1]],
    ext = ext,
    get_exted = get_exted,
    ok.runs = ok.runs
  )
  
  # number of estimation methods per run
  n_est_methods = sapply(1:length(ok.runs), function(x, par, ok.runs)
    length(par[[x]]), par=par, ok.runs = ok.runs)
  if (is.null(index)&single_flag==0) index = n_est_methods 
  if (!missing(index) & length(index) != length(ok.runs)) {
    message(
      "index supplied not of same length as number of parseable runs. Defaulting to last estimation method of each run."
    )
    index = n_est_methods
  }
  
  ## txt is the lst files split into a list of text belonging to each estimation method
  txt = lapply(lst, function(x) c(grep("#TBLN", x), length(x)))
  txt = lapply(1:length(txt), function(x,txt,index) 
    c(txt[[x]][index[x]],txt[[x]][index[x]+1])
    , txt=txt,index=index
  )
  txt = lapply(1 : length(txt), function(x, txt, lst){
    paste( lst[[x]][txt[[x]][1]:txt[[x]][2]] )
  }, txt = txt, lst = lst
  )
  
  nms = lapply(1:length(methods), function(x, nms,index) 
    nms[[x]][index[x]], nms=methods, index=index) %>% unlist()
  
  ## now we have all parameter tables, we name them acroding to run (1) and est method (2)
  par_save = lapply(1:length(par), function(x, par, nms, index) 
  {
    y = par[[x]]
    names(y) = nms[[x]]
    y
    }, par=par, index=index, nms=methods
  )
  names(par_save) = ok.runs ## par_save to not throw away all goodies (for later?) 
  
  ## zoom in on the estimation method of choice (index)
  par = lapply(1:length(par_save), function(x, par, index, single_flag) 
  {
    if(single_flag==0) par[[x]][index[x]] else par[[x]]
  }, par=par_save, index=index, single_flag=single_flag
  )
  
  estimated = lapply(par, function(x)
  {
    x = x[[1]]
    x %<>% mutate(parameter=substring(rownames(.),1,5))
    nth = paste0(sum(x$parameter=="THETA"&as.numeric(x$fix)==0),"/", sum(x$parameter=="THETA"))
    nom = paste0(sum(x$parameter=="OMEGA"&as.numeric(x$fix)==0),"/", sum(x$parameter=="OMEGA"))
    nsg = paste0(sum(x$parameter=="SIGMA"&as.numeric(x$fix)==0),"/", sum(x$parameter=="SIGMA"))
    npar= paste0(sum(as.numeric(x$fix)==0),"/", sum(nrow(x)))
    c(nth=nth,nom=nom,nsg=nsg,npar=npar)
  })
  
  ## create estimation method short hands
  meth = lapply(par, names)
  
  ##
  generic_methods = data.frame(full=c(
    "Iterative Two Stage",
    "Importance Sampling",
    "Importance Sampling assisted by Mode a Posteriori",
    "Objective Function Evaluation by Importance/MAP Sampling",
    "Stochastic Approximation Expectation-Maximization",
    "Objective Function Evaluation by Importance Sampling",
    "MCMC Bayesian Analysis",
    "First Order Conditional Estimation with Interaction",
    "First Order Conditional Estimation",
    "Conditional Estimation", # needed in case of Laplacian
    "Conditional Estimation with Interaction", # needed in case of Laplacian
    "First Order")
    , short = c("its","imp","impmap","impmap-e","saem", "imp-e","bayes","focei","foce","foce","focei","fo")
  )
  meth = lapply(meth, function(x) trimws(gsub('Laplacian ', '',x)))
  meth = lapply(meth, function(x) trimws(gsub('\\(.*?\\)', '',x)))
  meth = lapply(
     meth, 
     function(x,gm) gm$short[match(x, gm$full)], 
     gm=generic_methods
  )
  
  lapl = lapply(txt, tolower) %>% lapply(., function(x) substring(x[grepl("laplacian obj", tolower(x))], 43,45))
  if(is.list(lapl)) lapl = lapply(lapl,function(x)ifelse(length(x)==0,"NA",x)) %>% unlist()
  
  base = lapply(lst, function(x) x[grep("Based on:", x)])
  base = lapply(base, function(x) 
    extract_number(sub(".*Based on: ([A-Z,a-z,0-9]+)","\\1", x)[1])
  )
  
  dta = lapply(
    lst, 
    function(x)stringr::str_split(stringr::str_squish(x[grep("[$]DATA", x)]), " ")[[1]][-1]
  )
  ignores = lapply(dta, function(x) paste(x[-1], collapse = " "))
  dta = lapply(dta, function(x) x[1])
  
  Description = lapply(lst, function(x) substring(x[grep("Description:", x) + 1], 7))
  Description = lapply(Description, function(x) ifelse(length(x) == 0, "No Description", x))
  
  my_ofv <- function(x, directory, ok.runs, index, extension, nested) {
    ofv = get_ofv(
      ok.runs[x], 
      directory = directory, 
      extension = extension, 
      nested = nested,
      quiet=TRUE
    )[[index[x]]]
    return(ofv)
  }
  ofv = sapply(
    1:length(ok.runs), 
    my_ofv, 
    directory = directory, 
    ok.runs=ok.runs, 
    index=index, 
    extension = extension[[1]],
    nested = nested[[1]]
  )
  if(is.list(ofv)) ofv = lapply(ofv,function(x)ifelse(length(x)==0,NA,x)) %>% unlist()
         
  cn = sapply(
    1:length(ok.runs), 
    function(x, directory, extension, nested, ok.runs, index)nm_condition_number(
      ok.runs[x], 
      directory = directory, 
      extension = extension,
      nested = nested,
    )[[index[x]]]
    , 
    directory = directory, 
    extension = extension[[1]],
    nested = nested[[1]],
    ok.runs=ok.runs, 
    index=index
  )
  cn = sapply(cn, function(x){
    as.character(
      ifelse(is.null(x), "-", ifelse(as.numeric(x)>1e4, ">10,000",round(x,1)))
    )})
  
  nobs = sapply(lst, function(x)
    extract_number(gsub("TOT. NO. OF OBS RECS:", "", x[grep("TOT. NO. OF OBS RECS:", x)])))
  nids = sapply(lst, function(x)
    extract_number(gsub("TOT. NO. OF INDIVIDUALS:", "", x[grep("TOT. NO. OF INDIVIDUALS:", x)])))
  mins = sapply(txt, function(x)
    as.numeric(any(x[grep("0MINIMIZATION", x)] == "0MINIMIZATION SUCCESSFUL")))
  mins = lapply(mins, function(x) ifelse(length(x)==0,NA,x))
  rerr = sapply(txt, function(x) {
    y = 0
    if (length(x[grep("TERMINATED", x) + 1]) > 0)
      y = x[grep("ERROR=", x)] %>% gsub(x=., "[.]+","") %>% extract_number()
    if(length(grep("ERROR=", x))==0 & any(grepl("OBJ. FUNC. IS INFINITE",x))) y = 999
    return(y)
  })
  if(is.list(rerr)) rerr = lapply(rerr,function(x)ifelse(length(x)==0,NA,x)) %>% unlist()
  
  ## check mins and rerr
  
  dOFV = data.frame(
    Run = extract_number(ok.runs), 
    Ref = unlist(base), 
    OFV = ofv
  )
    
  dOFV$dOFV = as.numeric(with(dOFV,c(NA, ofv[-1] - ofv[match(Ref,Run)][-1])))
  dOFV = cbind(
    dOFV,
    data.frame(
      meth=unlist(meth),
      lap=unlist(lapl)
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


