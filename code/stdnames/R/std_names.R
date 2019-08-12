#' Standardize plant names
#'
#' A reproducible protocol to standardize plant names from a comparative
#'  dataset.
#'
#' @param x A data.frame with your data and one column with plant species names
#' that you iwsh to standardize.
#' @param species_column A character with the name of the column in the data.frame
#' that contains the plant species names that you iwsh to standardize.
#' @param trait_columns A character vector with the column names in the data.frame
#' that contains variables (traits) you want to keep in the output.
#' @param infra Logical. If TRUE (default), infraspecific epithets are used to
#'  match taxon names in TPL.
#' @param max.distance A number indicating the maximum distance allowed for a 
#' match in agrep when performing corrections of spelling errors in specific
#'  epithets. see \code{\link{agrep}}.
#' @param diffchar A number indicating the maximum difference between the number
#'  of characters in corrected and original taxon names.
#' @param version A character vector indicating whether to connect to the newest
#'  version of TPL (1.1) or to the older one (1.0). Defaults to "1.1".
#' @param verbose Logical. If TRUE detailed messages and warnings are printed.
#' @return A list with the following components:
#' \itemize{
#'   \item{\strong{std}} The original data.frame with standardized plant names
#'   following The Plant List.
#'   \item{\strong{std_names}} A data.frame with submitted and standardized plant
#'   names following The Plant List.
#'   \item{\strong{tpl_all}} The original data.frame with detailed information on
#'   name standardization following The Plant List.
#' }
#' @seealso \code{\link{TPL}} and \code{\link{TPLck}}.
#' 
#' @details This function uses the functions: \code{\link{TPL}} and
#'  \code{\link{TPLck}} from the R package \code{Taxonstand} to perform 
#'  name standardization following The Plant List database.
#' @export
#'
std_names <- function(x, species_column, trait_columns = NULL,
                      infra = TRUE, max.distance = 1, diffchar = 2,
                      version = "1.1", verbose = FALSE){
  # checks---
  if (!is.data.frame(x)) {
    stop("x must be a data.frame!")
  }
  
  # get variables
  id_label = "ID_"
  s_df <- x
  cn <- colnames(s_df)
  cm <- match(species_column, cn)
  ct <- trait_columns 
  if (is.na(cm)) {
    stop(paste(species_column, "is not a column in the provided data.frame"))
  }
  
  if (any(is.na(match(ct, cn)))) {
    stop(paste("trait_columns not found in the provided data.frame!"))
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
  
  # Check for blans and NA on Genus and epithet!
  pn <- parse_names(spn)
  bcg <- is.na(pn$genus) | pn$genus == "" | pn$genus == " "
  bce <- is.na(pn$epi) | pn$epi == "" | pn$epi == " "
  
  ### Check for blank genus or epithets provided
  if(any(bcg == TRUE) | any(bce == TRUE)) {
    stop("Blank or NA detected ! Check and correct these names!")
  }
  
  # give then unique ids
  spn_id        <- make_id(spn, label = id_label)
  s_df$id_names <- spn_id$id_names
  
  # converte species_column to "original_name"
  names(s_df)[names(s_df) == species_column] <- "original_name"
  
  # Run fuzz muchting with TPL
  sp.tpl       <- Taxonstand::TPL(splist = spn_id$original_name,
                                  infra = infra, max.distance = max.distance,
                                  diffchar = diffchar, version = version)
  tpl_warnings <- warnings()
  
  # add id names to tpl output
  sp.tpl$id_names <- s_df$id_names
  
  # Prepare outputs
  raw_tpl_out   <- merge(s_df, sp.tpl, by = c("id_names"))
  cle_out       <- clean_tpl(raw_tpl_out, verbose = verbose)
  cle_out$std_all$original_name <- NULL
  tpl_all       <- merge(s_df[, c("original_name", "id_names", ct)],
                         cle_out$std_all, by = "id_names")
  
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
  tax_out   <- higher_tax(as.character(tpl_all$tpl_genus))
  tpl_full  <- merge(tpl_all, 
                      tax_out, 
                      by.x = "tpl_genus",
                      by.y = "genus",
                      all.x = TRUE)

  # Full output-----
  tpl_full <- tpl_full[, c(
    "original_name", "tpl_name", "tpl_genus", "tpl_epithet", "tpl_infra_rank",
    "tpl_infra_name", "tpl_authority", "tpl_id", "family", "order", "group",
    "tpl_status", "tpl_version",
    "on_tpl", "fail_rank", "corrected", "misapplied", "changed", "duplicated",
    ct)]
  
  # Short output----
  cnf <- c("original_name", "tpl_name", "tpl_genus",
           "tpl_epithet", "tpl_infra_rank", "tpl_infra_name",
           "family","order","group", "on_tpl", "fail_rank", "changed",
    ct
    )
  tpl_short <- tpl_full[, cnf]
  
    # Create complete output
    res <- list(
      std_names        = cle_out$std,
      tpl_full         = tpl_full,
      tpl_short        = tpl_short,
      which_fail_name  = cle_out$which_fail,
      which_fail_rank  = cle_out$which_rank_fail,
      which_fail_genus = cle_out$which_genus_fail,
      which_changed    = cle_out$which_changed,
      which_corrected  = cle_out$which_corrected,
      which_duplicated = cle_out$which_duplicated,
      raw_tpl_out      = raw_tpl_out,
      source_data      = x,
      tpl_warnings     = tpl_warnings
    )
  
  out <- list(
    corrected_list  = tpl_short,
    unmatched_list  = tpl_short[tpl_short$on_tpl == FALSE, ],
    detailed_output = res
    )
  return(out)
}
