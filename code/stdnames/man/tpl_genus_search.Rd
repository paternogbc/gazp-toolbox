% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/url_search.R
\name{tpl_genus_search}
\alias{tpl_genus_search}
\title{Check genus}
\usage{
tpl_genus_search(genus, infra = TRUE)
}
\arguments{
\item{genus}{The name of the genus to search on The Plant List.}
}
\value{
A list with the following components:
\itemize{
\item{\strong{tpl_genus}} The name of the Genus on The Plant List.
\item{\strong{species_list}} A character vector with the list of species
from submitted genus name.
}
}
\description{
Check if a genus exist in The Plant List website.
}
