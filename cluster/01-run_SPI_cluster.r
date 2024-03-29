library(sf)
source("scr/01-run_SPI_computation.r")

# Get array number from command line
# rm(list = ls())
ARRAY_ID <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))

#------------------------------------------------------------------------------
# 0. PARAMS
#------------------------------------------------------------------------------
PROTECTED_AREA_TYPE = "" # Types of protected areas to consider (unique(aires_prot$DESIG_GR))
SPLIT = TRUE # Split computations into total, south and north regions
UNION = TRUE # Union of protected areas ?
YEARS_LIST <- c(1876, 1900, 1919, 1925, 1927, 1931, 1937, 1938, 1941, 1955, 1960, 1970, 1972, 1976, 1977, 1978, 1979, 1980, 1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023)
SPECIES_LIST <- c("Anaxyrus americanus", "Lithobates sylvaticus", "Lithobates palustris", "Lithobates septentrionalis", "Lithobates pipiens",
    "Lithobates clamitans", "Necturus maculosus", "Lithobates catesbeianus", "Pseudacris crucifer", "Pseudacris maculata", "Pseudacris triseriata",
    "Hyla versicolor", "Eurycea bislineata", "Ambystoma laterale", "Hemidactylium scutatum", "Plethodon cinereus", "Ambystoma maculatum", 
    "Desmognathus ochrophaeus", "Desmognathus fuscus", "Notophthalmus viridescens", "Gyrinophilus porphyriticus", "Mustela frenata", 
    "Mustela nivalis", "Ovibos moschatus", "Synaptomys borealis", "Synaptomys cooperi", "Myodes gapperi", "Microtus pennsylvanicus", 
    "Microtus chrotorrhinus", "Microtus pinetorum", "Gulo gulo", "Rangifer tarandus caribou", "Castor canadensis", "Odocoileus virginianus", 
    "Lasionycteris noctivagans", "Lasiurus cinereus", "Myotis septentrionalis", "Myotis leibii", "Lasiurus borealis", "Condylura cristata", 
    "Canis latrans", "Sciurus carolinensis", "Tamiasciurus hudsonicus", "Glaucomys sabrinus", "Eptesicus fuscus", "Blarina brevicauda", 
    "Mustela erminea", "Sylvilagus floridanus", "Dicrostonyx hudsonius", "Lepus arcticus", "Lepus americanus", "Canis lupus", "Lontra canadensis",
    "Lynx canadensis", "Lyn rufus", "Marmota monax", "Martes americana", "Mephiti mephitis", "Sorex arcticus", "Sorex cinereus", "Sorex gaspensis",
    "Sorex fumeus", "Sorex dispar", "Sorex palustris", "Sorex hoyi", "Didelphis virginiana", "Ursus maritimus", "Ursus americanus", 
    "Martes pennanti", "Glaucomys volans", "Myotis lucifugus", "Phenacomys ungava", "Perimyotis subflavus", "Erethizon dorsatum", 
    "Ondatra zibethicus", "Rattus norvegicus", "Procyon lotor", "Vulpes lagopus", "Urocyon cinereoargenteus", "Vulpes vulpes", 
    "Peromyscus leucopus", "Mus musculus", "Napaeozapus insignis", "Zapus hudsonius", "Peromyscus maniculatus", "Neotamias minimus", 
    "Tamias striatus", "Parascalops breweri", "Neovison vison", "Alces americanus", "Acipenser fulvescens", "Acipenser oxyrinchus", 
    "Alosa aestivalis", "Alosa pseudoharengus", "Alosa sapidissima", "Amia calva", "Ameiurus natalis", "Ameiurus nebulosus", 
    "Ammocrypta pellucida", "Ambloplites rupestris", "Anguilla rostrata", "Aplodinotus grunniens", "Apeltes quadracus", "Carassius auratus", 
    "Catostomus catostomus", "Catostomus commersonii", "Carpiodes cyprinus", "Coregonus artedi", "Cottus bairdii", "Coregonus clupeaformis", 
    "Cottus cognatus", "Couesius plumbeus", "Cottus ricei", "Ctenopharyngodon idella", "Culaea inconstans", "Cyprinus carpio", 
    "Cyprinella spiloptera", "Dorosoma cepedianum", "Esox americanus americanus", "Esox americanus vermiculatus", "Esox lucius", 
    "Esox masquinongy", "Esox niger", "Etheostoma exile", "Etheostoma flabellare", "Etheostoma nigrum", "Etheostoma olmstedi", 
    "Exoglossum maxillingua", "Fundulus diaphanus", "Fundulus heteroclitus", "Gasterosteus aculeatus", "Gasterosteus wheatlandi", 
    "Hiodon alosoides", "Hiodon tergisus", "Hybognathus hankinsoni", "Hybognathus regius", "Ichthyomyzon castaneus", "Ichthyomyzon fossor",
    "Ictalurus punctatus", "Ichthyomyzon unicuspis", "Lethenteron appendix", "Labidesthes sicculus", "Lepomis cyanellus", "Lepomis gibbosus", 
    "Lepomis macrochirus", "Lepomis peltastes", "Lepisosteus osseus", "Lota lota", "Luxilus cornutus", "Margariscus margarita", 
    "Micropterus salmoides", "Microgadus tomcod", "Morone americana", "Moxostoma anisurum", "Moxostoma carinatum", "Morone chrysops", 
    "Moxostoma hubbsi", "Moxostoma macrolepidotum", "Moxostoma valenciennesi", "Myoxocephalus thompsonii", "Neogobius melanostomus", 
    "Notropis atherinoides", "Notropis bifrenatus", "Notemigonus crysoleucas", "Noturus flavus", "Noturus gyrinus", "Notropis heterodon", 
    "Notropis heterolepis", "Notropis hudsonius", "Noturus insignis", "Notropis rubellus", "Notropis stramineus", "Notropis volucellus", 
    "Oncorhynchus clarkii", "Oncorhynchus kisutch", "Oncorhynchus mykiss", "Oncorhynchus nerka", "Oncorhynchus tshawytscha", "Osmerus mordax", 
    "Percina caprodes", "Percina copelandi", "Perca flavescens", "Petromyzon marinus", "Percopsis omiscomaycus", "Chrosomus eos", 
    "Chrosomus neogaeus", "Pimephales notatus", "Pimephales promelas", "Pomoxis nigromaculatus", "Pungitius pungitius", "Rhinichthys atratulus", 
    "Rhinichthys cataractae", "Salvelinus alpinus", "Sander canadensis", "Salvelinus fontinalis", "Salvelinus namaycush", "Salmo trutta", 
    "Sander vitreus", "Scardinius erythrophthalmus", "Semotilus atromaculatus", "Semotilus corporalis", "Tinca tinca", 
    "Myoxocephalus quadricornis", "Umbra limi", "Micropterus dolomieu", "Morone saxatilis", "Prosopium cylindraceum", "Salmo salar", 
    "Diadophis punctatus", "Storeria occipitomaculata", "Storeria dekayi", "Nerodia sipedon", "Thamnophis sauritus", "Thamnophis sirtalis", 
    "Lampropeltis triangulum", "Liochlorophis vernalis", "Apalone spinifera", "Glyptemys insculpta", "Graptemys geographica", 
    "Dermochelys coriacea", "Emydoidea blandingii", "Sternotherus odoratus", "Chrysemys picta", "Clemmys guttata", "Chelydra serpentina")

#------------------------------------------------------------------------------
# 1. Select species and years
#------------------------------------------------------------------------------
sp_name <- SPECIES_LIST[ARRAY_ID]


#------------------------------------------------------------------------------
# 2. Compute SPI
#------------------------------------------------------------------------------
SPI <- run_SPI_computation(sp_name, YEARS_LIST, SPLIT = TRUE, PROTECTED_AREA_TYPE, UNION)


#------------------------------------------------------------------------------
# 2. Save SPI
#------------------------------------------------------------------------------
write.csv(SPI, paste0("results/", gsub(" ", "_", sp_name), ".csv"))
