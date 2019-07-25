#' Build a higher taxonomic table from a species list.
#'
#' @param x A character vector with plant names.
#'
#' @return A data.frame with the following components:
#' \itemize{
#'   \item{\strong{binomial}} The original species name provided.
#'   \item{\strong{genus}} The genus name.
#'   \item{\strong{family}} The family name.
#'   \item{\strong{order}} The order name.
#'   \item{\strong{group}} The group name.
#'   \item{\strong{on_tpl}} Logical. Is the genus name on TPL?.
#'  }
#'
#' @examples
#' library(stdnames)
#' sp <- c("Mimosa tenuiflora", "Eucalyptus_lehmannii", "Yucca glauca")
#' higher_tax(sp)
#' @export
#' 
higher_tax <- function(x) {
  x <- suppressMessages(make_id(x))
  sp <- x$original_binomial
  tax <- taxonlookup::lookup_table(
    species_list = sp,
    by_species = TRUE,
    missing_action = "NA"
  )

  tax_out <-
    data.frame(
      binomial = sp,
      genus  = tax$genus,
      family = tax$family,
      order  = tax$order,
      group  = tax$group
    )
  # check if genus fail to match TPL list
  tax_out$on_tpl <- !c(is.na(tax_out$family) | is.na(tax_out$order))

  # get unmatched genus
  genus_fail <- as.character(tax_out[!tax_out$on_tpl, "genus"])

  nn <- length(genus_fail)
  if (nn > 0) {
    message(paste(
      "There are", nn, "unmatched genus names!", "\n",
      "You should probably check these manually!"
    ))
    message(paste(genus_fail, "\n"))
  }
  return(tax_out)
}

#' Clean and organize the output from TPL fuzzy matching
#'
#' @param x The output from TPL fuzzy matching.
#' @param verbose Logical. Print detailed information?
#'
#' @return
#' @export
clean_tpl <- function(x, verbose = TRUE) {
  ## Check species status
  x$tpl_binomial <- paste(x$New.Genus, x$New.Species)
  fail <- !x$Plant.Name.Index
  n_fail <- sum(fail)
  w_fail <- as.character(x[fail, ]$Taxon)
  miss <- x$Taxonomic.status == "Misapplied"
  n_miss <- sum(miss, na.rm = T)
  w_miss <- as.character(x[miss, ]$Taxon)
  spel <- x$Typo == TRUE
  n_spel <- sum(spel, na.rm = T)
  w_spel <- data.frame(
    id_names       = x[spel, ]$id_names,
    submitted_name =  as.character(x[spel, ]$Taxon),
    corrected_name = as.character(x[spel, ]$tpl_binomial))

  if (is.null(x$id_names)) {
    xt <-
      data.frame(
        submitted_binomial = x$Taxon,
        tpl_binomial       = paste(x$New.Genus, x$New.Species),
        tpl_authority      = x$New.Authority,
        tpl_id             = x$New.ID,
        tpl_status         = x$New.Taxonomic.status,
        tpl_version        = x$TPL.version,
        on_tpl             = x$Plant.Name.Index,
        corrected          = spel,
        misapplied         = miss
      )
  } else {
    xt <-
      data.frame(
        id_names           = x$id_names,
        submitted_binomial = x$Taxon,
        tpl_binomial       = paste(x$New.Genus, x$New.Species),
        tpl_authority      = x$New.Authority,
        tpl_id             = x$New.ID,
        tpl_status         = x$New.Taxonomic.status,
        tpl_version        = x$TPL.version,
        on_tpl             = x$Plant.Name.Index,
        corrected          = spel,
        misapplied         = miss
      )
    std <- xt[, c("id_names", "submitted_binomial", "tpl_binomial")]
  }

  ### detect and clean dupliacted species
  dup      <- duplicated(xt$tpl_binomial)
  w_sp_dup <- as.character(xt$tpl_binomial[dup])
  w_dup    <- xt[x$tpl_binomial %in% w_sp_dup, ]
  w_dup    <- w_dup[order(w_dup$tpl_binomial),]
  w_dup    <- w_dup[, c("id_names", "submitted_binomial", "tpl_binomial")]
  n_dup    <- length(w_sp_dup)

  ### add column for duplicated species
  xt$duplicated <- dup

  ### Create clean table without duplicated species
  xt_clean <- xt[xt$duplicated == FALSE, ]


  ### Warning and messages
  if (n_fail != 0) {
    message(n_fail, " names submitted are not on The Plant List")
    if (verbose == TRUE) {
      message("Check these species manually", paste("\n", w_fail))
    }
  }

  ### Warning and messages
  if (n_spel != 0) {
    message(
      n_spel, " names submitted were corrected automatically!",
      " Make sure they are right."
    )
    if (verbose == TRUE) {
      message("Check these species manually", paste("\n", w_spel))
    }
  }

  ### Warning and messages
  if (n_dup != 0) {
    message(
      n_dup, " duplicated names (after standardization) were excluded."
    )
    if (verbose == TRUE) {
      message("Check these species manually", paste("\n", w_sp_dup))
    }
  }

  ### Warning and messages
  if (n_miss != 0) {
    message(
      n_miss, " names have `Misapplied` as Taxonomic Statatus!",
      " See `?TPLck()` for details"
    )
    if (verbose == TRUE) {
      message("Check these species manually", paste("\n", w_miss))
    }
  }

  res <- list(
    std_all = xt,
    std_clean = xt_clean,
    which_fail = w_fail,
    which_corrected = w_spel,
    which_duplicated = w_dup
  )

  if (!is.null(x$id_names)) {
    res$std <- std
    }
  return(res)
}

