% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/formatted_signif.r
\name{formatted_signif}
\alias{formatted_signif}
\title{Format Real with Enforced Significant Digits}
\usage{
formatted_signif(x, digits = 3, latex = FALSE, align.dot = FALSE)
}
\arguments{
\item{x}{a vector of values to be processed into significant digits format}

\item{digits}{single value specifying the number of significant digits}

\item{latex}{whether to convert scientific notation to latex equivalent (e -> *10^)}

\item{align.dot}{whether to decimal-align the result}
}
\value{
A formatted character vector containing \code{x} with significant \code{digits} format
}
\description{
Formats real number, enforcing printed number of significant digits.
In contrast, \code{as.character(signif())} drops trailing zeros.
}
\examples{
library(xtable)
formatted_signif(c(5,4.99, 4.99999,5.0000001,5001),4)

numvec = c(5,4.99, 4.99999,5.0000001,5001, 0.00005,101,39.9)
print(
   xtable(
      data.frame(
          original = numvec
         ,latex.TRUE = formatted_signif(numvec,3, TRUE,FALSE)
         ,align.TRUE = formatted_signif(numvec,3, FALSE,TRUE)
         ,all.TRUE = formatted_signif(numvec,3, TRUE,TRUE)
      )
   )
   , booktabs = TRUE
   , sanitize.text.function = identity
)
# now take this to a LaTeX compiler!
}
\seealso{
Other format: 
\code{\link{orderedNumeric}()},
\code{\link{repeat_nth}()},
\code{\link{swap}()}
}
\concept{format}
