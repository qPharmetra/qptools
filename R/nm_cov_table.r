globalVariables(c(
  'covariates', 'parameters','myID', 'carryAlong', 'covValue', 'parValue', 'covariate'
))

#' Double Stacking or Wide to Tall Transformation of Parameter and ETA Estimates with Covariates
#' @description Double stack parameter estimates and ETA values with covariates into a single data frame
#' @param x NONMEM output tables as a data.frame from get.xpose.tables, or read_nmtables, or alike
#' @param ID the subject identifier in the NONMEM output
#' @param parameters Model parameter name vector
#' @param covariates covariates to integrate
#' @param carryAlong columns to carry along i the output
#' @param wide2tall either 'parameter' or 'eta'. Plural will be accepted too
#' @param n_cat number of unique values to qualify as a categorical covariate
#' @return data frame with parValue, etaValue, covValue, and cov_class (continuous or categorical)
#' @export
#' @importFrom magrittr %>%
#' @importFrom tidyselect one_of contains matches
#' @importFrom dplyr mutate group_by select distinct ungroup
#' @importFrom tidyr pivot_longer
#' @family nm
#' @examples
#'
#' library(magrittr)
#' library(tidyr)
#' library(dplyr)
#' options(nmDir=getOption('qpExampleDir'))
#' out = 'run103' %>% get_xpose_tables()
#' out %<>% nm_cov_table(parameters=c('CL', 'V', 'KA'),
#'                       covariates=c('WT'),
#'                       carryAlong=NULL
#' ) 
#' 
#' out %>% nm_cov_table(parameters=c('CL', 'V'),
#'                      covariates=c('WT'),
#'                      carryAlong=NULL,
#'                      wide2tall='etas'
#' ) 
#' 
#' out %>% nm_cov_table(parameters=c('CL', 'V', 'KA'),
#'                      covariates=c( 'WT'),
#'                      carryAlong=NULL,
#'                      wide2tall='parameter'
#' ) 
#'
#' library(ggplot2)
#' out = "run100" %>% get_xpose_tables 
#' out %<>% nm_cov_table(
#'   parameters=c("CL","V","KA"), 
#'   covariates = c("WT","SEX","ETN"), 
#'   wide2tall = "parameters"
#' )
#' outcon = out %>% 
#'   filter(cov_class=="continuous") %>% 
#'   mutate(covValue=as.numeric(covValue))
#' outcat = out %>% filter(cov_class=="categorical")
#' outcon %>%
#'   ggplot(aes(x=covValue,y=parValue)) + 
#'   geom_point() + 
#'   stat_smooth() + 
#'   facet_wrap(covariate~parameter, scales="free_y")
#'   
#' outcat %>%
#'   ggplot(aes(y=covValue,x=parValue)) + 
#'   geom_point() + 
#'   geom_boxplot(horizontal=TRUE) + 
#'   facet_grid(covariate~parameter, scales="free_x")
#'   

nm_cov_table = function(x
                        , ID = 'ID'
                        , parameters = character(0)
                        , covariates = character(0)
                        , carryAlong = character(0)
                        , wide2tall = 'none'
                        , n_cat = 10 ## how many unique levels define a categorical covariate
)
{
  if(!tolower(wide2tall) %in% c('eta', 'etas', 'parameter', 'parameters','none')){
    message("argument 'wide2tall' should be either eta(s) or parameter(s) or none"); return()
  }
  x$myID = parse(text=paste0('paste(', paste(ID,collapse=','),')')) %>% eval(x)
  carryAlong = c(carryAlong, ID)
  x = x %>%
    distinct(myID, .keep_all = TRUE) %>%
    select(tidyselect::one_of(ID)
           , one_of(parameters)
           , contains('ET') & matches('[0-9]')
           , one_of(covariates)
           , one_of(carryAlong)
    )
  parameters = names(x)[is.element(names(x),parameters)]
  covariates = names(x)[is.element(names(x),covariates)]
  etas       = names(x)[grepl('[0-9]',names(x)) & grepl('ET',names(x))]
  if(tolower(wide2tall) %in% c('parameter','parameters')){
    x = x %>%
      pivot_longer(cols=parameters, names_to = 'parameter', values_to = 'parValue') %>%
      pivot_longer(cols=covariates, names_to = 'covariate', values_to = 'covValue'
                   , values_transform = list(covValue = as.character)
                   , values_ptypes = list(covValue=character()))
  }
  if(tolower(wide2tall) %in% c('eta','etas')){
    x = x %>%
      pivot_longer(cols=etas, names_to = 'eta', values_to = 'etaValue') %>%
      pivot_longer(cols=covariates, names_to = 'covariate', values_to = 'covValue'
                   , values_transform = list(covValue = as.character)
                   , values_ptypes = list(covValue=character()))
  }
  if(wide2tall != 'none')
    x = x %>%
    group_by(covariate) %>%
    mutate(cov_class = ifelse(length(unique(covValue)) < n_cat, 'categorical', 'continuous')) %>%
    ungroup()
  return(x)
}

