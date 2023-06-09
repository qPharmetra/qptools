% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sample_by_id.r
\name{sample_by_id}
\alias{sample_by_id}
\title{Group-wise sampling from prespecified distribution}
\usage{
sample_by_id(id, samples, replace = TRUE)
}
\arguments{
\item{id}{vector with group information}

\item{samples}{distribution to sample from}

\item{replace}{if TRUE (default) sampling will be done with replacement}
}
\value{
samples of the prespecified distribution, one for each level of \code{group}
}
\description{
Populates 1 sample from prespecified distribution for each group (id or subject, or trial, or other)
}
\examples{
my.ids = rep(1:5,each = 3)
my.ids

set.seed(123456)
sample_by_id(my.ids, samples = rgamma(1000,1))

my.ids = rep(1:5,times = 3)
my.ids
sample_by_id(my.ids, samples = rgamma(1000,1))

#one unique value per id
sample_by_id(unique(my.ids), samples = rgamma(1000,1))
tapply(sample_by_id(my.ids, samples = rgamma(1000,1)),my.ids, unique)
}
\seealso{
Other basic: 
\code{\link{asNumeric}()},
\code{\link{doubleStack}()},
\code{\link{extract_character}()},
\code{\link{extract_number}()},
\code{\link{fxs}()},
\code{\link{geomean_cv}()},
\code{\link{geomean}()},
\code{\link{isMissing}()},
\code{\link{isNumeric}()},
\code{\link{locf}()},
\code{\link{logit_inv}()},
\code{\link{logit}()},
\code{\link{lunique}()},
\code{\link{make.symmetric}()},
\code{\link{rgenpois}()},
\code{\link{rnorm_by_id}()},
\code{\link{sunique}()}
}
\concept{basic}
