% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/setInteraction.R
\name{setInteraction}
\alias{setInteraction}
\alias{getInteraction}
\title{Set species interaction matrix}
\usage{
setInteraction(params, interaction = NULL)

getInteraction(params)
}
\arguments{
\item{params}{MizerParams object}

\item{interaction}{Optional interaction matrix of the species (predator
species x prey species). Entries should be numbers between 0 and 1. By
default all entries are 1. See "Setting interactions" section below.}
}
\value{
MizerParams object with updated interaction matrix. Because of the
way the R language works, \code{setInteraction()} does not make the changes to
the params object that you pass to it but instead returns a new params
object. So to affect the change you call the function in the form
\code{params <- setInteraction(params, ...)}.
}
\description{
Set species interaction matrix
}
\section{Setting interactions}{


The interaction matrix \eqn{\theta_{ij}} describes the interaction of each
pair of species in the model. This can be viewed as a proxy for spatial
interaction e.g. to model predator-prey interaction that is not size based.
The values in the interaction matrix are used to scale the encountered food
and predation mortality (see on the website
\href{https://sizespectrum.org/mizer/articles/model_description.html#sec:pref}{the section on predator-prey encounter rate}
and on \href{https://sizespectrum.org/mizer/articles/model_description.html#mortality}{predation mortality}).
The first index refers to the predator species and the second to the prey
species.

It is used when calculating the food encounter rate in \code{\link[=getEncounter]{getEncounter()}} and
the predation mortality rate in \code{\link[=getPredMort]{getPredMort()}}. Its entries are
dimensionless numbers.The values are between 0 (species do not overlap and
therefore do not interact with each other) to 1 (species overlap perfectly).
If all the values in the interaction matrix are set to 1 then predator-prey
interactions are determined entirely by size-preference.

This function checks that the supplied interaction matrix is valid and then
stores it in the \code{interaction} slot of the params object before returning
that object.

The order of the columns and rows of the \code{interaction} argument should be the
same as the order in the species params data frame in the \code{params} object. If
you supply a named array then the function will check the order and warn if
it is different. One way of creating your own interaction matrix is to enter
the data using a spreadsheet program and saving it as a .csv file. The data
can be read into R using the command \code{read.csv()}.

The interaction of the species with the resource are set via a column
\code{interaction_resource} in the \code{species_params} data frame. Again the entries have to
be numbers between 0 and 1. By default this column is set to all 1s.
}

\examples{
\dontrun{
params <- newTraitParams()
interaction <- getInteraction(params)
interaction[1, 3] <- 0
params <- setInteraction(params, interaction)
}
}
\seealso{
Other functions for setting parameters: 
\code{\link{gear_params}()},
\code{\link{resource_params}()},
\code{\link{setExtMort}()},
\code{\link{setFishing}()},
\code{\link{setInitialValues}()},
\code{\link{setMaxIntakeRate}()},
\code{\link{setMetabolicRate}()},
\code{\link{setParams}()},
\code{\link{setPredKernel}()},
\code{\link{setReproduction}()},
\code{\link{setResource}()},
\code{\link{setSearchVolume}()},
\code{\link{species_params}()}
}
\concept{functions for setting parameters}
