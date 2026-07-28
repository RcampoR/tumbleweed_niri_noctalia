####### REPRODUCIBILIDAD #########

# renv::activate()
# renv::snapshot()
# renv::restore()
library(here)

# PAQUETES DE USUARIO

library(dplyr)
library(readr)

BD_original <- read_delim(here("datos", "BD_guartinajas_diversidad_peces.csv"))

View(BD_original)
