####### REPRODUCIBILIDAD #########

# renv::activate()
# renv::snapshot()
# renv::restore()
library(here)

# PAQUETES DE USUARIO

library(dplyr)
library(readr)
library(iNEXT)

BD_original <- read_delim(here("datos", "BD_guartinajas_diversidad_peces.csv"))

View(BD_original)


BD_original
