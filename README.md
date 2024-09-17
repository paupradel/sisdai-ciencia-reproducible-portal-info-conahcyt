# Datos para "info Conahcyt"
![Estatus](https://img.shields.io/badge/Estatus-desarrollo-yellow)

En este repositorio encuentras los códigos para descargar los datos abiertos de la Cuenta Pública, procesarlos, y generar salidas para alimentar el [Portal de información Conahcyt](http://info.conahcyt.mx/), el cual fue desarrollado con las herramientas del [Sisdai](https://sisdai.conahcyt.mx/).


## Acerca de este proyecto

El Portal de información pone a disposición pública la información que sustenta los cambios más significativos que derivaron de la implementación de la nueva política de Humanidades, Ciencias, Tecnologías e Inovación (HCTI). En la Sección Presupuesto del Portal se puede visualizar en qué se ejerce el presupuesto asignado al Consejo.

Con los códigos de este repositorio puedes descargar los [datos abiertos de la Cuenta Pública](https://www.transparenciapresupuestaria.gob.mx/Datos-Abiertos) (siempre y cuando los enlaces estén activos), procesarlos para utilizar aquellos que corresponden al Ramo 38, correspondiente a las Humanidades, Ciencias, Tecnologías e Innovación y generar insumos para replicar la visualización de la Sección _Presupuesto_ del Portal. 

Adicionalmente contiene archivos en formato `quarto` para recorrer el procesamiento paso a paso y generar visualizaciones similares a las que se encuentran en el portal, todo esto utilizando el lenguaje de programación `R`.

Es importante que sepas que con realizar algunas modificaciones menores al código, podrás descargar y almacenar los datos de los otros ramos o alguno en particular.


> **_Limitación de responsabilidad_**
>
> El presente es un proyecto en construcción, por tanto el equipo del Sisdai no es responsable del uso y contenido del presente recurso, toda vez que se trata de una versión en su modalidad prueba, y no de una versión liberada al público, por lo que una vez que sea lanzada la versión final, se invita a la persona usuaria a consultarla y validar sus requisitos.

## Requerimientos
- [R (> 4.0)](https://www.r-project.org/)
- [Quarto](https://quarto.org/)  

Se recomienda instalar el IDE [Rstudio](https://www.rstudio.com/categories/rstudio-ide/), sin embargo es posible correr este proyecto con cualquier otro IDE donde la persona usuaria pueda utilizar `R`.

## Instrucciones de uso
Para ejecutar el código en este repositorio es necesario tener instalado el lenguaje de programación estadística `R`. El repositorio está ordenado de tal forma que todos los códigos se encuentran en la carpeta `procesamiento` y los datos se almacenan en la carpeta `datos`.

El primer paso es descargar los datos de la cuenta pública, lo cual se hace usando el código `01_descargar_datos.R` en caso de que se pueda realizar por que algún enlace está roto, puedes encontrar la salida de estescript en la descarga de datos de la narrativa de la sección [Presupuesto](https://info.conahcyt.mx/presupuesto/) del portal. Para generar los datos para alimentar la narrativa en el portal se utiliza el código `02_salida_json_sisdai.r` y para generar el archivo separado por comas (`csv`) para compartir datos en formato abierto se usa el código `03_datos_tabulares.R`.   

Finalmente, el código `ejemplo_narrativa.qmd` permite replicar el procesamiento de los datos y las visualizaciones que se presentan el el portal.


## Producto final
Los datos abiertos generados con el código `03_datos_tabulares.R` incluyen las siguientes variables:

| Variable         	| Definición                                      | Tipo de variable |
|------------------	|------------------------------------------------ |------------------|
| ciclo            	| Año al que corresponde el ciclo presupuestario  | Numérico         |
| mod_pp           	| Clave del programa presupuestario            | Texto            |
| desc_pp        	| Descripción del programa presupuestario      | Texto            |
| clave_agrupacion  | Clave de la agrupación utilizada en el Portal   | Texto            |
| agrupacion        | Agrupación utilizada en el Portal        	      | Texto            |
| monto_ejercido 	| Monto ejercido                                  | Numérico         | 


## Licencia


**SOFTWARE LIBRE Y ESTÁNDARES ABIERTOS**

Este proyecto se encuentra alineado al Sisdai que a su vez, parte de las disposiciones establecidas por la Coordinación de Estrategia Digital Nacional (DOF:06/09/2021) en donde se estipula que las "políticas y disposiciones tienen como objetivo fortalecer el uso del software libre y los estándares abiertos, fomentar el desarrollo de aplicaciones institucionales con utilidad pública, lograr la autonomía, soberanía e independencia tecnológicas dentro de la APF". En el artículo 63 se explicita que "cuando se trate de desarrollos basados en software libre, se respetarán las condiciones de su licenciamiento original [...]".
