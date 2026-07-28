# renv::activate()
# renv::snapshot()

library(here)
library(tidyverse)
library(readxl)
library(vegan)


rm(list = ls())
# ==========================
# Cargar base de datos
# ==========================

bd_original <- read_excel(
  here("bd_julieth.xlsx"),
  sheet = "datos_1",
  range = "A1:K34"
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

# vegan utiliza muestras en filas

matriz_muestreos <- t(matriz_familias)

# ==========================
# Curva de acumulación
# ==========================

curva <- specaccum(
  matriz_muestreos,
  method = "random",
  permutations = 1000
)

curva_bd <- tibble(
  muestreos = curva$sites,
  riqueza = curva$richness,
  sd = curva$sd
)

grafica_acumulacion <- ggplot(
  curva_bd,
  aes(muestreos, riqueza)
) +

  geom_ribbon(
    aes(
      ymin = riqueza - sd,
      ymax = riqueza + sd
    ),
    fill = "#4F9D69",
    alpha = 0.20
  ) +

  geom_line(
    colour = "#4F9D69",
    linewidth = 1.2
  ) +

  geom_point(
    colour = "#4F9D69",
    size = 3
  ) +

  scale_x_continuous(
    breaks = curva_bd$muestreos
  ) +

  labs(
    x = "Número de muestreos",
    y = "Riqueza acumulada de familias"
  ) +

  theme_classic(base_size = 12) +

  theme(
    axis.title = element_text(face = "bold")
  )

grafica_acumulacion

ggsave(
  here("figuras", "curva_acumulacion.png"),
  grafica_acumulacion,
  width = 11,
  height = 7,
  dpi = 1000
)

# ==========================
# Heatmap
# ==========================

orden_familias <- bd_original |>
  group_by(Familia) |>
  summarise(
    total = sum(TOTAL),
    .groups = "drop"
  ) |>
  arrange(desc(total))

heatmap_bd <- bd_original |>
  group_by(Muestreo) |>
  mutate(
    abundancia_relativa = TOTAL / sum(TOTAL)
  ) |>
  ungroup() |>
  mutate(
    Familia = factor(
      Familia,
      levels = rev(orden_familias$Familia)
    )
  )

grafica_heatmap <- ggplot(
  heatmap_bd,
  aes(
    factor(Muestreo),
    Familia,
    fill = abundancia_relativa
  )
) +

  geom_tile(
    colour = "white",
    linewidth = 0.3
  ) +

  scale_fill_distiller(
    palette = "Greens",
    direction = 1,
    name = "Abundancia\nrelativa"
  ) +

  labs(
    x = "Muestreo",
    y = "Familia"
  ) +

  theme_classic(base_size = 12) +

  theme(
    axis.title = element_text(face = "bold"),
    axis.text.y = element_text(face = "italic")
  )

grafica_heatmap

ggsave(
  here("figuras", "heatmap_familias.png"),
  grafica_heatmap,
  width = 10,
  height = 7,
  dpi = 1000
)

# ==========================
# Números de Hill
# ==========================

vector_familias <- rowSums(matriz_familias)

hill_number <- function(abund, q){

  abund <- abund[abund > 0]

  p <- abund / sum(abund)

  if(abs(q - 1) < 1e-8){

    return(
      exp(
        -sum(p * log(p))
      )
    )

  }

  (sum(p^q))^(1 / (1 - q))

}

orden_q <- seq(
  0,
  2,
  by = 0.05
)

perfil_hill <- tibble(
  q = orden_q,
  diversidad = sapply(
    orden_q,
    hill_number,
    abund = vector_familias
  )
)

grafica_hill <- ggplot(
  perfil_hill,
  aes(q, diversidad)
) +

  geom_line(
    colour = "#4F9D69",
    linewidth = 1.2
  ) +

  geom_point(
    data = subset(
      perfil_hill,
      q %in% c(0,1,2)
    ),
    colour = "#4F9D69",
    size = 3
  ) +

  scale_x_continuous(
    breaks = c(0,1,2),
    labels = c(
      "q = 0",
      "q = 1",
      "q = 2"
    )
  ) +

  labs(
    x = "Orden de diversidad (q)",
    y = "Diversidad efectiva (números de Hill)"
  ) +

  theme_classic(base_size = 12) +

  theme(
    axis.title = element_text(face = "bold")
  )

grafica_hill

ggsave(
  here("figuras", "numeros_hill.png"),
  grafica_hill,
  width = 11,
  height = 7,
  dpi = 1000
)
