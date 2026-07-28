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


# ==========================
# Matriz de comunidad
# ==========================

matriz_familias <- bd_original |>
  group_by(Familia, Muestreo) |>
  summarise(
    abundancia = sum(TOTAL),
    .groups = "drop"
  ) |>
  pivot_wider(
    names_from = Muestreo,
    values_from = abundancia,
    values_fill = 0
  ) |>
  column_to_rownames("Familia")

# ==========================
# Vector de abundancias
# ==========================

vector_familias <- rowSums(matriz_familias)

inext_familias <- iNEXT(
  vector_familias,
  q = c(0,1,2),
  datatype = "abundance"
)
