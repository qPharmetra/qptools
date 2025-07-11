% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_cov.r
\name{get_covmat.character}
\alias{get_covmat.character}
\title{Get Covariance Matrix for Character}
\usage{
\method{get_covmat}{character}(
  x,
  directory = getOption("nmDir", getwd()),
  extension = getOption("nmFileCov", "cov"),
  quiet = TRUE,
  clean = TRUE,
  nested = TRUE,
  clue = "TABLE NO.",
  ...
)
}
\arguments{
\item{x}{character: a file path, or the name of a run in 'directory', or cov content}

\item{directory}{character: optional location of x}

\item{extension}{character: extension identifying cov files}

\item{quiet}{logical: flag for displaying intermediate output}

\item{clean}{should the unzipped file be removed when done (defaults to TRUE)}

\item{nested}{is the file nested within the run directory?}

\item{clue}{a text fragment expected to occur in cov files}

\item{...}{passed arguments}
}
\value{
list of covariance matrices as data frames
}
\description{
Gets covariance matrix for character.
}
\seealso{
Other cov: 
\code{\link{get_covmat}()},
\code{\link{get_covmat.cov}()},
\code{\link{read_cov}()},
\code{\link{read_cov.character}()},
\code{\link{read_cov.cov}()}
}
\concept{cov}
