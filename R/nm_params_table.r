globalVariables(c('ext', 'nms', 'par_table', 'shrink', 'pardef','RSE', 'estimate_save', 'shrinksd','whats', 'parameter', 'label', 'CI95', 'symbol','Name','ITEM','myFormat','estimate_untransf','se_est_untransf'))


#' Get Parameter Table
#' 
#' Gets a parameter table. Generic, with method
#' \code{\link{nm_params_table.character}}.
#' @export
#' @keywords internal
#' @param x object of dispatch
#' @param ... passed arguments
#' @family ext
nm_params_table <- function(x, ...)UseMethod('nm_params_table')

#' Get Parameter Table for Character
#' 
#' Gets a parameter table for a finished run. Uses EXT file.
#' See also \code{\link{get_est_table}} which uses \pkg{pmxTools}
#' to construct a parameter table from the XML.
#' See also \code{\link[nonmemica]{partab}} which does similar.
#' 
#' @export
#' @family ext
#' @return data.frame with class 'nmpartab'
#' @param x character: a file path, or the name of a run in 'directory', or ext content
#' @param directory character: optional location of x
#' @param extension length-two character: extensions identifying ext and lst files
#' @param quiet logical: flag for displaying intermediate output
#' @param clean should the unzipped file be removed when done (defaults to TRUE)
#' @param nested length-two logical: are ext and lst files nested within the run directory?
#' @param clue a text fragment expected to occur in cov files
#' @param keep_stat a text fragment indicating whether to take shrinkage variance ('VR') of standard deviation ('SD', default). 
#' @param keep_type a text fragment indicating whether to take shrinkage 'EBV' or 'ETA' (default)
#' @param ci.sep character: character to separate confidence intervals by
#' @param fields character: names of semicolon-delimited fields to expect in control streams
#' @param digits numeric: number of significant digits to display in 95 percent confidence interval (returned as text); use \code{format(digits=)} to control significance of other variables
#' @param ... passed to \code{\link{read_ext.character}}
#' @importFrom magrittr %>% %<>%
#' @importFrom dplyr mutate select left_join
#' @importFrom tidyselect everything
#' @importFrom nonmemica definitions as_nms_nonmem nms_pmx as_nms_canonical nms_canonical nms_nonmem
#' @examples
#' library(magrittr)
#' library(dplyr)
#' options(nmDir = getOption("qpExampleDir"))
#' "example1" %>% nm_params_table
#' "run103" %>% nm_params_table
#' "run103" %>% nm_params_table_short
#' "run103" %>% nm_params_table %>% lol
#' "run103" %>% nm_params_table %>% 
#'    lol %>% 
#'    format(
#'       paste_label_unit='label', 
#'       latex=TRUE
#'    ) %>% 
#'    knitr::kable(
#'      format="latex",
#'      escape=FALSE, 
#'      booktabs=TRUE
#'    ) 
#'
#' # merge bootstrap results in
#' boot_dir = getOption("nmDir") %>% file.path(., "bootstrap")
#' param105 = "run105" %>% nm_params_table() %>% lol
#' fn_boot = "raw_results_run105bs.csv"
#' bootstrap = read_bootstrap(boot_dir, filename = fn_boot)
#' theBoots = bootstrap %>% tabulate_bootstrap()
#' param105 %<>% left_join(theBoots %>% filter(parameter !="ofv") %>% select(parameter,b_central,b_CI))
#' param105 %>% select(parameter,estimate, se_est, CI95, shrinksd, b_central,b_CI)

