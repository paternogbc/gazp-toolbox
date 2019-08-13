#' Remove unecessary white spaces from plant names.
#'
#' @param x A character vector with plant names.
#'
#' @return The names provided after checking and removing for
#' Leading/Trailing and unecessary white spaces on names.
#' @export
#'
#' @examples
#' library(stdnames)
#' sp <- c("Mimosa tenuiflora ", "Yucca   glauca", " Eucalyptus angulosa")
#' white_space(sp)
white_space <- function(x) {
  if (class(x) != "character") {
    stop("x must be a character vector!")
  }
  x1 <- x
  x2 <- trimws(x1)
  x3 <- gsub("\\s+"," ", x2)
  if(!identical(x1, x2) & !identical(x2, x3)) {
    message("Leading/Trailing or unecessary white spaces were removed from names")
  }
  return(x3)
}

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
  
  ## Check and remove white spaces
  x <- white_space(x)
  
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
    original_name = x,
    stringsAsFactors = FALSE
  )
  return(res)
}

# Function to parse names provided into (Genus, epithet).
#' parse_names()
#'
#' @param x A character vector specifying a list of plant names, each element 
#' including at least genus and epithet, but infra ranks (var.) can also be 
#' provided.
#'
#' @return A data.frame with the following components:
#' \itemize{
#'   \item{\strong{original_name}} The original names provided in \code{x}.
#'   \item{\strong{original_genus}} The parsed Genus name extracted from \code{x}.
#'   \item{\strong{original_epi}} The parsed Epithet name extracted from \code{x}.
#'   \item{\strong{original_rank}} The parsed infraspecific rank abbreviation 
#'   extracted from \code{x}.
#'   \item{\strong{original_infra}} The parsed Infraspecific name extracted from
#'    \code{x}.
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
  genus  <- sapply(strsplit(x$original_name, split = " "), FUN = `[`, 1)
  epi    <- sapply(strsplit(x$original_name, split = " "), FUN = `[`, 2)
  sub_t  <- sapply(strsplit(x$original_name, split = " "), FUN = `[`, 3)
  sub_n  <- sapply(strsplit(x$original_name, split = " "), FUN = `[`, 4)
  res <- data.frame(
    name = x$original_name,
    genus = genus,
    epi = epi,
    rank = sub_t,
    infra = sub_n,
    stringsAsFactors = FALSE
  )
  res[is.na(res)] <- ""
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

  # parse names
  x <- parse_names(x)

  xe <- x$epi
  xb <- x$name

  # Check if there is true blanks in epithet and convert to NA
  xe[xe == ""] <- "NA"
  
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
    return(x)
  }

  if (n_morp > 0) {
    # Cprrect epithets
    correct_epi <- x$epi
    correct_epi[x$morphotype == "yes"] <- label
    x$corrected_name <- white_space(
      paste(x$genus, correct_epi, x$rank, x$infra)
    )
    

    if (detailed == TRUE) {
      out <- list(
        x = x,
        morphotypes = data.frame(
          original_name = x[x$morphotype == "yes", ]$name,
          corrected_name= x[x$morphotype == "yes", ]$corrected_name
        ),
        types_count = t_morp
      )
    } else {
      out <- x[, c("name", "corrected_name", "morphotype")]
    }
  }
  return(out)
}