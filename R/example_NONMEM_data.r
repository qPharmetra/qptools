globalVariables(c('EVID', 'CMT', 'AMT', 'DOSE', 'ID', 'TIME', 'DV'))

# ROXYGEN Documentation
#' Create an example PKPD Dataset
#' @description Create a data set with concentration predictions and (effect compartment) predictions for a 1 compartment open model with first order absorption
#' @param DOSE values for dose level
#' @param TIME numeric vector describing time of observation
#' @param ID vector of ID values
#' @return A data.frame with concentration and effect predictions
#' @export
#' @importFrom dplyr bind_rows mutate arrange
#' @importFrom tidyr as_tibble
#' @family example
#' @examples
#' pkpd_df = example_NONMEM_data()
#' head(pkpd_df)

example_NONMEM_data = function (ID = 3,
                                   TIME = seq(0, 24, 2),
                                   DOSE = c(1, 2.5, 10)
)
{
  nmobs = expand.grid(ID = seq(ID * length(DOSE)), TIME = TIME) %>%
    mutate(AMT = 0, EVID = 0, DV = 0) %>%
    arrange(ID, TIME)
  nmobs$DOSE = rep(DOSE, ea = ID * length(TIME))
  nmdose = subset(nmobs, TIME == TIME[1], select = c(ID, DOSE)) %>%
    mutate(
      AMT = DOSE,
      TIME = 0,
      EVID = 1,
      DV = 0
    )
  nmdata = bind_rows(nmobs, nmdose) %>% arrange(ID, DOSE, TIME,-EVID)
  nmdata %<>% as_tibble
  return(nmdata)
}

