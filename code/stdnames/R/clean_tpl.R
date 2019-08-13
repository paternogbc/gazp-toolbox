#' Clean and organize the output from TPL fuzzy matching
#'
#' @param x The output from TPL fuzzy matching.
#' @param verbose Logical. Print detailed information?
#'
#' @return A cleaned and organized output from \link{TPL} search.
#' @export
clean_tpl <- function(x, verbose = TRUE) {
  message("cleaning output...")
  ## Join parsed names
  tpl_name <- paste(x$New.Genus, x$New.Species)
  winfra <- !is.na(x$New.Infraspecific.rank)
  tpl_name[winfra] <- trimws(
    paste(
      x[winfra,]$New.Genus,
      x[winfra,]$New.Species,
      x[winfra,]$New.Infraspecific.rank,
      x[winfra,]$New.Infraspecific)
  )
  
  # clean unecessary white spaces
  x$tpl_name <- white_space(tpl_name)
  
  # tpl flags
  fail   <- !x$Plant.Name.Index
  high   <- x$Higher.level
  n_high <- sum(high, na.rm = TRUE)
  w_high <- as.character(x[high, ]$Taxon)
  miss   <- x$Taxonomic.status == "Misapplied"
  n_miss <- sum(miss, na.rm = TRUE)
  w_miss <- as.character(x[miss, ]$Taxon)
  spel   <- x$Typo == TRUE
  n_spel <- sum(spel, na.rm = TRUE)
  w_spel <- data.frame(
    submitted_name =  as.character(x[spel, ]$Taxon),
    corrected_name = as.character(x[spel, ]$tpl_name)
  )
  
  # which fail
  fail_tpl = (fail == TRUE & high == FALSE)
  n_fail <- sum(fail_tpl, na.rm = TRUE)
  w_fail <- as.character(x[fail_tpl, ]$Taxon)
  
  ### Which changed
  chd    <- x$Taxon != x$tpl_name
  n_chd  <- sum(chd, na.rm = TRUE)
  w_chd  <- data.frame(
    submitted_name = as.character(x[chd, ]$Taxon),
    corrected_name = as.character(x[chd, ]$tpl_name)
  )
  # Detailed output
  xt <-
    data.frame(
      submitted_name     = x$Taxon,
      tpl_name           = x$tpl_name,
      tpl_genus          = x$New.Genus,
      tpl_epithet        = x$New.Species,
      tpl_infra_rank     = x$New.Infraspecific.rank,
      tpl_infra_name     = x$New.Infraspecific,
      tpl_authority      = x$New.Authority,
      tpl_id             = x$New.ID,
      tpl_status         = x$New.Taxonomic.status,
      tpl_version        = x$TPL.version,
      on_tpl             = !fail_tpl,
      fail_rank          = x$Higher.level,
      corrected          = spel,
      misapplied         = miss,
      changed            = chd,
      stringsAsFactors = F
    )
  
  # Make tpl_x NA for names that fail to occur in TPL
  gfail   <- NULL
  n_gfail <- NULL
  if (n_fail > 0) {
    
    # first check for genus that exist even if the name fails
    gc    <- suppressMessages(tpl_genus_check(parse_names(w_fail)$genus))
    
    if (FALSE %in% gc$on_tpl) {
      gfail   <- gc[gc$on_tpl != TRUE, ]$genus
      n_gfail <- length(gfail)
      xt[xt$tpl_genus %in% gfail, ]$tpl_genus <- ""
    } 
    
    xt[xt$on_tpl == FALSE, ]$tpl_name       <- ""
    xt[xt$on_tpl == FALSE, ]$tpl_epithet    <- ""
    xt[xt$on_tpl == FALSE, ]$tpl_infra_rank <- ""
    xt[xt$on_tpl == FALSE, ]$tpl_infra_name <- ""
  }
  
  # Make blank status = "not_on_tpl"
  if (sum(xt$tpl_status == "", na.rm = T) > 0){
    xt[xt$tpl_status == "", ]$tpl_status <- "NOT in TPL"
  }
  
  if (is.null(x$id_names)) {
    std <- xt[, c("submitted_name", "tpl_name")]
  } else {
    xt <-
      data.frame(
        id_names = x$id_names, 
        xt
      )
    std <- xt[, c("submitted_name", "tpl_name")]
  }
  
  
  
  ### detect and clean dupliacted species
  dup      <- duplicated(xt[, "tpl_name"], incomparables = NA)
  w_sp_dup <- as.character(xt$tpl_name[dup])
  w_dup    <- xt[x$tpl_name %in% w_sp_dup, ]
  w_dup    <- w_dup[order(w_dup$tpl_name),]
  w_dup    <- w_dup[, c("submitted_name", "tpl_name")]
  n_dup    <- length(w_sp_dup)
  
  ### add column for duplicated species
  xt$duplicated <- dup
  
  ### Names that failed
  if (n_fail != 0) {
    message(n_fail, " name (s) submitted were not found in The Plant List!")
    if (verbose == TRUE) {
      message("Check these names manually", paste("\n", w_fail))
    }
  }
  
  ### Genus fails
  if (!is.null(n_gfail)) {
    message(n_gfail, " Genus name (s) were not found in The Plant List!")
    if (verbose == TRUE) {
      message("Check these names manually. Perharps try: fuzzy_genus()", paste("\n", gfail))
    }
  }
  ### Warning and messages
  if (n_high != 0) {
    message(n_high, " name (s) submitted have infraspecific levels that does not ", 
            "occur in The Plant List.")
    if (verbose == TRUE) {
      message("Be aware:", paste("\n", w_high))
    }
  }
  
  ### Warning and messages
  if (n_spel != 0) {
    message(
      n_spel, " names submitted were corrected automatically!",
      " Make sure they are right."
    )
    if (verbose == TRUE) {
      message("Be aware: ", paste("\n", w_spel$submitted_name))
    }
  }
  
  ### Warning and messages
  if (n_dup != 0) {
    message(
      n_dup, " duplicated name (s) were detected"
    )
    if (verbose == TRUE) {
      message("Be aware:", paste("\n", w_sp_dup))
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
    std              = std,
    std_all          = xt,
    which_fail       = w_fail,
    which_genus_fail = gfail,
    which_rank_fail  = w_high,
    which_changed    = w_chd,
    which_corrected  = w_spel,
    which_duplicated = w_dup
  )
  return(res)
}
