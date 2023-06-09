% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract_character.r
\name{extract_character}
\alias{extract_character}
\title{Extract character information from a string}
\usage{
extract_character(x, collapse = FALSE)
}
\arguments{
\item{x}{A character or numeric string.}

\item{collapse}{A boolean, should the character vector returned by collapsed (see \code{\link[base]{paste}}).}
}
\value{
A character string or vector if the input has multiple character blocks.
}
\description{
Takes character string and parses the character input from it, if available
}
\examples{
extract_character(x = "df12Lee31df")
extract_character(x = "df1231df", TRUE)
}
\seealso{
Other basic: 
\code{\link{asNumeric}()},
\code{\link{doubleStack}()},
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
\code{\link{sample_by_id}()},
\code{\link{sunique}()}
}
\concept{basic}
