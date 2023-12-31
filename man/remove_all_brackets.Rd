% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/remove.R
\name{remove_all_brackets}
\alias{remove_all_brackets}
\title{Removes all brackets}
\usage{
remove_all_brackets(string)
}
\arguments{
\item{string}{A character string}
}
\value{
A string without brackets
}
\description{
Takes a string as input and removes everything between square and round
brackets. The function wraps around \code{\link{remove_square_brackets}} and
\code{\link{remove_round_brackets}}. To avoid problems, we first remove
square brackets.
}
