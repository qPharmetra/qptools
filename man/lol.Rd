% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lol.r
\name{lol}
\alias{lol}
\title{Get the Last Element of a List}
\usage{
lol(x, n = NULL)
}
\arguments{
\item{x}{any list}

\item{n}{numeric: position of the element. Defaults to NULL which ensure that the last element is returned.}
}
\value{
data.frame
}
\description{
Extracts the Last Element of a List. most NONMEM post-processing functions in 
\pkg{qptools} provide a list of data frames. This function returns the last (default)
or nth element of that list.
}
\examples{
library(magrittr)
library(dplyr)
options(nmDir = getOption("qpExampleDir"))
"run103" \%>\% nm_params_table \%>\% format
"run103" \%>\% nm_params_table \%>\% format \%>\% lol
d = list(A=data.frame(A=1:3,B=3:1),B=data.frame(A=3:1,B=1:3),C=data.frame(A=10:12,B=5:7))
d \%>\% lol
d \%>\% lol(n=2)

}
\seealso{
Other ext: 
\code{\link{as.list.ext}()},
\code{\link{as.matrix.ext}()},
\code{\link{find_diag}()},
\code{\link{format.nmpartab}()},
\code{\link{format.nmpartab_}()},
\code{\link{get_ext}()},
\code{\link{get_ext.character}()},
\code{\link{get_ext.ext}()},
\code{\link{get_ext.extList}()},
\code{\link{get_ofv.ext}()},
\code{\link{get_ofv.nonmem}()},
\code{\link{nm_condition_number}()},
\code{\link{nm_condition_number.default}()},
\code{\link{nm_condition_number.ext}()},
\code{\link{nm_params_table}()},
\code{\link{nm_params_table.character}()},
\code{\link{nm_params_table_short}()},
\code{\link{nm_params_table_short.character}()},
\code{\link{nm_params_table_short.ext}()},
\code{\link{nm_params_table_short.nmpartab}()},
\code{\link{read_ext}()},
\code{\link{read_ext.character}()},
\code{\link{read_ext.ext}()},
\code{\link{summary.extList}()}
}
\concept{ext}