nm_params_table.character <- function(
      x, 
      directory = getOption("nmDir", getwd()), 
      extension = c(
         getOption("nmFileExt", 'ext'),
         getOption("nmFileLst", 'lst')
      ),
      quiet = TRUE, 
      clean = TRUE,
      nested = c(TRUE, FALSE),
      clue = 'ITERATION',
      keep_stat = "SD",
      keep_type = "ETA",
      ci.sep = " - ",
      fields = getOption('fields', c('symbol', 'unit', 'transform', 'label')),
      digits = 3,
      ...
){
   stopifnot(is.logical(nested))
   nested <- rep(nested, length.out = 2)
   
   ext <- read_ext(
     x, 
     directory = directory, 
     extension = extension[[1]], 
     quiet = quiet, 
     clean = clean,
     nested = nested[[1]],
     clue = clue
   )
   ext = ext %>% as.list
   class(ext) = "extList"
   
   msel_list = lapply(ext,function(x) {x$ITERATION %>% unlist %>% as.numeric} <= {-1000000000})
   msel_list = lapply(msel_list, function(x) any(x==TRUE))
   msel = msel_list %>% unlist 
   ## if at least 1 EXT is wrong then make EXT look like something parseable
   ## done by taking the last iteration and use that as estimate, the rest is NA
   if(any(msel==FALSE)){
     ext = lapply(1:length(ext), function(a,ext,msel_list){
       if(!msel_list[[a]]){ ## if the ext is 'wrong'
       nams = names(ext[[a]])
       y = ext[[a]]
       y %<>% slice(c(n(),n()))
       y = apply(y,2,function(z) unlist(z) %>% as.numeric()) %>% data.frame()
       names(y) = nams
       y %<>% mutate(ITERATION = c(ITERATION[1],-1000000000))
       y %<>% .[c(1,rep(2,7)),]
       y$ITERATION[-1] = y$ITERATION[-1]-c(0:6)
       y[-c(1:2),-c(1,ncol(y))] = NA 
       row.names(y) = NULL
       y
       } else ext[[a]] # return the already good one
     }, ext = ext, msel_list = msel_list)
     class(ext) = "extList"
   }
   
   lst <- read_lst(
     x, 
     directory = directory, 
     extension = extension[[2]], 
     quiet = quiet, 
     clean = clean,
     nested = nested[[2]],
     clue = clue
   )
   lst = lst %>% strsplit(., split="\n") %>% .[[1]]
   class(lst) = "lst"
   
   ## txt2 is the first bit of the lst file - before any estimation output. Like a preamble.
   txt2 = lst[1:grep("#TBLN", lst)[1]]
   whats = find_diag_template(txt2) 

   shrink <- nm_shrinkage(
     x, 
     directory = directory, 
     extension = extension, 
     quiet = quiet, 
     clean = clean,
     nested = nested,
     clue = clue,
     keep_stat = keep_stat,
     keep_type = keep_type
   )
   
   # if(all(!msel)) {shrink = shrink} else {
   #   shrink = shrink %>% .[msel] # remove unparsable ones
   # }
   # 
   pardef <- x %>% nonmemica::definitions(project=directory, fields = fields) 
   
   #pardef 'item' is canonical.  Limit to parameters.
   pardef %<>% filter(grepl("(theta_|omega_|sigma_)", item))
   pardef %<>% mutate(
      parameter = 
         item %>% 
         as_nms_canonical %>% 
         nms_nonmem %>% 
         as.character
   ) 
   # pardef %<>% filter(grepl("(THETA|OMEGA|SIGMA)",parameter))
   if(nrow(pardef)>0) pardef %<>% mutate_cond(is.na(label) & !is.na(symbol), label=symbol)
   if(nrow(pardef)>0) pardef %<>% mutate_cond(!is.na(label) & is.na(symbol), symbol=parameter)#label
   if(nrow(pardef)>0) pardef %<>% mutate_cond(is.na(label) & is.na(symbol), label=parameter, symbol=parameter)#item

   par_table = ext %>% summary

   par_table %<>% lapply(., function(y) y %>%
                           mutate(parameter = rownames(y)) %>%
                           select(parameter, everything())
   )
   if(nrow(pardef)==0) pardef = par_table[[1]] %>% 
     select(parameter) %>% mutate(symbol=NA,unit=NA,transform=NA,label=NA,item=NA) 

   nms = names(ext)
   if(!is.list(shrink)) {
     if(!quiet) print("No shrinkage information available.")
     par_table = lapply(par_table, function(x) x %>% left_join(whats, by = 'parameter') %>% mutate(shrinksd=NULL))
   } else {
     par_table = lapply(1:length(par_table), function(x, par_table, shrink, whats) 
     {
       par_table[[x]] %<>% left_join(shrink[[x]], by = 'parameter')
       #par_table[[x]] %>% left_join(whats, by = 'parameter')
       par_table[[x]] %<>% mutate(pclass=substring(parameter,1,5))
       par_table[[x]] %<>% mutate_cond(is.na(on),on=0, shrinksd=0, type="")
     }, par_table=par_table, shrink=shrink, whats = whats)
   }
   
   my_fun <- function(x, pardef, digits) {
     if (length(x$se_est) == 0 | all(is.na(x$se_est))) {
        x %<>% mutate(RSE = NA) 
     } else {
      # x %<>% mutate(RSE = signif(as.numeric(se_est) / abs(as.numeric(estimate)) * 100, digits = digits)) TTB 6/26/2025
        x %<>% mutate(RSE = as.numeric(se_est) / abs(as.numeric(estimate)) * 100)
     }
     x %<>% select(parameter, pclass, on, everything())
   # x %<>% mutate(across(-all_of(c('parameter','on', 'type', 'pclass', 'shrinksd')), as.numeric)) TTB 6/26/2025
     x %<>% mutate(across(any_of(c(
        'estimate','se_est',
        # 'eigen_cor', # TTB 2025-08-25 dropped at version 4.5.1-13.  See note in read_ext.r.
        'cond', 'om_sg', 'se_om_sg', 'fix','term','part_deriv_LL')), as.numeric))
     x %<>% mutate(CI95 = "-")
     if (length(x$se_est) == 0 | all(is.na(x$se_est)))
       x %<>% mutate(CI95 = NA) else {
       x %<>% mutate_cond(fix == 0
                          , CI95 = paste0(
                            signif(estimate - se_est * 1.96, digits = digits),
                            ci.sep,
                            signif(estimate + se_est * 1.96, digits = digits)
                          ))
       }
     x %<>% left_join(pardef, by = 'parameter')

     # we know parameter is present, but item and symbol may not be.
     x %<>% mutate(ITEM = parameter %>% as_nms_nonmem %>% nms_canonical %>% as.character)
     x %<>% mutate_cond(is.na(symbol), symbol = parameter)
     x %<>% mutate_cond(is.na(label), label = parameter)
     x %<>% mutate_cond(is.na(item), item = ITEM)
     x %<>% select(-ITEM)
     if (length(x$se_est) == 0 | all(is.na(x$se_est)))
       x %<>% mutate(se_est = NA)
     if(all(is.na(x$RSE))) x %<>% mutate(RSE = 0) else {x %<>% mutate_cond(fix==1 & is.na(RSE), RSE=0)}
     x$parameter %<>% as_nms_nonmem # parameter is THETA(1), OMEGA(2,2), etc.
     x
   }
   par_table = lapply(par_table, my_fun, pardef=pardef, digits = digits)
   names(par_table) = nms
   par_table[] <- lapply(par_table, function(t)structure(t, class = union('nmpartab_', class(t))))
   class(par_table) <- union('nmpartab', class(par_table))
   return(par_table)
}

