% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nm_runrecord_graph.r
\name{nm_runrecord_graph}
\alias{nm_runrecord_graph}
\title{Graph a Runrecord}
\usage{
nm_runrecord_graph(
  x,
  directory = getOption("nmDir"),
  keep.cols = c("ID", "DV", "CWRES", "PRED", "IPRED", "TIME", "EVID"),
  alias = list(DV = "CONC", TIME = "TIME"),
  index = NULL,
  extension = c(getOption("nmFileExt", "ext"), getOption("nmFileLst", "lst")),
  nested = c(TRUE, FALSE),
  dot.size = 1,
  text.size = 1,
  yLimits = NULL,
  ...
)
}
\arguments{
\item{x}{character vector of run names, e.g. c('run1','run2')}

\item{directory}{path to working directory}

\item{keep.cols}{character: columns to keep}

\item{alias}{named vector of aliases to substitute}

\item{index}{integer indicating choice of estimation method (defaults to last)}

\item{extension}{length-character indicating extensions for ext and lst files}

\item{nested}{length-two logical indicating whether ext and lst files are nested in run directory}

\item{dot.size}{dot size}

\item{text.size}{text size}

\item{yLimits}{numeric vector of length 2 given the limits of the y axis}

\item{...}{passed to other functions}
}
\value{
ggplot
}
\description{
Graphs a runrecord.
See \code{\link{nm_runrecord}}.
}
\examples{

nm_runrecord_graph(
  c('run101', 'run102', 'run103', 'run104', 'run105'),
  directory = getOption('qpExampleDir')
)
}
\seealso{
Other runrecord: 
\code{\link{get_xpose_tables}()},
\code{\link{nm_runrecord}()}
}
\concept{runrecord}
