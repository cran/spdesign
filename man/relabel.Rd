% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rsc.R
\name{relabel}
\alias{relabel}
\title{Relabeling of attribute levels}
\usage{
relabel(x)
}
\arguments{
\item{x}{A vector of attribute levels}
}
\description{
Relabels the attribute levels to create a new design candidate. For example,
if the column contains the levels (1, 2, 1, 3, 2, 3) and 1 and 3 are
relabeled, then the column becomes (3, 2, 3, 1, 2, 1), i.e. 1 becomes 3 and
3 becomes 1.
}
\details{
Will randomly sample 2 attribute levels that will be relabeled and the
relabeling is done independently for each column, which implies that
the same attribute will be relabeled differently depending on which
alternative it belongs to.
}
\references{
Hensher, D. A., Rose, J. M. & Greene, W., 2005, Applied Choice Analysis,
2nd ed., Cambridge University Press
}
