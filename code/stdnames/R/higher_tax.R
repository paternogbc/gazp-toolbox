#' Build a higher taxonomic table from a species list.
#'
#' @param x A character vector with plant names.
#'
#' @return A data.frame with the following components:
#' \itemize{
#'   \item{\strong{submitted_name}} The provided name.
#'   \item{\strong{group}} The taxonomic group name.
#'   \item{\strong{order}} The taxonomic order name.
#'   \item{\strong{family}} The taxonomic family name.
#'   \item{\strong{genus}} The taxonomic genus name.
#'  }
#'
#' @details Plant names in which the genus does not occur in TPL database will 
#' receive NA's for group, order and family.
#' 
#' @examples
#' library(stdnames)
#' sp <- c("Mimosa tenuiflora", "Eucalyptus_lehmannii", "Yucca glauca")
#' higher_tax(sp)
#' @export
#' 
higher_tax <- function(x) {
  # crop duplicated names and remove NA
  x <- x[!duplicated(x)]
  x <- x[x != ""]
  x <- x[!is.na(x)]
  
  tax <- taxonlookup::lookup_table(
    species_list = x,
    by_species = TRUE,
    missing_action = "NA",
  )
  tax$submitted_name = rownames(tax)
  rownames(tax) <- NULL
  tax <- tax[, c("submitted_name", "genus", "family", "order", "group")]
  return(tax)
}