#' Get Abbreviated Parameter Table
#' 
#' Gets abbreviated parameter table.
#' Generic; see method \code{\link{nm_params_table_short.nmpartab}}.
#' 
#' @export
#' @keywords internal
#' @family ext
#' @param x object of dispatch
#' @param ... passed
nm_params_table_short <- function(x, ...)UseMethod('nm_params_table_short')

#' Get Abbreviated Parameter Table for 'nmpartab'
#' 
#' Shortens the output of \code{\link{nm_params_table}} (based on EXT file) to essential information.
#' See also \code{\link{get_est_table}} which uses \pkg{pmxTools}
#' to construct a parameter table from the XML.
#' See also \code{\link[nonmemica]{partab}} from \pkg{nonmemica} which does similar.
#' 
#' @export
#' @family ext
#' @return data.frame of class 'nmpartab'
#' @param x list: the output of nm_params_table which is a list of data frames ('nmpartab')
#' @param selection character: allowed columns
#' @param ... ignored
#' @importFrom magrittr %>%
#' @examples
#' library(magrittr)
#' library(dplyr)
#' options(nmDir = getOption("qpExampleDir"))
#' "run103" %>% nm_params_table
#' "run103" %>% nm_params_table_short
#' "run103" %>% nm_params_table %>% nm_params_table_short
#' "run103" %>% nm_params_table %>% nm_params_table_short %>% lol
#' "run103" %>% nm_params_table() %>% lol %>% filter(pclass=="THETA") %>% format()

