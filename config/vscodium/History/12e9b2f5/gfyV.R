#renv::activate()
#renv::snapshot()
library(here)
library(tidyverse)
library(readxl)



# CARGAR BASE DE DATOS

bd_original <- read_excel( 
                           here("bd_julieth.xlsx"),
                           sheet = "datos_1",
                           range = "A1:k34" 
                          )[, c(1, 2, 11)]
