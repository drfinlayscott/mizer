% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/species_params.R
\name{get_f0_default}
\alias{get_f0_default}
\title{Get default value for f0}
\usage{
get_f0_default(params)
}
\arguments{
\item{params}{A MizerParams object}
}
\value{
A vector with the values of f0 for all species
}
\description{
Fills in any missing values for f0 so that if the prey abundance was
described by the power law \eqn{\kappa w^{-\lambda}} then the encounter rate
coming from the given \code{gamma} parameter would lead to the feeding level
\eqn{f_0}. This is thus doing the inverse of \code{\link[=get_gamma_default]{get_gamma_default()}}.
Only for internal use.
}
\details{
For species for which no value for \code{gamma} is specified in the species
parameter data frame, the \code{f0} values is kept as provided in the species
parameter data frame or it is set to 0.6 if it is not provided.
}
\seealso{
Other functions calculating defaults: 
\code{\link{get_gamma_default}()},
\code{\link{get_h_default}()},
\code{\link{get_ks_default}()}
}
\concept{functions calculating defaults}
\concept{helper}
