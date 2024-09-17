# Carga de bibliotecas
# Si no tienes la biblioteca pacman con la primera línea de código se instala.

if (!require("pacman")) install.packages("pacman")

pacman::p_load(readr, dplyr, glue, janitor, stringr)

lista <- list()
n <- 1

# Iteracion por anio para descarga del archivo correspondiente a cada anio
# Para cada anio se prueban diferentes enlaces de descarga; cuando no se encuentra
# un enlace, el codigo arroja una advertencia
for(i in 2012:2023) {
    print(i)
    
    url <- glue('https://www.transparenciapresupuestaria.gob.mx/work/models/PTP/DatosAbiertos/BD_Cuenta_Publica/CSV/cuenta_publica_{i}_gf_ecd_epe.csv') 
    tryCatch(
        {
            tmp <- read_csv(url, locale = locale(encoding = "latin1"))
        },
        error = function(cond) {
            message(paste("La URL 1 no existe:", i))
            NA
        }
    )
    
    url <- glue('https://www.transparenciapresupuestaria.gob.mx/work/models/PTP/DatosAbiertos/BD_Cuenta_Publica/CSV/cuenta_publica_{i}_ra_ecd_epe.csv') 
    tryCatch(
        {
            tmp <- read_csv(url, locale = locale(encoding = "latin1"))
        },
        error = function(cond) {
            message(paste("La URL 2 no existe:", i))
            NA
        }
    )
    
    url <- glue('https://www.transparenciapresupuestaria.gob.mx/work/models/PTP/DatosAbiertos/BD_Cuenta_Publica/CSV/cuenta_publica_{i}_ra_ecd.csv') 
    tryCatch(
        {
            tmp <- read_csv(url, locale = locale(encoding = "latin1"))
        },
        error = function(cond) {
            message(paste("La URL 3 no existe:", i))
            NA
        }
    )
    
    url <- glue('https://www.transparenciapresupuestaria.gob.mx/work/models/PTP/DatosAbiertos/BD_Cuenta_Publica/CSV/Cuenta_Publica_{i}.csv') 
    tryCatch(
        {
            tmp <- read_csv(url, locale = locale(encoding = "latin1"))
        },
        error = function(cond) {
            message(paste("La URL 4 no existe:", i))
            NA
        }
    )
    
    tmp$anio <- i
    tmp$ID_RAMO <- as.numeric(tmp$ID_RAMO)
    
    lista[[n]] <- 
        tmp |> 
        clean_names() |> 
        filter(id_ramo == 38)
    n <- n + 1
}

# save(lista, file = "datos/datos-originales/ramo38_original.RData")

# Correccion de numeros segun columnas encontradas
corregir_num <- function(txt) {
    out <- as.numeric(gsub(",", "", txt))
    return(out)
}

# lista_respaldo <- lista
# lista <- lista_respaldo
for(n in 1:length(lista)) {
    if("id_ramo" %in% names(lista[[n]])) {
        lista[[n]]$id_ramo <- corregir_num(lista[[n]]$id_ramo)
    }
    if("id_ur" %in% names(lista[[n]])) {
        lista[[n]]$id_ur <- corregir_num(lista[[n]]$id_ur)
    }
    if("monto_devengado" %in% names(lista[[n]])) {
        lista[[n]]$monto_devengado <- corregir_num(lista[[n]]$monto_devengado)
    }
    if("monto_aprobado" %in% names(lista[[n]])) {
        lista[[n]]$monto_aprobado <- corregir_num(lista[[n]]$monto_aprobado)
    }
    if("monto_modificado" %in% names(lista[[n]])) {
        lista[[n]]$monto_modificado <- corregir_num(lista[[n]]$monto_modificado)
    }
    if("monto_pagado" %in% names(lista[[n]])) {
        lista[[n]]$monto_pagado <- corregir_num(lista[[n]]$monto_pagado)
    }
    if("adefas" %in% names(lista[[n]])) {
        lista[[n]]$adefas <- corregir_num(lista[[n]]$adefas)
    }
    if("ejercicio" %in% names(lista[[n]])) {
        lista[[n]]$ejercicio <- corregir_num(lista[[n]]$ejercicio)
    }
    if("id_clave_cartera" %in% names(lista[[n]])) {
        lista[[n]]$id_clave_cartera <- corregir_num(lista[[n]]$id_clave_cartera)
    }
}

# Creacion de base
cp <-
    bind_rows(lista) |> 
    select(ciclo:ejercicio) |> 
    mutate(mod_pp = glue("{id_modalidad}-{str_pad(id_pp, 3, pad = '0')}"))

write_csv(cp, "datos/datos-procesados/datos_ramo38.csv")

