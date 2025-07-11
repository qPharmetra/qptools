% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_nm_qp.r
\name{get_est_table}
\alias{get_est_table}
\title{Create a Table of Model Parameters}
\usage{
get_est_table(x, ...)
}
\arguments{
\item{x}{object of dispatch}

\item{...}{passed arguments}
}
\description{
Creates a Table of Model Parameters.
Generic, with default method \code{\link{get_est_table.default}}
and special method \code{\link{get_est_table.nonmem}}.
}
\seealso{
Other nm: 
\code{\link{definitions.nonmem}()},
\code{\link{extract_varcov}()},
\code{\link{get_est_table.default}()},
\code{\link{get_est_table.nonmem}()},
\code{\link{get_ofv}()},
\code{\link{get_ofv.character}()},
\code{\link{nm_cov_table}()},
\code{\link{nm_unzip}()},
\code{\link{read_nm_qp}()},
\code{\link{read_nm_qp.character}()},
\code{\link{read_nm_qp.nonmem}()},
\code{\link{sample_uncert_qp}()}
}
\concept{nm}
\keyword{internal}
