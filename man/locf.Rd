% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/locf.r
\name{locf}
\alias{locf}
\title{Last Observation Carried Forward (LOCF)}
\usage{
locf(x, na = NA)
}
\arguments{
\item{x}{Placehoder for parameter description}

\item{na}{code for missing values to be LOCF-ed}
}
\value{
Placeholder for return description
}
\description{
Derive Last Observation Carried Forward (LOCF). Preserves factors as well.
}
\examples{
locf(c(NA,NA,1,NA,NA,2,NA,NA,NA,NA,3))
# Note that initial missing values take next value (1),
# so next value carried backward at beginning
# Example with "."
locf(c(".",".",1,".",".",2,".",".",".",".",3), na = ".")
# Note, if you have text in the vector, it is all converted to text.
# This is by design so we can use different types.
# Examples with factors
fac = as.factor(c(".",".","A",".",".","B",".",".",".",".","C"))
locf(fac,na = ".")
fac = as.factor(c(NA,NA,"A",NA,NA,"B",NA,NA,NA,NA,"C"))
locf(fac,na = NA)
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
\code{\link{logit_inv}()},
\code{\link{logit}()},
\code{\link{lunique}()},
\code{\link{make.symmetric}()},
\code{\link{rgenpois}()},
\code{\link{rnorm_by_id}()},
\code{\link{sample_by_id}()},
\code{\link{sunique}()}
}
\concept{basic}
