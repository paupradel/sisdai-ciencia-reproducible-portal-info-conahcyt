# Carga de bibliotecas
pacman::p_load(readr, dplyr, jsonlite, scales, tidyr, glue, purrr)

## Lectura de datos '''---------------------------------------------------------
datos_cp <- read_csv("datos/datos-procesados/datos_ramo38.csv")

## Auxiliares ------------------------------------------------------------------
colores <- c(
  "total" = "#FFFFFF",
  "becas" = "#131347",
  "snii" = "#5979A1",
  "fomento" = "#CDF0CE",
  "pronaces" = "#CDF0CE",
  "admin" = "#AB57FF",
  "cp" = "#18B584",
  "resto" = "#FFFFFF"
)

representan <- c(
  "Total" = "Total",
  "Becas" = "Becas",
  "SNII"= "Sistema Nacional de Investigadoras e Investigadores",
  "Promoción y fomento" = "Promoción y Fomento",
  "Pronaces" = "Programas Nacionales Estratégicos",
  "Admin" = "Administrativo",
  "CP" = "Centros Públicos",
  "Resto" = "Resto"
)

guia <- tibble(
  id = names(colores), 
  nombre = names(representan),
  descripcion = representan,
  color = colores,
  orden = 0:7
)

## Agrupacion de datos ---------------------------------------------------------
anuales <-
  datos_cp |> 
  mutate(
    monto_final = case_when(
      # variable para unificar el monto ejercido
      monto_ejercido > 0 ~ monto_ejercido,
      monto_devengado > 0 ~ monto_devengado,
      T ~ monto_ejercicio
    ),
    id = case_when(
      desc_ur != "Consejo Nacional de Ciencia y Tecnología"  ~ "cp",
      mod_pp %in% c("F-001", "F-002", "U-003", "S-192", "S-225",
                    "S-236", "S-278", "U-004") ~ "fomento",
      mod_pp == "F-003" ~ "pronaces",
      mod_pp %in% c("S-190", "U-002") ~ "becas",
      mod_pp == "S-191" ~ "snii",
      TRUE ~ "admin"
    ),
  ) |> 
  group_by(ciclo, id) |> 
  summarise(
    monto_ejercido = sum(monto_final, na.rm = T),
  ) |> 
  mutate(
    porcentaje = monto_ejercido / sum(monto_ejercido)
  ) |> 
  ungroup() |> 
  filter(monto_ejercido > 0)

total <- 
  anuales |> 
  group_by(ciclo) |> 
  summarise(monto_ejercido = sum(monto_ejercido)) |> 
  mutate(
    id = "total", 
    porcentaje = 1,
    cs = 0) |> 
  left_join(guia)

## transformaciones para json
tmp <-
  anuales |>
  left_join(guia) |> 
  arrange(ciclo, orden) |> 
  group_by(ciclo) |> 
  mutate(
    cs = cumsum(monto_ejercido),
  ) |> 
  bind_rows(total) |> 
  arrange(ciclo, orden) |> 
  mutate(
    resto = max(monto_ejercido) - cs
  ) |> 
  ungroup() 

rst <-   
  tmp |> 
  select(ciclo, monto_ejercido = resto) |> 
  mutate(orden = max(guia$orden)) |> 
  left_join(guia) |> 
  mutate(
    orden = tmp$orden  
    )

tmp2 <- 
  tmp |> 
  # filter(orden != 0) |> 
  filter(orden != max(guia$orden)) |> 
  arrange(ciclo, orden) |> 
  select(-c(cs, resto)) 

lista_final <- list()
lista_datos <- list()

# El json se genera a partir de listas anidadas
for(a in unique(tmp2$ciclo)){
  t <- tmp2 |> filter(ciclo == a) 
  r <- rst |> filter(ciclo == a) 
  
  n <- 1
  
  for(i in r$orden) {
    
    dat <- 
      bind_rows(
        t |> 
          filter(orden <= i),
        r |> 
          filter(orden == i) |> 
          mutate(orden = max(guia$orden))
      ) |> 
      arrange(orden) |> 
      filter(orden != 0)
    
    
    if (i == max(guia$orden)) {
      b1 <- dat
    } else if (i == 0) {
      b1 <- dat
      b1$orden[b1$id == "resto"] <- 0
    } else {
      b1 <- dat |> filter(orden != max(guia$orden))
    }
    
    b <- 
      b1 |> 
      filter(orden == max(orden)) |> 
      mutate(
        bullet = case_when(
          # 0 el total
          i == 0 ~ glue('En {ciclo}, el Gobierno de México ejerció {number(monto_ejercido, 
                       scale = .000001, big.mark = ",")} millones de pesos (MDP) a través del ramo 38 denominado "Consejo Nacional de Ciencia y Tecnología"'),
          
          # 1 es becas
          i == 1 ~ glue("de esta cifra, el Consejo Nacional destinó el {percent(porcentaje, accuracy = .1)} ({number(monto_ejercido,  
                       scale = .000001, big.mark = ',')} MDP)  a {(descripcion)}"),
          # 2 es snii
          i == 2 ~ glue("el {percent(porcentaje, accuracy = .1)} ({number(monto_ejercido, 
                       scale = .000001, big.mark = ',')} MDP) al {(descripcion)} ({nombre})"),
          
          # 3 es promocion y fomento 
          i == 3 ~ glue("un {percent(porcentaje, accuracy = .1)} ({number(monto_ejercido, 
                       scale = .000001, big.mark = ',')} MDP) a {(descripcion)}"),
          # 4 pronaces
          i == 4 ~ glue("un {percent(porcentaje, accuracy = .1)} ({number(monto_ejercido, 
                       scale = .000001, big.mark = ',')} MDP) a los {(descripcion)} ({nombre})"),
          
          # El resto (5) administrativo
          i == 5 ~ glue("y otro {percent(porcentaje, accuracy = .1)} ({number(monto_ejercido, 
                       scale = .000001, big.mark = ',')} MDP) a temas de corte Administrativo."),
          # 6 es cp
          i == 6 ~ glue("Finalmente el {percent(porcentaje, accuracy = .1)} ({number(monto_ejercido, 
                       scale = .000001, big.mark = ',')} MDP) del ramo 38 fue ejercido desde los {(descripcion)} ({nombre}).")
          
        )
      ) |> pull(bullet) 
    
    lista_salida <- list(
      bullet = b, 
      datos = dat |> select(id, monto_ejercido),
      variables = dat |> select(id, color, nombre)
    )
    lista_datos[[n]] <- lista_salida 
    n <- n + 1
  }
  
  lista_final <- append(lista_final, list(lista_datos))
}

names(lista_final) <- as.character(unique(tmp2$ciclo))


## Guardar salida '''''---------------------------------------------------------
write_json(lista_final, "datos/datos-procesados/datos_narrativa_presupuesto.json",
           encoding = "latin1", pretty = T, auto_unbox = T)
