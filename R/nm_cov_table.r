globalVariables(c(
  'covariates', 'parameters','myID', 'carryAlong', 'covValue', 'parValue', 'covariate'
))

# ROXYGEN Documentation
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
#' print("hello world")
#'

nm_cov_table = function(x
                        , ID = "ID"
                        , parameters = c("CL", "V", "KA", "KTR")
                        , covariates = c("DOSE","WT", "HT", "AGE", "BMI", "SEX", "RACE")
                        , carryAlong = "SUBJID"
                        , wide2tall = "none"
                        , n_cat = 10 ## how many unique levels define a categorical covariate
)
{
  x$myID = parse(text=paste0("paste(", paste(ID,collapse=","),")")) %>% eval(x)
  carryAlong = c(carryAlong, ID)
  x = x %>%
    distinct(myID, .keep_all = T) %>%
    select(tidyselect::one_of(ID)
           , one_of(parameters)
           , contains("ET") & matches("[0-9]")
           , one_of(covariates)
           , one_of(carryAlong)
    )
  parameters = names(x)[is.element(names(x),parameters)]
  covariates = names(x)[is.element(names(x),covariates)]
  etas       = names(x)[grepl("[0-9]",names(x)) & grepl("ET",names(x))]
  if(tolower(wide2tall) %in% c("parameter","parameters")){
    x = x %>%
      pivot_longer(cols=parameters, names_to = "parameter", values_to = "parValue") %>%
      pivot_longer(cols=covariates, names_to = "covariate", values_to = "covValue"
                   , values_transform = list(covValue = as.character)
                   , values_ptypes = list(covValue=character()))
  }
  if(tolower(wide2tall) %in% c("eta","etas")){
    x = x %>%
      pivot_longer(cols=etas, names_to = "eta", values_to = "etaValue") %>%
      pivot_longer(cols=covariates, names_to = "covariate", values_to = "covValue"
                   , values_transform = list(covValue = as.character)
                   , values_ptypes = list(covValue=character()))
  }
  if(wide2tall != "none")
    x = x %>%
    group_by(covariate) %>%
    mutate(cov_class = ifelse(length(unique(covValue)) < n_cat, "categorical", "continuous")) %>%
    ungroup()
  return(x)
}

#nm_unzip("example1", path = file.path(getOption("qpExampleDir"),"example1"))
#out1 = get_xpose_tables("example1", path = getOption("qpExampleDir"))
#nm_cov_table(out1)
