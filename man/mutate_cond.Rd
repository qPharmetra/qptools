% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mutate_cond.r
\name{mutate_cond}
\alias{mutate_cond}
\title{Conditional Mutate (dplyr) rows that match a specified condition}
\usage{
mutate_cond(.data, condition, ..., envir = parent.frame())
}
\arguments{
\item{.data}{dataset to perform opertaion}

\item{condition}{condition to}

\item{...}{any argument to pass on to  mutate}

\item{envir}{environment - this parameter is best left alone, as the default setting allows use as standalone as well as in piping calls}
}
\value{
the dataset with the conditional mutation
}
\description{
Mutate rows that match a specified condition, when using dplyr.
}
\examples{
library(magrittr)
library(dplyr)
nmData = example_NONMEM_data() \%>\%
   mutate(CMT = swap(EVID, 0:1, 2:1)) \%>\%
   mutate_cond(condition = CMT>1, CMT = 2
   )
tibble::as_tibble(nmData)
}
