% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/assertions.R
\name{fits_lvl_occurrences}
\alias{fits_lvl_occurrences}
\title{Test whether a design candidate fits the constraints imposed by the level
occurrences}
\usage{
fits_lvl_occurrences(utility, x, rows)
}
\arguments{
\item{utility}{A named list of utility functions. See the examples and the
vignette for examples of how to define these correctly for different types
of experimental designs.}

\item{x}{An object of class 'utility' or 'spdesign'}

\item{rows}{Number of rows in the design}
}
\value{
A boolean equal to TRUE if attribute level balanced
}
\description{
Test whether a design candidate fits the constraints imposed by the level
occurrences
}