nm_params_table_short.nmpartab = function(
      x,
      selection = c(
         'parameter','estimate','RSE','CI95','fix','shrinksd',
         'symbol','unit','transform','label','se_est'
      ),
      ...
)
{
   sel = c('parameter',selection, 'estimate','RSE','CI95','fix', 'shrinksd',
                 'symbol','unit','transform','label','se_est') %>% 
     unique 
   y <- lapply(x, function(x) x%>% select(any_of(sel)))
   class(y) <- union('nmpartab', class(y))
   return(y)
}


#' Get Abbreviated Parameter Table for 'ext'
#' 
#' Shortens the output of \code{\link{nm_params_table}} (based on EXT file) to essential information.
#' See also \code{\link{get_est_table}} which uses \pkg{pmxTools}
#' to construct a parameter table from the XML.
#' See also \code{\link[nonmemica]{partab}} from \pkg{nonmemica} which does similar.
#' 
#' @export
#' @family ext
#' @return data.frame of class 'nmpartab'
#' @param x the output of \code{\link{read_ext}}
#' @param selection character: allowed columns
#' @param ... passed to \code{\link{nm_params_table}} and \code{\link{nm_params_table_short.nmpartab}}
#' @importFrom magrittr %>%
#' @examples
#' library(magrittr)
#' library(dplyr)
#' options(nmDir = getOption("qpExampleDir"))
#' "run103" %>% nm_params_table
#' "run103" %>% nm_params_table_short
#' "run103" %>% nm_params_table %>% nm_params_table_short
#' "run103" %>% nm_params_table %>% lol %>% names
#' "run103" %>% nm_params_table_short %>% lol %>% names
#' "run103" %>% nm_params_table %>% nm_params_table_short %>% lol %>% names

nm_params_table_short.ext = function(
      x,
      selection = c(
        'parameter','estimate','RSE','CI95','fix','shrinksd',
        'symbol','unit','transform','label'
      ),
      ...
)
{
  sel = c('parameter','estimate','RSE','CI95','fix','shrinksd',
          'symbol','unit','transform','label',selection) %>% 
    unique
  y <- nm_params_table(x, ...)
  z <- nm_params_table_short(y, selection = sel, ...)
  z
}


#' Get Abbreviated Parameter Table for Character
#' 
#' Shortens the output of \code{\link{nm_params_table}} (based on EXT file) to essential information.
#' See also \code{\link{get_est_table}} which uses \pkg{pmxTools}
#' to construct a parameter table from the XML.
#' See also \code{\link[nonmemica]{partab}} from \pkg{nonmemica} which does similar.
#' 
#' @export
#' @family ext
#' @return data.frame of class 'nmpartab'
#' @param x character, e.g. a run name like 'run01'
#' @param selection character: allowed columns
#' @param ... passed to \code{\link{nm_params_table.character}} and \code{\link{nm_params_table_short.ext}}
#' @importFrom magrittr %>%
#' @examples
#' library(magrittr)
#' library(dplyr)
#' options(nmDir = getOption("qpExampleDir"))
#' "run103" %>% nm_params_table
#' "run103" %>% nm_params_table_short
#' "run103" %>% nm_params_table %>% nm_params_table_short

nm_params_table_short.character = function(
      x,
      selection = c(
        'parameter','estimate','RSE','CI95','fix','shrinksd',
        'symbol','unit','transform','label'
      ),
      ...
)
{
  sel = c('parameter','estimate','RSE','CI95','fix','shrinksd',
                'symbol','unit','transform','label',selection) %>% 
    unique
  y <- nm_params_table(x, ...)
  z <- nm_params_table_short(y, selection = sel, ...)
  z
}

