# ROXYGEN Documentation
#' Group-wise sampling from prespecified distribution
#' @description Populates 1 sample from prespecified distribution for each group (id or subject, or trial, or other)
#' @param id vector with group information
#' @param samples distribution to sample from
#' @param replace if TRUE (default) sampling will be done with replacement
#' @return samples of the prespecified distribution, one for each level of \code{group}
#' @export
#' @family basic
#' @examples
#' my.ids = rep(1:5,each = 3)
#' my.ids
#'
#' set.seed(123456)
#' sample_by_id(my.ids, samples = rgamma(1000,1))
#'
#' my.ids = rep(1:5,times = 3)
#' my.ids
#' sample_by_id(my.ids, samples = rgamma(1000,1))
#'
#' #one unique value per id
#' sample_by_id(unique(my.ids), samples = rgamma(1000,1))
#' tapply(sample_by_id(my.ids, samples = rgamma(1000,1)),my.ids, unique)


sample_by_id <- function(id, samples, replace = TRUE)
{
  # samples can be the output from any function
  len = length(unique(id))
  sample(samples, size = len, replace = replace)[tapply(id, id)]
}


