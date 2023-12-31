% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/derive.R
\name{derive_vcov}
\alias{derive_vcov}
\title{Derive the variance covariance matrix of the design}
\usage{
derive_vcov(design_env, model)
}
\arguments{
\item{design_env}{An environment containing all the elements
necessary to derive the variance-covariance matrix}

\item{model}{A string indicating the model for which you wish to derive the
variance covariance matrix. Can be either "mnl" or "rpl"}
}
\value{
The variance covariance matrix. If the Fisher information matrix is
singular, then return NULL
}
\description{
The function is a wrapper around \code{\link{derive_vcov_mnl}} and
\code{\link{derive_vcov_rpl}} and calculates the variance-covariance matrix
of the specified model and design given the priors.
}
