% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/swap.r
\name{swap}
\alias{swap}
\title{Replace Existing set of Values with Another set of Values}
\usage{
swap(x, from, to)
}
\arguments{
\item{x}{vector to apply the exchange over}

\item{from}{(Sorted) vector of unique OLD values}

\item{to}{(Sorted) vector of unique NEW values}
}
\value{
swapped vector of x
}
\description{
Replaces existing set of values with another set of values
}
\examples{
my.vect = c(1,2,2,2,4,4,4,3,3,3,3,5)
swap(my.vect, c(1,2,3,4), c(11,22,33,44))
}
\seealso{
Other format: 
\code{\link{formatted_signif}()},
\code{\link{orderedNumeric}()},
\code{\link{repeat_nth}()}
}
\concept{format}
\keyword{internal}
