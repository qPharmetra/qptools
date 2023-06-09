% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make_symmetric.r
\name{make.symmetric}
\alias{make.symmetric}
\title{Create symmetrical matrix}
\usage{
make.symmetric(values, triangle = "upper")
}
\arguments{
\item{values}{vector of length cumsum(ncol(matrix))}

\item{triangle}{defaulting to 'upper', can also take the value 'lower'}
}
\value{
A matrix of dimension ncol x ncol
}
\description{
Create symmetrical matrix of lower or upper traingle of a matrix
}
\examples{
  make.symmetric(c(0.12,
                   0.02,1.02,
                   0.23,-0.3,0.23))
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
\code{\link{rgenpois}()},
\code{\link{rnorm_by_id}()},
\code{\link{sample_by_id}()},
\code{\link{sunique}()}
}
\concept{basic}
