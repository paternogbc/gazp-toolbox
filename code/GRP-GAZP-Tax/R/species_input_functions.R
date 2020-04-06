


### Functions that feed into the 'species_names_processing.R' and 'species_trait_creation.R' workflows
# Updated on: April 6, 2020
# Updated by: Emma Ladouceur


##################### Creating species codes
code_creation <- function(missings, gazp) {
  
  # Flag infraspecies, morphotypes
  missings <- missings %>%
    mutate(infra = ifelse(str_detect(name, "subsp."),
                          "subspecies",
                          NA),
           infra = ifelse(str_detect(name, "spp"),
                          "morphotype",
                          infra),
           infra = ifelse(str_detect(name, "var."),
                          "variant",
                          infra))
  
  # Make code, with special naming rules for subspecies and morphotypes
  missings <- missings %>%
    separate(name, into = c("genus", "species", 
                            "type", "infra_name"),
             remove = FALSE) %>%
    mutate(speciesid = 
             paste(str_sub(genus, 1, 3),
                             str_sub(species, 1, 3),
                   sep = "_")) %>%
    mutate(speciesid = case_when(infra == "subspecies" ~ paste0(speciesid, "1"), 
                                 TRUE ~ speciesid)) %>% 
    mutate(speciesid = case_when(infra == "morphotype" ~ paste0("G_", speciesid), 
                                 TRUE ~ speciesid)) %>%
    select(Code, old_name, name, speciesid, infra, morphotype)
  
  # summarise any duplicate species codes within new species list
  n.conflict <- missings %>% group_by(speciesid) %>% filter(n()>1) %>% summarize(n=n())
  
  # flag those new duplicates as a conflict
  missings2 <- missings %>%  mutate(conflict = ifelse(speciesid %in% n.conflict$speciesid,
                                                      "conflict",
                                                      NA))
  
  # Flag conflicts across new species codes and existing species codes
  missings3 <- missings %>% mutate(conflict = ifelse(speciesid %in% gazp$speciesid,
                                                     "conflict",
                                                     NA))
  # combine conflicts into one column
  missings <-  missings2 %>% left_join (missings3, by=c("Code","old_name","name","speciesid","infra","morphotype")) %>%
    mutate(conflict =
             ifelse(!is.na(conflict.x),
                    conflict.x,
                    conflict.y)) %>%
    select(-conflict.x,-conflict.y)
  
  # Return full matrix
  return(missings)

}

##################### Functions to extract traits
#### Seed mass
seed_mass <- function(names_list, seed) {
  seed_match <- seed[seed$tpl_name %in% names_list$name, ]
  
  if(nrow(seed_match) == 0) 
    seed_match <- seed[seed$original_name %in% names_list, ]
  
  if(nrow(seed_match) == 0 & !is.na(names_list$infra_name[i])) 
    seed_match <- seed[seed$tpl_genus == names_list$genus[i] &
                         seed$tpl_epithet == names_list$species[i],]
  
  if(nrow(seed_match) == 0) {
    seed_out <- NA
  } else {
    seed_out <- mean(seed_match$weight_g)
  }
  
  return(seed_out)
  
}

#### Photosynthetic pathway
photosynthesis <- function(names_list, photo) {
  photo_match <- photo[photo$genus %in% names_list$genus &
                         photo$species %in% names_list$species,]
  
  if(nrow(photo_match) == 0) {
    photo_out <- NA
  } else {
    
    if(nrow(photo_match) == 1) 
      photo_out <- photo_match$photo
    
    if(nrow(photo_match) > 1) {
      

  if(length(unique(photo_match$photo)) == 1) {
    photo_out <- unique(photo_match$photo)
  } else {
    photo_out <- str_c(unique(photo_match$photo),
                       collapse = "/")
    }
   }
  }
  return(photo_out)
  
}

#### Raunkiaer lifeform
raunk <- function(names_list, form) {
  form_match <- form[form$genus %in% names_list$genus &
                       form$species %in% names_list$species,]
  
  if(nrow(form_match) == 0) {
    raunk_out <- NA
  } else {
    
    if(nrow(form_match) == 1) 
      raunk_out <- form_match$life
    
    if(nrow(form_match) > 1) {
      
  if(length(unique(form_match$life)) == 1) {
    raunk_out <- unique(form_match$life)
  } else {
    raunk_out <- str_c(unique(form_match$life),
                      collapse = "/")
    }
  }
 }
  return(raunk_out)
  
}

#### Woodiness
woodiness <- function(names_list, wood) {
  wood_match <- wood[wood$genus %in% names_list$genus &
                       wood$species %in% names_list$species,]
  
  if(nrow(wood_match) == 0) {
    wood_out <- NA
  } else {
    
    if(nrow(wood_match) == 1) 
      wood_out <- wood_match$wood
    
    if(nrow(wood_match) > 1) {
      
      if(length(unique(wood_match$wood)) == 1) {
        wood_out <- unique(wood_match$wood)
      } else {
        wood_out <- "semi-woody"
      }
    }
  }
  
  return(wood_out)
  
}

#### Nitrogen fixation
n_fixing <- function(names_list, nfix) {
  nfix_match <- nfix[nfix$genus %in% names_list$genus &
                       nfix$species %in% names_list$species,]
  
  if(nrow(nfix_match) == 0) {
    nfix_out <- NA
  } else {
    
    if(nrow(nfix_match) == 1) 
      nfix_out <- nfix_match$nfix
    
    if(nrow(nfix_match) > 1) {
      
      if(length(unique(nfix_match$life)) == 1) {
        nfix_out <- unique(nfix_match$nfix)
      } else {
        nfix_out <- "possible"
      }
    }
  }
  
  return(nfix_out)
  
}

#### Lifespan
span_group <- function(names_list, span) {
  span_match <- span[span$genus %in% names_list$genus &
                       span$species %in% names_list$species,]
  
  if(nrow(span_match) == 0) {
    span_out <- NA
  } else {
    
    if(nrow(span_match) == 1) 
      span_out <- span_match$span
    
    if(nrow(span_match) > 1) {
      
      if(length(unique(span_match$life)) == 1) {
        span_out <- unique(span_match$span)
      } else {
        span_out <- str_c(unique(span_match$span), 
                          collapse = "/")
      }
    }
  }
  
  return(span_out)
  
}

