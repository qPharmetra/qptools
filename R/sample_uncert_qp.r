globalVariables(c('seed', 'est.step', 'nm_object', 'no_steps'))

# ROXYGEN Documentation
#' Draw Samples from the Quasi-Posterior Parameter Estimate Distribution.
#' @description Read point estimates and the variance-covariance matrix of a model run and create a distribution of parameter estimates forming a sample of the quasi-posterior parameter distribution
#' @param run character string in the form of 'run1'
#' @param path root directory of the run folder where .cov file resides
#' @param n sample size of the requested distribution
#' @param est_step estimation number - defaults to the last one
#' @param seed random seed for simulation
#' @param quiet suppresses the messages (defaults to not suppressing)
#' @param clear_zip remove the xml and cov file after unzipping? Defaults to TRUE
#' @return List of covariance matrices
#' @export
#' @family nm
#' @importFrom Hmisc unPaste
#' @importFrom dplyr select distinct group_by mutate
#' @importFrom tidyr pivot_longer
#' @importFrom tidyselect one_of
#' @importFrom pmxTools get_sigma get_omega get_theta
#' @importFrom MASS mvrnorm
#' @importFrom stringr str_count
#' @examples
#'
#' unc1 = sample_uncert_qp(run = "example1", path = getOption("qpExampleDir"))
#' unc1 = sample_uncert_qp(run = "example1", path = getOption("qpExampleDir"), quiet=TRUE, n=100)
#' dim(unc1)

sample_uncert_qp = function(run,
                            path = getOption("nmDir"),
                            n = 10,
                            seed = 1234,
                            est_step = NULL,
                            clear_zip = TRUE,
                            quiet = FALSE)
{
  nm_object = read_nm_qp(
    run = run,
    path = path,
    clear_zip = clear_zip,
    quiet = quiet
  )
  if (is.null(est_step)) {
    no_steps <-
      sum(stringr::str_count(names(nm_object$nonmem$problem), "estimation"))
  } else {
    no_steps <- est_step
  }

  thetas <- get_theta(nm_object, est.step = no_steps)
  omegas <- get_omega(nm_object, est.step = no_steps)
  sigmas <- get_sigma(nm_object, est.step = no_steps)
  omList <- c()
  for (i in 1:nrow(omegas)) {
    for (j in 1:i) {
      omList <- c(omList, omegas[i, j])
    }
  }
  siList <- c()
  for (i in 1:nrow(sigmas)) {
    for (j in 1:i) {
      siList <- c(siList, sigmas[i, j])
    }
  }
  mu <- as.numeric(c(thetas, siList, omList))
  vcov <-
    nm_covmat_extract(
      run = run,
      path = path,
      quiet = quiet,
      clear_zip = clear_zip
    )[[no_steps]]
  if (!quiet) {
    message(n, " samples created from ", run)
  }
  as.data.frame(MASS::mvrnorm(n = n, mu, Sigma = vcov))
}
