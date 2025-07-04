% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_mod.r
\name{read_mod.character}
\alias{read_mod.character}
\title{Read NONMEM MOD Results for Character}
\usage{
\method{read_mod}{character}(
  x,
  directory = getOption("nmDir", getwd()),
  extension = getOption("nmFileMod", "mod"),
  quiet = TRUE,
  clean = TRUE,
  nested = FALSE,
  clue = "\\\\$PROB",
  ...
)
}
\arguments{
\item{x}{character: a file path, or the name of a run in 'directory', or mod content}

\item{directory}{character: optional location of x}

\item{extension}{character: extension identifying mod files}

\item{quiet}{logical: flag for displaying intermediate output}

\item{clean}{should the unzipped file be removed when done (defaults to TRUE)}

\item{nested}{is the file nested within the run directory?}

\item{clue}{a text fragment expected to occur in cov files}

\item{...}{passed arguments}
}
\value{
length-one character of class 'mod'
}
\description{
Reads NONMEM MOD results for class character using \code{\link{read_gen.character}}.
}
\examples{
library(magrittr)
options(nmDir = getOption('qpExampleDir'))
'example1' \%>\% read_mod(ext = 'ctl')
}
\seealso{
Other mod: 
\code{\link{read_mod}()},
\code{\link{read_mod.mod}()}
}
\concept{mod}