#' Format Parameter Table
#' 
#' Formats list of parameter tables for inclusion in reports, typically in \LaTeX or Rmarkdown 
#' or bookdown format. 
#' It takes output of class 'nmpartab' which \code{\link{nm_params_table}} and 
#' \code{\link{nm_params_table_short}} provide. 
#' Alternative methods for parameter tables: see also \code{\link{get_est_table}} 
#' which uses \pkg{pmxTools} to construct a parameter table from the XML. 
#' See also \code{\link[nonmemica]{partab}} from \pkg{nonmemica} which does similar.
#' Formatting functions \code{\link{formatted_signif}} that calls 
#' \code{\link{align_around_decimal_point}}.
#' 
#' @export
#' @family ext
#' @return data.frame of class 'nmpartab'
#' @param x character, e.g. a run name like 'run01'
#' @param align.dot logical: align dots around decimal point, defaults to TRUE, but only effective when latex=TRUE
#' @param latex logical: creates escaped \LaTeX output and effectuates align.dot argument. Defaults to FALSE.
#' @param digits numeric: number of significant digits assed to (formatted_)signif. Defaults to 3.
#' @param fixed.text character: string used as suffix after a fixed parameter estimate. 
#' @param paste_label_unit logical: glue label and bracketed unit together. Defaults to FALSE. 
#' @param pretty provide the key names after formatting only (TRUE, default) or keep the untransformed 
#' @param ... arguments passed on to \code{\link{format.nmpartab_}}
#' @importFrom magrittr %>% %<>%
#' @importFrom nonmemica nms_pmx
#' @examples
#' library(magrittr)
#' library(dplyr)
#' library(knitr)
#' library(yamlet)
#' library(nonmemica)
#' options(nmDir = getOption("qpExampleDir"))
#' "run103" %>% nm_params_table %>% format
#' "run103" %>% nm_params_table %>% lol %>% format
#' "run103" %>% nm_params_table %>% format %>% lol # same
#' "run103" %>% nm_params_table %>% format(paste_label_unit= 'label')
#' "run103" %>% nm_params_table %>% format(paste_label_unit= 'label') %>% lol
#' "run103" %>% nm_params_table %>% format(paste_label_unit= 'label', pretty = FALSE) %>% lol
#' lapply(
#'   setNames(
#'     nm=paste0("run",100:103)), 
#'     function(x){
#'       x %>% 
#'       nm_params_table %>% 
#'       format(paste_label_unit= 'label') %>% 
#'       lol
#'     } 
#'    )
#'
#' tab <- "run103" %>% nm_params_table %>% lol 
#' tab %<>% format(paste_label_unit='label')
#' 
#' # 'Name' is class 'nms_nonmem'
#' # and has a guide with spork assignments
#' tab %>% decorations(Name)
#' 
#' # yamlet::scripted() makes it a factor 
#' # and renders its levels as html or latex
#' # In a pdf context, this creates ready-to-use 
#' # tex markup that you will not want to escape.
#' # Make sure your other table cell content is
#' # already escaped as necessary.

#' was <- knitr::opts_knit$set(out.format = 'latex') %$% out.format

#' tab %<>% scripted
#' tab %$% Name %>% levels
#' 
#' 
#' tab %>% kable(
#'   format = 'latex', 
#'   escape = FALSE, 
#'   booktabs = TRUE
#' )
#' 
#' # cleanup
#' knitr::opts_knit$set(out.format = was)
#' 
#' # Alternatively, use shorter latex syntax.
#' "run103" %>% 
#'   nm_params_table %>% 
#'   lol %>%
#'   format %>%
#'   to_latex
#'   
#' # If you haven't formatted the table, to_latex() modifies
#' # 'parameter' instead of 'Name'
#' "run103" %>% 
#'   nm_params_table %>% 
#'   lol %>%
#'   to_latex
#' 
#' 
#'   
#' # You can also work with vectors
#' c('THETA1', 'OMEGA(2,3)') %>% as_nms_nonmem %>% to_latex
#' qptools:::to_latex.nms_nonmem(c('THETA1', 'OMEGA(2,3)'))

format.nmpartab = function(
    x,
    align.dot = TRUE,
    latex=FALSE,
    digits=3,
    fixed.text = "(fixed)",
    paste_label_unit = 'none',
    pretty = TRUE,
    ...
    )
{
  nms=names(x)
 
  y = lapply(
     x,
     format,
     align.dot = align.dot,
     latex = latex,
     digits = digits,
     fixed.text = fixed.text,
     paste_label_unit = paste_label_unit,
     pretty = pretty,
     ...
  )
  names(y)=nms
  y
}

