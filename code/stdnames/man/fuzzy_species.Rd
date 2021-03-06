% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/url_search.R
\name{fuzzy_species}
\alias{fuzzy_species}
\title{Fuzzy matching TPL species names}
\usage{
fuzzy_species(x, max.distance = 1, species_list = NULL, ...)
}
\arguments{
\item{x}{A character vector with species names to perform match.}

\item{max.distance}{Maximum distance allowed for a match.}

\item{species_list}{The list of unique genus names. If NULL, the updated list
of names will be downloaded from The Plant List website with \link{tpl_genus}}

\item{...}{Arguments to be passed to \link{agrep}.}
}
\value{
A list with potential matches for the submitted names.
}
\description{
Try to match submitted species name with names from The Plant List using
fuzzy maching approach.
}
