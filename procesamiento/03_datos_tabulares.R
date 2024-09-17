# Carga de bibliotecas

pacman::p_load(readr, dplyr)

# Lectura de datos
datos_cp <- read_csv("./datos/datos-procesados/datos_ramo38.csv")

# auxiliar para ajuste de nombres
guia <- tibble(
  clave_agrupacion = c("becas", "snii", "cp",
                       "fomento", "pronaces", "admin"),
  agrupacion = c("Becas", "Sistema nacional de investigadores e investigadoras",
                 "Centros públicos", "Promoción y fomento", 
                 "Pronaces", "Administrativo")
)

## Agrupacion de datos según el total del monto ejercido cada anio 
## para cada programa presupuestario

anuales <-
  datos_cp |> 
  mutate(
    monto_final = case_when(
      # variable para unificar el monto ejercido
      monto_ejercido > 0 ~ monto_ejercido,
      monto_devengado > 0 ~ monto_devengado,
      T ~ monto_ejercicio
    ),
    clave_agrupacion = case_when(
      desc_ur != "Consejo Nacional de Ciencia y Tecnología" ~ "cp",
      mod_pp %in% c("F-001", "F-002", "U-003", "S-192", "S-225",
                    "S-236", "S-278", "U-004") ~ "fomento",
      mod_pp == "F-003" ~ "pronaces",
      mod_pp %in% c("S-190", "U-002") ~ "becas",
      mod_pp == "S-191" ~ "snii",
      TRUE ~ "admin"
    ),
  ) |> 
  group_by(ciclo, clave_agrupacion, mod_pp, desc_pp) |> 
  summarise(
    monto_ejercido = sum(monto_final, na.rm = T),
    .groups = "drop"
  ) |> 
  left_join(guia) |> 
  select(ciclo, mod_pp, desc_pp, clave_agrupacion, agrupacion, monto_ejercido)

write_csv(anuales, "./datos/datos-procesados/hcti_cuenta_publica_2022.csv")
