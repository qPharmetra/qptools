
# ROXYGEN Documentation
#' Group-wise sampling from normal distribution
#' @description Populates 1 sample from normal distribution for each group (id or subject, or trial, or other)
#' @param id vector with group information
#' @param mean mode of the normal distribution
#' @param sd standard deviation of the normal distribution
#' @return samples of a normal distribution, one for each level of \code{group}
#' @export
#' @family basic
#' @importFrom stats rnorm
#' @examples
#' df = data.frame(id=rep(1:3,ea=4))
#' sam = rnorm_by_id(df$id, mean = 0, sd = 1)
#' tapply(sam,df$id, unique)

rnorm_by_id <- function(id, mean = 0, sd = 1)
  {
    len = length(unique(id))
    rnorm(n = len, mean = mean, sd = sd)[tapply(id, id)]
  }



