% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract.R
\name{extract_values}
\alias{extract_values}
\title{Extract the value argument(s)}
\usage{
extract_values(string, simplify = FALSE)
}
\arguments{
\item{string}{A character string}

\item{simplify}{If TRUE return as a vector. Default is FALSE.}
}
\value{
A vector or list with the extracted value arguments
}
\description{
Extracts the value argument(s) of the supplied string. The value argument
is defined as the characters between [] string.
}
