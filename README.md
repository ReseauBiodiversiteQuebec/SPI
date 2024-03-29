# Computation of the SPI indicator for Québec

The SPI biodiversity indicator measures the protected species distribution. It is computed as the ratio of the protected species distribution area to the total area of the species distribution. 


## Methodology

The method rests on species distribution maps and their overlap with protected areas.

Jetz, W., McGowan, J., Rinnan, D.S. et al. Include biodiversity representation indicators in area-based conservation targets. Nat Ecol Evol 6, 123–126 (2022). https://doi.org/10.1038/s41559-021-01620-y

## Data

All data needed for the analyses are available in the `data_raw` folder.

### Range Maps

The range maps were obtained from [donneesquebec](https://www.donneesquebec.ca/recherche/dataset/aires-de-repartition-faune) web portal and were downloaded on November 13th, 2023. These range maps were produced by the MELCCFP and were last updated on 2023-09-11. These range maps are available in the `data_raw` folder where each `.gpkg` file is named after a species group with 8 fields :

- DESC_ENTIT : Signification de l’entité géographique
- GRAND_GROUPE : Classification taxonomique
- PRODUCTEUR : Ministère producteur des données
- NOM_FRANCA : Nom français officiel de l’espèce utilisé au Québec
- NOM_ANGLA : Nom anglais de l’espèce
- NOM_SCIENT : Nom scientifique de l’espèce
- FAMILLE : Famille de l'espèce dans le système de classification
- DATE_MAJ : Année de mise à jour des données

### CDPNQ occurences

Occurences were downloaded from the [donneesquebec](https://www.donneesquebec.ca/recherche/dataset/occurrences-especes-en-situation-precaire) web portal on December 06, 2023 and was last updated on 2023-11-30. Downloaded data is available in the `data_raw` folder as `emvs_dq.gpkg`. 

Metadata for the occurences dataset is available in the `data_raw` folder as `metadonnees_cdpnq.xlsx`.

### Protected Areas

The protected areas were downloaded from the [donneesquebec](https://www.donneesquebec.ca/recherche/dataset/aires-protegees-au-quebec) web portal on November 13, 2023 and were last updated on 2023-11-03. Downloaded data are available in the `data_raw` folder. Only the 'Aires protégées du registre' layer was used and **no distinction is made between the different types of protected areas**.

### Data treatment

Protected areas dataset contains multiple types of protected areas that may overlap. Overlap would duplicate the protected area and bias the SPI computation. To remove overlap between the different protected areas, the `st_union` function from the `sf` package was used to union overlapping polygons. The resulting layer is available in the `data` folder as `aires_union.gpkg`.



## Run computations

**1. Prepare data**

Data preparation is done with the `00-prep_data.r` script.

```r
source("scr/00-prep_data.r")
```

This script will :

- Combine range maps for each species group into a single layer
- Split range maps into North and South regions
- Union overlapping protected areas
- Split protected areas into North and South regions

The resulting layers are saved in the `data_clean` folder.

**2. Run computations**

Computations may be ran from a personal computer with the `run_SPI_computation` function.

```r
source("scr/01-run_SPI_computation.r")

SPECIES = "Anaxyrus americanus" # Species analyzed
YEAR = 1990 # Years of creation of protected areas of interest (all years before this year will also be considered)
SPLIT = FALSE # Compute for North and South regions in addition to the whole province
PROTECTED_AREA_TYPE = c("Parc national du Québec") # Types of protected areas to consider (unique(aires_prot$DESIG_GR))
UNION = FALSE # Union all protected areas ?

run_SPI_computation(SPECIES, YEAR, SPLIT, PROTECTED_AREA_TYPE, UNION = FALSE)
```

Alternatively, computations may be ran using clusters with the `start.sh` script in the `cluster` folder.


## Access results

When ran on clusters, yearly SPI values per species are saved in dataframe `results/SPI.csv`.

Results are also saved in csv files per species in the `results` folder. They may be assembled as a single dataframe using the `cluster/02-combine_results.r`.

```r
# Combine results
source("cluster/02-combine_results.r")
```

The dataframe will be saved as `results/SPI_ranges.csv`.

```r
# View results
source("scr/utils-visualisation.r")
SPI <- read.csv("results/SPI_ranges.csv")

# Remove species with no name
SPI <- SPI[SPI$SPECIES != "Information masquée",]

plot_SPI_time_series() # Time series of SPI values by species
plot_SPI_scores() # Histogram of SPI scores for a given year
plot_SPI_by_group() # Time series of SPI values devided by species groups
# plot_SPI_at_risk() # Time series of SPI values for species at risk
plot_SPI_regions() # Time series of SPI values for south and north regions

# png("results/figures/RANGES_SPI_regions.png", width = 3000, height = 2000, res = 300, bg = "transparent")
# plot_SPI_regions()
# dev.off()

# png("results/figures/RANGES_SPI_by_group.png", width = 3000, height = 2000, res = 300, bg = "transparent")
# plot_SPI_by_group()
# dev.off()

# png("results/figures/RANGES_SPI_scores.png", width = 3000, height = 2000, res = 300, bg = "transparent")
# plot_SPI_scores()
# dev.off()
```

