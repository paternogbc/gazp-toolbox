% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/higher_tax.R
\name{higher_tax}
\alias{higher_tax}
\title{Build a higher taxonomic table from a species list.}
\usage{
higher_tax(x)
}
\arguments{
\item{x}{A character vector with plant names.}
}
\value{
A data.frame with the following components:
\itemize{
\item{\strong{submitted_name}} The provided name.
\item{\strong{group}} The taxonomic group name.
\item{\strong{order}} The taxonomic order name.
\item{\strong{family}} The taxonomic family name.
\item{\strong{genus}} The taxonomic genus name.
}
}
\description{
Build a higher taxonomic table from a species list.
}
\details{
Plant names in which the genus does not occur in TPL database will
receive NA's for group, order and family.
}
\examples{
library(stdnames)
sp <- c("Mimosa tenuiflora", "Eucalyptus_lehmannii", "Yucca glauca")
higher_tax(sp)
}
