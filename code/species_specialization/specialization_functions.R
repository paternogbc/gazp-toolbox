library(rgbif)
library(tidyverse)
library(raster)
library(dismo)
options(stringsAsFactors = F)

# Load data
legend <- read.csv('C:\\Users\\Nancy\\Documents\\GitHub\\gazp-toolbox\\data-sets\\specialization\\worldclim_legend.csv',
                   skip = 2)
ari <- raster("C:\\Users\\Nancy\\Documents\\GitHub\\gazp-toolbox\\data-sets\\specialization\\Aridity.tif")
elev <- raster("C:\\Users\\Nancy\\Documents\\GitHub\\gazp-toolbox\\data-sets\\specialization\\GMTED2010.tif")
slope <- terrain(elev, opt = 'slope')
r <- getData('worldclim', var = 'bio', res = 2.5)

###### Get GBIF location data
gbif_create <- function(species, genus) {
  
  key <- name_backbone(name = paste(genus, species, sep = " "))$speciesKey
  
  xy <- occ_data(taxonKey = key, limit = 200000)
  xy2 <- xy$data %>%
    mutate(sp = paste(genus, species)) %>%
    dplyr::select(-c(publishingOrgKey, networkKeys))
  
  for(j in 1:ncol(xy2)) {
    
    xy2[, j] <- unlist(xy2[, j])
    
  }
  
  return(xy2)
  
}

###### Extract WorldClim and aridity variables for occurence data
occ_clim <- function(occ_list, genus, species) {
  
  if(!("sp" %in% colnames(occ_list)))
    occ_list$sp <- paste(genus, species)
  
  occ_list <- occ_list %>%
    dplyr::select(sp, decimalLatitude, decimalLongitude)
  occ_list <- na.omit(occ_list)
  coordinates(occ_list) <- ~decimalLongitude + decimalLatitude
  
  if(nrow(occ_list) < 100) {
    
    print("Number of GBIF records less than 100")
    return(data.frame(sp = paste(genus, species),
                      variable = NA,
                      Range = NA,
                      Mean = NA,
                      SD = NA,
                      Min = NA,
                      Max = NA,
                      N = nrow(occ_list),
                      variable.name = NA))
  
    } else {
      
      # WorldClim extraction
      vals <- raster::extract(r, occ_list)
      
      clim1 <- data.frame(occ_list, vals) %>%
        dplyr::select(-optional) %>%
        gather("variable", "value", -c(sp, decimalLatitude, decimalLongitude))
      
      clim2 <- na.omit(clim1) %>%
        group_by(sp, variable) %>%
        summarize(Range = diff(range(value)),
                  Mean = mean(value),
                  SD = sd(value),
                  Min = min(value),
                  Max = max(value),
                  N = n()) %>%
        left_join(legend, by = "variable")
      
      clim_out <- clim2[order(as.numeric(gsub('[a-z]', '', clim2$variable))), ]
      
      # Aridity extraction
      arid1 <- raster::extract(ari, occ_list)
      arid1 <- na.omit(arid1)
      
      arid_out <- data.frame(sp = paste(genus, species, sep = " "),
                             variable = "bio20",
                             Range = diff(range(arid1)),
                             Mean = mean(arid1),
                             SD = sd(arid1),
                             Min = min(arid1),
                             Max = max(arid1),
                             N = length(arid1),
                             variable.name = "Aridity index")
      
      # Full output
      return(bind_rows(clim_out, arid_out))
    
  }

}

###### Extract topography variables for occurrence data
occ_topo <- function(occ_list, genus, species) {
  
  if(!("sp" %in% colnames(occ_list)))
    occ_list$sp <- paste(genus, species)
  
  occ_list <- occ_list %>%
    dplyr::select(sp, decimalLatitude, decimalLongitude)
  occ_list <- na.omit(occ_list)
  coordinates(occ_list) <- ~decimalLongitude + decimalLatitude
  
  if(nrow(occ_list) < 100) {
    
    print("Number of GBIF records less than 100")
    return(data.frame(sp = paste(genus, species),
                      variable = NA,
                      Range = NA,
                      Mean = NA,
                      SD = NA,
                      Min = NA,
                      Max = NA,
                      N = nrow(occ_list),
                      variable.name = NA))
    
  } else {
    
    # Topography extraction
    elev1 <- raster::extract(elev, occ_list)
    elev1 <- na.omit(elev1)
    slope1 <- raster::extract(slope, occ_list)
    slope1 <- na.omit(slope1)
    
    topo_out <- data.frame(sp = paste(genus, species, sep = " "),
                           variable = c("bio21", "bio22"),
                           Range = c(diff(range(elev1)),
                                     diff(range(slope1))),
                           Mean = c(mean(elev1),
                                    mean(slope1)),
                           SD = c(sd(elev1),
                                  sd(slope1)),
                           Min = c(min(elev1),
                                   min(slope1)),
                           Max = c(max(elev1),
                                   max(slope1)),
                           N = c(length(elev1),
                                 length(slope1)),
                           variable.name = c("Elevation",
                                             "Slope"))
    
    # Full output
    return(topo_out)
    
  }
  
}

