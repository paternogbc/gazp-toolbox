#' Perform basic checks on a species list and create species unique id.
#'
#' @param x A character vector specifying the species list, each element including
#'  genus and specific epithet
#' @param label A character with the label prefix (e.g. id_) to generate a
#' unique identifier for the dataset.
#'
#' @return A data.frame with the following components:
#' \itemize{
#'   \item{\strong{id}} A unique identifier for every species in the provided list.
#'   \item{\strong{original_binomial}} The original names provided in \code{x}.
#' }
#'
#' @examples
#' library(stdnames)
#' sp <- c("Mimosa tenuiflora", "Eucalyptus_lehmannii", "Yucca glauca")
#' make_id(x = sp)
#' @export
make_id <- function(x, label = "id_") {
  if (!is.atomic(x)) {
    stop("x must be a vector!")
  }
  # is character?
  if (!is.character(x)) {
    x <- as.character(x)
    message("Names were converted to a character vector")
  }
  # check if species are not in Genus_epithet format
  if (sum(grepl(pattern = "_", x = x)) != 0) {
    x <- gsub(pattern = "_", replacement = " ", x = x)
    message(
      "Names were converted to `Genus epithet` format instead of ",
      "`Genus_epithet`"
    )
  }
  ## Generate unique id_names for each name provided!
  id_names <- paste(
    label,
    formatC(
      seq_len(length(x)), width=3, flag="0"
      ),
    sep = ""
    )
  res <- data.frame(
    id_names = id_names,
    original_binomial = x,
    stringsAsFactors = FALSE
  )
  return(res)
}

# Function to parse names provided into (Genus, epithet).
#' parse_names()
#'
#' @param x A character vector specifying the species list, each element including
#'  genus and specific epithet
#'
#' @return A data.frame with the following components:
#' \itemize{
#'   \item{\strong{original_binomial}} The original names provided in \code{x}.
#'   \item{\strong{original_genus}} The parsed Genus name extracted from \code{x}.
#'   \item{\strong{original_epi}} The parsed Epithet name extracted from \code{x}.
#' }
#'
#' @export
#'
#' @examples
#' library(stdnames)
#' sp <- c("Mimosa tenuiflora", "Eucalyptus_lehmannii", "Yucca glauca")
#' parse_names(x = sp)
parse_names <- function(x) {
  x <- make_id(x = x)
  n <- nrow(x)
  genus <- sapply(strsplit(x$original_binomial, split = " "), FUN = `[`, 1)
  epi <- sapply(strsplit(x$original_binomial, split = " "), FUN = `[`, 2)
  res <- data.frame(
    original_binomial = x$original_binomial,
    original_genus = genus,
    original_epi = epi,
    stringsAsFactors = FALSE
  )
  ngen <- length(unique(genus))
  message(paste(
    n, "unique binomial names and",
    ngen, "unique Genus names were provided!"
  ))
  return(res)
}

#' Correct morphotypes
#'
#' Find and fix morphotypes in a species list
#'
#' @param x A character vector specifying the species list, each element including
#'  genus and specific epithet
#' @param pattern A character vector specifying the pattern to identify potential
#' morphotypes.
#' @param label A character string to replace morphotypes epithet.
#' @param detailed Logical. If TRUE returns a more detailed output.
#' @return
#' @export
#'
#' @examples
#' library(stdnames)
#' sp <- c("Mimosa sp.", "Eucalyptus_NA", "Yucca glauca")
#' fix_morphotype(x = sp)
#' fix_morphotype(x = sp, label = "spp.")
#'
#'#change patterns to spot morphotypes
#' sp <- c("Mimosa unkown", "Eucalyptus_NA", "Yucca glauca")
#' fix_morphotype(x = sp, pattern = c("unkown", "NA"))
#'
#'# No morphotypes found, x is returned back!
#'sp <- c("Mimosa tenuiflora", "Eucalyptus angulosa", "Yucca glauca")
#'fix_morphotype(x = sp, pattern = c("unkown", "NA"))
#'
# For a detailed output
#' sp <- c("Mimosa tenuiflora", "Mimosa sp.", "Eucalyptus_NA", "Yucca NA",
#' "Acacia spp.", "Acacia ")
#' out <- fix_morphotype(x = sp, detailed = TRUE)
#' out$x
#'  out$morphotypes
#' barplot(out$types_count)

fix_morphotype <- function(
  x, pattern = c("sp.", "spp.", "spp", "NA"),
  label = "sp.",
  detailed = FALSE
  ) {

  # check if names were parsed
  ox <- x
  sc <- sum(
    colnames(x) == c(
      "original_binomial", "original_genus", "original_epi"
    )
  )
  if (sc < 3) {
    x <- suppressMessages(parse_names(x))
  }

  xe <- x$original_epi
  xb <- x$original_binomial

  # Check if there is true NA in epithet and convert to character
  xe[is.na(xe)] <- "NA"

  wsp <- lapply(pattern, function(x) {
      which(grepl(pattern = x, x = xe, fixed = TRUE))
    })
    names(wsp) <- pattern

  morp <- lapply(wsp, function(x) {
    xb[x]
  })
  n_morp <- length(unique(do.call(c, wsp)))
  t_morp <- sapply(morp, length)
  morp_unique <- unique(do.call(c, wsp))
  x$morphotype <- "no"


  if (sum(t_morp, na.rm = TRUE) > 0) {
    x[morp_unique, ]$morphotype <- "yes"
    message(paste(sum(n_morp), "species names might be morphotypes!",
                  "Consider checking `morphotype == yes`"))
  }

  if (n_morp == 0) {
    message("No morphotypes were found!")
    message("Orginal vector is returned back!")
    out <- ox
  }

  if (n_morp > 0) {
    # Cprrect epithets
    x$corrected_epi <- x$original_epi
    x$corrected_binomial <- x$original_binomial
    x[x$morphotype == "yes", ]$corrected_epi <- label
    x[x$morphotype == "yes", ]$corrected_binomial <-
      paste(x[x$morphotype == "yes", ]$original_genus, label)

    if (detailed == TRUE) {
      out <- list(
        x = x,
        morphotypes = data.frame(
          original_binomial = x[x$morphotype == "yes", ]$original_binomial,
          corrected_binomial = x[x$morphotype == "yes", ]$corrected_binomial
        ),
        types_count = t_morp
      )
    } else {
      out <- x[, c("original_binomial", "corrected_binomial", "morphotype")]
    }
  }
  return(out)
}
