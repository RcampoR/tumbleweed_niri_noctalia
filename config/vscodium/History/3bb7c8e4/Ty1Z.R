####### REPRODUCIBILIDAD #########

# renv::activate()
# renv::snapshot()
# renv::restore()
library(here)

# PAQUETES DE USUARIO

library(tidyverse)
library(iNEXT)


BD_original <- read_delim(here("datos", "BD_guartinajas_diversidad_peces.csv"))[, -1]

# ==========================
# Preparación de los datos
# ==========================

BD_guartinajas <- BD_original %>%
  mutate(
    nombre_especie = especie
  )


# ==========================
# Matrices de comunidad
# ==========================

matriz_guartinajas <- BD_guartinajas %>%
  group_by(nombre_especie, Muestreo) %>%
  summarise(abundancia = sum(abundancia), .groups = "drop") %>%
  pivot_wider(
    names_from = Muestreo,
    values_from = abundancia,
    values_fill = 0
  ) %>%
  column_to_rownames("nombre_especie")


matriz_lago <- BD_guartinajas %>%
  filter(ambiente == "Lago") %>%
  group_by(nombre_especie, Muestreo) %>%
  summarise(abundancia = sum(abundancia), .groups = "drop") %>%
  pivot_wider(
    names_from = Muestreo,
    values_from = abundancia,
    values_fill = 0
  ) %>%
  column_to_rownames("nombre_especie")


matriz_rio <- BD_guartinajas %>%
  filter(ambiente == "rio") %>%
  group_by(nombre_especie, Muestreo) %>%
  summarise(abundancia = sum(abundancia), .groups = "drop") %>%
  pivot_wider(
    names_from = Muestreo,
    values_from = abundancia,
    values_fill = 0
  ) %>%
  column_to_rownames("nombre_especie")


# ==========================
# Vectores para iNEXT
# ==========================

vector_guartinajas <- rowSums(matriz_guartinajas)

vector_lago <- rowSums(matriz_lago)

vector_rio <- rowSums(matriz_rio)


# ==========================
# iNEXT
# ==========================

inext_guartinajas <- iNEXT(
  vector_guartinajas,
  q = c(0,1,2),
  datatype = "abundance"
)

inext_ambientes <- iNEXT(
  list(
    Lago = vector_lago,
    Río = vector_rio
  ),
  q = 0,
  datatype = "abundance"
)


# ==========================
# Figura principal
# ==========================

grafica_guartinajas <- ggiNEXT(
  inext_guartinajas,
  type = 1
) +
  scale_color_manual(values = "#4F9D69") +
  scale_fill_manual(values = "#4F9D69") +
  labs(
    x = "Número de individuos",
    y = "Riqueza de especies"
  ) +
  theme_classic(base_size = 12) +
  theme(
    axis.title = element_text(face = "bold"),
    legend.position = "none"
  )

grafica_guartinajas


# ==========================
# Figura exploratoria
# ==========================

punto_corte <- min(
  sum(vector_lago),
  sum(vector_rio)
)

grafica_lago_rio <- ggiNEXT(
  inext_ambientes,
  type = 1
) +
  scale_color_manual(
    values = c(
      "Lago" = "#6DB388",
      "Río" = "#6E9FD4"
    )
  ) +
  scale_fill_manual(
    values = c(
      "Lago" = "#6DB388",
      "Río" = "#6E9FD4"
    )
  ) +
  geom_vline(
    xintercept = punto_corte,
    linetype = 2,
    linewidth = 0.7,
    colour = "grey40"
  ) +
  labs(
    x = "Número de individuos",
    y = "Riqueza de especies",
    colour = "Ambiente",
    fill = "Ambiente"
  ) +
  theme_classic(base_size = 12) +
  theme(
    axis.title = element_text(face = "bold")
  )

grafica_lago_rio


# GUARDAR

ggsave(
  filename = here("figuras", "curva_acumulacion_guartinajas.png"),
  plot = grafica_guartinajas,
  width = 11,
  height = 7,
  dpi = 1000
)



ggsave(
  filename = here("figuras", "curva_lago_rio.png"),
  plot = grafica_lago_rio,
  width = 11,
  height = 7,
  dpi = 1000
)



# NUMEROS DE HILL
hill_number <- function(abund, q){

  abund <- abund[abund > 0]
  p <- abund / sum(abund)

  if(abs(q - 1) < 1e-8){
    return(exp(-sum(p * log(p))))
  }

  (sum(p^q))^(1 / (1 - q))
}


orden_q <- seq(0, 2, by = 0.05)

perfil_hill_guartinajas <- tibble(
  q = orden_q,
  diversidad = sapply(orden_q, hill_number, abund = vector_guartinajas)
)

ggplot(perfil_hill_guartinajas,
       aes(q, diversidad)) +

  geom_line(
    linewidth = 1.2,
    colour = "#4F9D69"
  ) +

  geom_point(
    data = subset(perfil_hill_guartinajas,
                  q %in% c(0,1,2)),
    size = 3,
    colour = "#4F9D69"
  ) +

  scale_x_continuous(
    breaks = c(0,1,2),
    labels = c("q = 0","q = 1","q = 2")
  ) +

  labs(
    x = "Orden de diversidad (q)",
    y = "Diversidad efectiva (números de Hill)"
  ) +

  theme_classic(base_size = 13) +

  theme(
    axis.title = element_text(face = "bold")
  )

ggsave(
    here("figuras", "diversidad_verdadera.png"),
    dpi = 1000,
    height = 7,
    width = 11
)