#' Standardize plant names
#'
#' A reproducible protocol to standardize plant names from a comparative
#'  dataset.
#'
#' @param x A data.frame with your data and one column with plant species names
#' that you iwsh to standardize.
#' @param species_column A character with the name of the column in the data.frame
#' that contains the plant species names that you iwsh to standardize.
#' @param id_label A character with the label prefix (e.g. id_) to generate a
#' unique identifier for the dataset.
#' @param infra Logical. If TRUE (default), infraspecific epithets are used to
#'  match taxon names in TPL.
#' @param max.distance A number indicating the maximum distance allowed for a 
#' match in agrep when performing corrections of spelling errors in specific
#'  epithets. see \code{\link{agrep}}.
#' @param diffchar A number indicating the maximum difference between the number
#'  of characters in corrected and original taxon names.
#' @param version A character vector indicating whether to connect to the newest
#'  version of TPL (1.1) or to the older one (1.0). Defaults to "1.1".
#'
#' @return A list with the following components:
#' \itemize{
#'   \item{\strong{std}} The original data.frame with standardized plant names
#'   following The Plant List.
#'   \item{\strong{std_names}} A data.frame with submitted and standardized plant
#'   names following The Plant List.
#'   \item{\strong{tpl_all}} The original data.frame with detailed information on
#'   name standardization following The Plant List.
#'   \item{\strong{tpl_clean}} The \code{tpl_all} data.frame after excluding
#'   duplicated plant names.
#'   \item{\strong{taxonomy_clean}} A taxonomic lookup table including the higher
#'    taxonomy of each plant name in {tpl_clean}.
#'   \item{\strong{which_fail}} The names that fail to match with The
#'    Plant list database.
#'   \item{\strong{which_corrected}} The names that were corrected automatically
#'   to match The Plant List database.
#'   \item{\strong{which_duplicated}} The names that were duplicated after
#'   standardization (e.g removing synonyms)
#'   \item{\strong{raw_tpl_out}} the raw output from \code{\link{TPL}}.
#'   \item{\strong{source_data }} The source data.frame provided with unique
#'   identifiers \code{id_names}.
#'   \item{\strong{tpl_warnings}} Any warning during TPL fuzzy matching.
#' }
#' @seealso \code{\link{TPL}} and \code{\link{TPLck}}.
#' 
#' @details This function uses the functions: \code{\link{TPL}} and
#'  \code{\link{TPLck}} from the R package \code{Taxonstand} to perform 
#'  name standardization following The Plant List database.
#' @export
#'
#' @examples
#' \dontrun{
#' library(stdnames)
#'
#'my_data <- species_data
#'# Stanardize species names within a comparative dataset
#'# First check and fix morphotypes
#'# check morphotypes
#'mf <- fix_morphotype(x = my_data$species)
#'mf[mf$morphotype == "yes", ]
#'
#'# Replace morphotype names
#'my_data$species <- mf$corrected_binomial
#'
#'# Run protocol to standardize plant names
#'out <- std_names(x = my_data, species_column = "species", id_label = "ID")
#'
#'# Your dataset plus corrected names
#'out$std
#'
#'# Only submitted/corrected names
#'out$std_names
#'
#'# Complete output (with details on name standardization)
#'out$tpl_all
#'
#'# After removing duplicated names
#'out$tpl_clean
#'
#'# A higher taxonomy for the clean species list
#'out$taxonomy_clean
#'
#'# Names that failed to match the plant list
#'out$which_fail
#'
#'# Names that were automatically corrected
#'out$which_corrected
#'
#'# Duplicated names after standardization
#'out$which_duplicated
#'
#'# The complete output from TPL fuzzy matching
#'out$raw_tpl_out
#'
#'# Source data with unique identifiers for each row in the data.frame
#'out$source_data
#'}
#'
std_names <- function(x, species_column, id_label = "ID_", 
                      infra = FALSE, max.distance = 1, diffchar = 2,
                      version = "1.1"){
  # checks---
  if (!is.data.frame(x)) {
    stop("x must be a data.frame")
  }

  # get variables
  s_df <- x
  cn <- colnames(s_df)
  cm <- match(species_column, cn)

  if (is.na(cm)) {
    stop(paste(species_column, "is not a column in the provided data.frame"))
  }

  # check for duplicated names
  if (sum(duplicated(x[, species_column]), na.rm = T) > 0) {
    message(
      paste("Be aware, duplicated names were provied on the ",
            "`", species_column, "`", "column!")
      )
  }

  # Get names vector
  spn    <- as.character(s_df[, cm])
  # Check for morphotypes

  mt <- suppressMessages(fix_morphotype(x = spn, pattern = c("spp.", "NA", " ")))
  if (!is.atomic(mt)) {
    stop("Check and correct morphotypes following the pattern: `Genus sp.`")
  }

  # give then unique ids
  spn_id        <- make_id(spn, label = id_label)
  s_df$id_names <- spn_id$id_names

  # Run fuzz muchting with TPL
  sp.tpl       <- Taxonstand::TPL(splist = spn, infra = infra)
  tpl_warnings <- warnings()

  # add id names to tpl output
  sp.tpl$id_names <- s_df$id_names

  # Prepare outputs
  raw_tpl_out   <- merge(s_df, sp.tpl, by = "id_names")
  clean_tpl_out <- clean_tpl(raw_tpl_out, verbose = F)

  tpl_all         <- merge(s_df, clean_tpl_out$std_all, by = "id_names")
  tpl_all[, c("submitted_binomial")] <- NULL

  tpl_clean       <- merge(s_df, clean_tpl_out$std_clean, by = "id_names")
  tpl_clean[, c("submitted_binomial")] <- NULL


  # Check if mergers are correct
  if (nrow(tpl_all) != nrow(s_df)) {
    stop("Number of rows between TPL output and source data are not equal!",
         "Something is really wrong!")
  }
  if (nrow(sp.tpl) != nrow(s_df)) {
    stop("Number of rows between TPL output and source data are not equal!",
         "Something is really wrong!")
  }

  ### Add higher taxonomy
  tax <- higher_tax(tpl_clean$tpl_binomial)
  cnt <- colnames(tax)
  tax$id_names <- tpl_clean$id_names
  tax <- tax[, c("id_names", cnt)]

  std <- merge(s_df, clean_tpl_out$std, by = "id_names")
  ncn <- setdiff( colnames(x), species_column)
  std <- std[, c("id_names", species_column, "tpl_binomial", ncn)]

  # Create complete output
  out <- list(
    std              = std,
    std_names        = clean_tpl_out$std,
    tpl_all          = tpl_all,
    tpl_clean        = tpl_clean,
    taxonomy_clean   = tax,
    which_fail       = clean_tpl_out$which_fail,
    which_corrected  = clean_tpl_out$which_corrected,
    which_duplicated = clean_tpl_out$which_duplicated,
    raw_tpl_out      = raw_tpl_out,
    source_data      = s_df[ , c("id_names", colnames(x))],
    tpl_warnings     = tpl_warnings
  )
  return(out)
}
