#' Conditional Mutate (dplyr) rows that match a specified condition
#' @description Mutate rows that match a specified condition, when using dplyr.
#' @param .data dataset to perform opertaion
#' @param condition condition to
#' @param ... any argument to pass on to  mutate
#' @param envir environment - this parameter is best left alone, as the default setting allows use as standalone as well as in piping calls
#' @return the dataset with the conditional mutation
#' @importFrom dplyr mutate
#' @importFrom magrittr %>%
#' @export
#' @examples
#' library(magrittr)
#' library(dplyr)
#' nmData = example_NONMEM_data() %>%
#'    mutate(CMT = swap(EVID, 0:1, 2:1)) %>%
#'    mutate_cond(condition = CMT>1, CMT = 2
#'    )
#' tibble::as_tibble(nmData)

mutate_cond <- function(.data, condition, ..., envir = parent.frame()) {
   condition <- eval(substitute(condition), .data, envir)
   .data[condition, ] <- .data[condition, ] %>% mutate(...)
   .data
}