#' Format Parameter Table Element
#' 
#' Formats parameter tables for inclusion in reports, typically in \LaTeX or Rmarkdown 
#' or bookdown format. 
#' It takes one element of class 'nmpartab' which \code{\link{nm_params_table}} and 
#' \code{\link{nm_params_table_short}} provide. 
#' Alternative methods for parameter tables: see also \code{\link{get_est_table}} 
#' which uses \pkg{pmxTools} to construct a parameter table from the XML. 
#' See also \code{\link[nonmemica]{partab}} from \pkg{nonmemica} which does similar.
#' Formatting functions \code{\link{formatted_signif}} that calls 
#' \code{\link{align_around_decimal_point}}.
#' 
#' @export
#' @keywords internal
#' @family ext
#' @return data.frame; column 'Name' has class 'nms_nonmem'
#' @param x data.frame
#' @param align.dot logical: align dots around decimal point, defaults to TRUE, but only effective when latex=TRUE
#' @param latex logical: creates escaped \LaTeX output and effectuates align.dot argument. Defaults to FALSE.
#' @param digits numeric: number of significant digits passed to (formatted_)signif. Defaults to 3.
#' @param fixed.text character: string used as suffix after a fixed parameter estimate. 
#' @param paste_label_unit character: Must be either "none" (default) keeping label and unit separate columns or "label" which glue label and bracketed unit together. Defaults to "none"
#' @param ci.sep character: character to separate confidence intervals by; only updates where transform is LOG or LOGIT; coordinate with usage in \code{\link{nm_params_table}}
#' @param backtransform whether to backtransform estimate, CI95, and RSE (LOG, LOGIT)
#' @param pretty provide the key names after formatting only (TRUE, default) or keep the untransformed columns as well (FALSE)
#' @param ... currently unused arguments
#' @importFrom magrittr %>% %<>%
#' @importFrom dplyr across case_when

