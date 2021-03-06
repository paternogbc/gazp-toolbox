% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/checks.R
\name{make_id}
\alias{make_id}
\title{Perform basic checks on a species list and create species unique id.}
\usage{
make_id(x, label = "id_")
}
\arguments{
\item{x}{A character vector specifying the species list, each element including
genus and specific epithet}

\item{label}{A character with the label prefix (e.g. id_) to generate a
unique identifier for the dataset.}
}
\value{
A data.frame with the following components:
\itemize{
\item{\strong{id}} A unique identifier for every species in the provided list.
\item{\strong{original_binomial}} The original names provided in \code{x}.
}
}
\description{
Perform basic checks on a species list and create species unique id.
}
\examples{
library(stdnames)
sp <- c("Mimosa tenuiflora", "Eucalyptus_lehmannii", "Yucca glauca")
make_id(x = sp)
}
