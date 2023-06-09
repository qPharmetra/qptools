% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sunique.r
\name{sunique}
\alias{sunique}
\title{Unique values sorted}
\usage{
sunique(x)
}
\arguments{
\item{x}{values to be uniqued and sorted}
}
\value{
Sorted unique values in vector \code{x}
}
\description{
Derive the unique values in a vector and sort the result
}
\note{
This function is different from \code{sort(unique(x))} which omits any NAs in the result. \code{sunique}
}
\examples{
sunique(round(100*runif(100)))
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
\code{\link{sample_by_id}()}
}
\concept{basic}