format.nmpartab_ = function(
    x,
    align.dot = TRUE,
    latex=FALSE,
    digits=3,
    fixed.text = "(fixed)",
    paste_label_unit = "none",
    ci.sep = " - ",
    backtransform = TRUE,
    pretty = TRUE,
    ...
)
{
  stopifnot(length(paste_label_unit) == 1,
            is.character(paste_label_unit), 
            !is.na(paste_label_unit), 
            paste_label_unit %in% c('none','label','symbol')
  )
  myFormat = function(x, digits, ...){ # myFormat takes a numeric argument and returns character
    if(!any(isNumeric(x))) return(x)
    x[isNumeric(x)] = formatted_signif(digits = digits, as.numeric(x[isNumeric(x)]), ...)
    return(x)
  }
  
  
  y = x %<>% mutate(fix = as.numeric(fix))
  y %<>% mutate(across(
    .cols = c(estimate, se_est, RSE, CI95),
    .names = '{.col}_untransf'
  ))
  y %<>% mutate(equation = "-", trnsfd = 0)
  y %<>% mutate_cond(is.na(transform) |
                       transform == "NA", transform = "-")
  y %<>% mutate_cond(is.na(unit) | unit == "NA", unit = "-")
  
  if(backtransform){
     # anywhere myFormat is called, numeric will be converted to character
     # therefore ALL cases must be considered, otherwise the chance is lost to signif other elements
    
    # LOG
    y %<>% mutate_cond(
       transform=="LOG", 
       estimate=exp(estimate_untransf) ,
       RSE = (sqrt(exp(se_est_untransf^2)-1) * 100) %>% myFormat(digits = digits),
       CI95 = 
          paste0(
             exp(estimate_untransf-se_est_untransf*1.96) %>% myFormat(digits = digits),
             ci.sep,
            exp(estimate_untransf+se_est_untransf*1.96)%>% myFormat(digits = digits)
         ),
         equation="est=exp(est); CI95=exp(est+/-se*1.96); RSE=sqrt(exp(se^2)-1)*100",
         trnsfd=1
    )
     
    # LOGIT
    y %<>% mutate_cond(
       transform=="LOGIT", 
       estimate=logit_inv(estimate_untransf),
       CI95 = paste0(
          logit_inv(estimate_untransf-se_est_untransf)%>% myFormat(digits = digits),
          ci.sep,
          logit_inv(estimate_untransf+se_est_untransf)%>% myFormat(digits = digits)
      ),
      RSE = "-",
      equation="est=logit_inv(est); CI95=logit_inv(est+/-se*1.96):RSE=-",
      trnsfd=1
    )
    
    y %<>% mutate_cond(
     # transform %in% c("LOG", "LOGIT"), TTB 6/26/2025 Likely mistake:
     # since these cases are handled above, and the complimentary case is not.
       ! transform %in% c("LOG", "LOGIT"), 
       estimate = as.numeric(estimate) %>% myFormat(digits = digits), 
       # default CI95 has already been assigned
       # signif RSE
       RSE = RSE %>% myFormat(digits = digits),
       se_est = "---"
    )
  }

  y %<>% mutate(shrinksd = ifelse(is.na(shrinksd), "-", shrinksd %>% myFormat(digits = digits))) 
  y %<>% rename(shrink = shrinksd)
  
  y %<>% mutate_cond(fix==0&transform=="-", 
                     estimate = estimate_untransf %>% myFormat(digits = digits))
  y %<>% mutate_cond(fix==1&transform!="-", 
                     estimate = estimate %>% paste(.,fixed.text),
                     RSE = "-", se_est= '-')
  y %<>% mutate_cond(fix==1&transform=="-", 
                     estimate = estimate_untransf %>% myFormat(digits = digits) %>% paste(.,fixed.text),
                     RSE = "-", se_est= '-')

  if(paste_label_unit != "none") {
    y %<>% mutate(
      label = case_when(
        is.na(unit) ~ label,
        paste_label_unit == 'none' ~ label,
        paste_label_unit == 'label' ~ paste0(label, ' (', unit, ')'),
        paste_label_unit == 'symbol' ~ paste0(symbol, ' (', unit, ')')
      ))
    #y %<>% mutate(parameter=gsub(parameter, " (-)", ""))
  }
  #y %<>% mutate_cond(!is.na(unit), label = paste(eval(substitute(paste_label_unit)), paste0("(",unit,")")))
  y %<>% mutate_cond(is.na(unit) | unit=="NA", unit="-")
  y %<>% mutate_cond(is.na(RSE) | RSE=="NA", RSE="-")
  y %<>% mutate_cond(is.na(CI95) | CI95=="NA - NA", CI95="-")
  
  keepers = c(
    'symbol','label','parameter','estimate','est_se', 'RSE','CI95','shrink',
    'unit','transform','trnsfd','fix'
  )
  
  if(pretty==FALSE) keepers = y %>% names
  y %<>% select(any_of(keepers)) %>%
    rename(Estimate = estimate, 
               "95\\% CI" =  CI95,
               Shrinkage = shrink, 
               Name = parameter,
               Parameter = symbol,
               Description = label
    )
  #y$Name %<>% as_nms_nonmem
  stopifnot(inherits(y$Name, 'nms_nonmem'))
  guide <- as.list(y$Name)
  names(guide) <- as_spork(y$Name)
  attr(y$Name, 'guide') <- guide
  
  # this is a special version of nmpartab_
  # signal with distinct class
  class(y) <- union('formatted', class(y))
  y
}

#' Convert nms_nonmem to spork
#' 
#' Converts nms_nonmem to spork, i.e. an abstract specification of 
#' thetas, omegas, and sigmas using NONMEM conventions.

#' @export
#' @return spork
#' @importFrom spork as_spork
#' @param x nms_canonical; see \code{\link[nonmemica]{as_nms_canonical}}
#' @param ... passed arguments

as_spork.nms_nonmem <- function(x, ...) {
   x %<>% sub('THETA', 'theta_', .)
   x %<>% sub('OMEGA', 'omega^2._', .)
   x %<>% sub('SIGMA', 'sigma^2._', .)
   x %<>% gsub('[()]', '', .)
   x %<>% as.character %>% as_spork
   x
}

# @export
# spork::as_latex
