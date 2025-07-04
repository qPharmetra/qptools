% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/find_diag.r
\name{find_diag.character}
\alias{find_diag.character}
\title{Find Diagonal Elements of a NONMEM Parameter Table for Character}
\usage{
\method{find_diag}{character}(
  x,
  directory = getOption("nmDir", getwd()),
  extension = getOption("nmFileExt", "ext"),
  quiet = TRUE,
  clean = TRUE,
  nested = TRUE,
  clue = "ITERATION",
  ...
)
}
\arguments{
\item{x}{character: a file path, or the name of a run in 'directory', or ext content}

\item{directory}{character: optional location of x}

\item{extension}{character: extension identifying ext files}

\item{quiet}{logical: flag for displaying intermediate output}

\item{clean}{should the unzipped file be removed when done (defaults to TRUE)}

\item{nested}{is the file nested within the run directory?}

\item{clue}{a text fragment expected to occur in cov files}

\item{...}{passed arguments}
}
\value{
list of data.frames
}
\description{
Find diagonal elements of a NONMEM parameter table for 'character'.
}
\examples{
library(magrittr)
options(nmDir = getOption("qpExampleDir"))
"example2" \%>\% find_diag

}
\keyword{internal}
