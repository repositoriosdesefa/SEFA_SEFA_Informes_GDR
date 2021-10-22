#########################################################
#### GENERAR REPORTES PARA CADA ESPECIALISTA SINADA #####
#########################################################

# I. LIBRERIAS A UTILIZAR----

library(googledrive)
library(googlesheets4)
library(writexl) 
library(xlsx)
library(readxl)
library(dplyr)


# II. IDENTIFICARSE----

correo_usuario <- "" # Correo especialista
drive_auth(email = correo_usuario) 
gs4_auth(token = drive_auth(email = correo_usuario), 
         email = correo_usuario)

# III. DESCARGANDO INFORMACION DE BASE DE DATOS----

BD_SINADA2 <- ""
BD_REG <- ""
BD_RPTA <- ""
CALCULADORA <- ""

TAREAS_SINADA2 <- read_sheet(BD_SINADA2, sheet = "Matriz trabajo")
METAS_SINADA2 <- read_sheet(BD_SINADA2, sheet = "Metas")
DIAS_LABORADOS_SINADA2 <- read_sheet(BD_SINADA2, sheet = "DIAS_LABORADOS")
PARAMETROS_FERIADOS <- read_sheet(BD_SINADA2, sheet = "PARAMETROS")

TAREAS_REGISTRO_SINADA1 <- read_sheet(BD_REG, sheet = "Consolidado")
METAS_REGISTRO_SINADA1 <- read_sheet(BD_REG, sheet = "Metas")
DIAS_LABORADOS_REGISTRO_SINADA1 <- read_sheet(BD_REG, sheet = "DIAS_LABORADOS")

TAREAS_RPTA_SINADA1 <- read_sheet(BD_RPTA, sheet = "E.respuestas_1")
METAS_RPTA_SINADA1 <- read_sheet(BD_RPTA, sheet = "Metas")
DIAS_LABORADOS_RPTA_SINADA1 <- read_sheet(BD_RPTA, sheet = "DIAS_LABORADOS")
PARAMETROS_SINADA1 <- read_sheet(BD_RPTA, sheet = "PARAMETROS")
CALCULADORABD_SINADA1 <- read_sheet(CALCULADORA, sheet = "Calculadora")
POI_SINADA1 <- read_sheet(BD_RPTA, sheet = "POI")

# IV. TRANSFORMANDO INFORMACION DE LA DATA----

TAREAS_SINADA2 <- select(
  TAREAS_SINADA2,
  DENUNCIA = 'CODIGO SINADA',
  HTCORREO_INGRESADO = 'HT RECEPCIONADA EN SINADA',
  ESPECIALISTA = 'Nombre completo',
  PRODUCTO_ACCION = 'TAREA PRINCIPAL',
  FECHA_ACCION = 'FECHA DEL DOC EN SIGED / FECHA DE ACCION',
  FECHA_ACCION1 = 'FECHA APROBACION',
  HOJA_TRAMITE_PRODUCTO = 'HT DEL DOCUMENTO SALIDA',
  NUMERO_DOC = 'NUMERO DEL DOC',
  JEFE
)

METAS_SINADA2 <- select(
  METAS_SINADA2,
  DATOS_ACTUALES = 'MES',
  ESPECIALISTA = 'NOMBRE_COMPLETO',
  TAREAS_IDEAL_DIARIO = 'TAREA_IDEAL1',
  NOMBRE_UNICO,
  ESTADO,
  CARGO,
  DESCRIPCION_META,
  INICIO_PERIODO,
  FIN_PERIODO
)

DIAS_LABORADOS_SINADA2 <- select(
  DIAS_LABORADOS_SINADA2,
  DIAS_NO_TRABAJADOS = 'FECHA_NO_TRABAJADA',
  ESPECIALISTA
)


TAREAS_REGISTRO_SINADA1 <- select(
  TAREAS_REGISTRO_SINADA1,
  CODIGO_RECEPCION = 'C?digo web',
  MEDIO_RECEPCION = 'Tipo',
  ESPECIALISTA = 'NOMBRE COMPLETO',
  ESTADO = 'Estado de atenci?n',
  PRODUCTO_ACCION = 'Acci?n',
  FECHA_CARGA = 'Fecha de carga',
  HOJA_TRAMITE_PRODUCTO = 'Hoja de tr?mite',
  FECHA_ACCION = 'Fecha de acci?n'
)

METAS_REGISTRO_SINADA1 <- select(
  METAS_REGISTRO_SINADA1,
  DATOS_ACTUALES = 'ACTUAL',
  ESPECIALISTA = 'Nombre_completo_1',
  TAREAS_IDEAL_DIARIO = 'Metas_diario_1',
  NOMBRE_UNICO = 'Datos',
  ESTADO,
  Cargo,
  INICIO_PERIODO,
  FIN_PERIODO
)

DIAS_LABORADOS_REGISTRO_SINADA1 <- select(
  DIAS_LABORADOS_REGISTRO_SINADA1,
  DIAS_NO_TRABAJADOS = 'FECHA_NO_TRABAJADA',
  ESPECIALISTA,
  FERIADOS
)


TAREAS_RPTA_SINADA1 <- select(
  TAREAS_RPTA_SINADA1,
  DENUNCIA = 'CODIGO SINADA',
  HTCORREO_INGRESADO = 'HT',
  ESPECIALISTA = 'Nombre completo',
  PRODUCTO_ACCION = 'TAREA PRINCIPAL',
  FECHA_ACCION = 'FECHA APROBACION',
  HOJA_TRAMITE_PRODUCTO = 'HT SALIDA',
  NUMERO_DOC = 'NRO DOC',
  TAREA_GENERAL = 'Tarea general'
)

METAS_RPTA_SINADA1 <- select(
  METAS_RPTA_SINADA1,
  DATOS_ACTUALES = 'MES',
  ESPECIALISTA = 'NOMBRE_COMPLETO',
  TAREAS_IDEAL_DIARIO = 'TAREA_IDEAL_1',
  META_MENSUAL = 'META_MENSUAL_1',
  NOMBRE_UNICO,
  TAREA_REAL = 'TAREAS_FINAL',
  ESTADO
)

DIAS_LABORADOS_RPTA_SINADA1 <- select(
  DIAS_LABORADOS_RPTA_SINADA1,
  DIAS_NO_TRABAJADOS = 'FECHA_NO_TRABAJADA',
  ESPECIALISTA
)

PARAMETROS_SINADA1 <- select(
  PARAMETROS_SINADA1,
  PERIODO,
  FECHA,
  FERIADOS,
  ESPECIALISTA = 'Nombre completo',
  NOMBRE_UNICO,
  CARGO
)

CALCULADORABD_SINADA1 <- select(
  CALCULADORABD_SINADA1,
  DENUNCIA = 'CODIGO_SINADA_FINAL',
  CONFICHA = 'Ficha elaborada',
  ENVIADAS = 'Enviadas (marcar "Si" cuando se env?e la ficha)'
)

POI_SINADA1 <- select(
  POI_SINADA1,
  DENUNCIA = 'C?digo Sinada',
  ESTADO = 'Estado carta cierre',
  FECHA_CIERRE = 'FECHA FIRMA'
)

# V. GUARDANDO INFORMACION----

setwd("")
dir <- ""

carpeta = file.path(dir)

write.xlsx(TAREAS_SINADA2, 
           file = file.path(carpeta, "SINADA2_DATA.xlsx"),
           sheetName = "TAREAS")

write.xlsx(METAS_SINADA2, 
           file = file.path(carpeta, "SINADA2_DATA.xlsx"),
           sheetName = "METAS",
           append = TRUE)

write.xlsx(DIAS_LABORADOS_SINADA2, 
           file = file.path(carpeta, "SINADA2_DATA.xlsx"),
           sheetName = "NOLABORADOS",
           append = TRUE)

write_xlsx(PARAMETROS_FERIADOS, file.path(carpeta,"FERIADOS.xlsx"))

write.xlsx(TAREAS_REGISTRO_SINADA1, 
           file = file.path(carpeta, "SINADA1_REGISTRO_DATA.xlsx"),
           sheetName = "TAREAS")

write.xlsx(METAS_REGISTRO_SINADA1, 
           file = file.path(carpeta, "SINADA1_REGISTRO_DATA.xlsx"),
           sheetName = "METAS",
           append = TRUE)

write.xlsx(DIAS_LABORADOS_REGISTRO_SINADA1, 
           file = file.path(carpeta, "SINADA1_REGISTRO_DATA.xlsx"),
           sheetName = "NOLABORADOS",
           append = TRUE)

write.xlsx(TAREAS_RPTA_SINADA1, 
           file = file.path(carpeta, "SINADA1_RPTA_DATA.xlsx"),
           sheetName = "TAREAS")

write.xlsx(METAS_RPTA_SINADA1, 
           file = file.path(carpeta, "SINADA1_RPTA_DATA.xlsx"),
           sheetName = "METAS",
           append = TRUE)

write.xlsx(DIAS_LABORADOS_RPTA_SINADA1, 
           file = file.path(carpeta, "SINADA1_RPTA_DATA.xlsx"),
           sheetName = "NOLABORADOS",
           append = TRUE)

write.xlsx(PARAMETROS_SINADA1, 
           file = file.path(carpeta, "SINADA1_RPTA_DATA.xlsx"),
           sheetName = "PARAMETROS",
           append = TRUE)

write.xlsx(CALCULADORABD_SINADA1, 
           file = file.path(carpeta, "SINADA1_RPTA_DATA.xlsx"),
           sheetName = "CALCULADORA",
           append = TRUE)

write.xlsx(POI_SINADA1, 
           file = file.path(carpeta, "SINADA1_RPTA_DATA.xlsx"),
           sheetName = "POI",
           append = TRUE)

# VI. GENERACION DE REPORTES POR EQUIPOS----

### VI.1 ESPECIALISTAS EQUIPO 2 SINADA ----

### Valores que se usar?n como "par?metros" (variables) del reporte

especialista  <- c ("ELIZABETH", "ISIDRO", "LESLIE", "KAREM", "MONICA", "ANA")

#(2)
# Definir funci?n para generaci?n de reportes
for ( i in especialista ) {
  rmarkdown :: render ( "Reporte_EQRPTA2.Rmd" ,
                        params  =  list(listado=i),
                        output_file  = paste0 ("Informe-",i)
  )
}

### VI.2 ESPECIALISTAS EQUIPO 1 REGISTRO DENUNCIAS ----

### Valores que se usar?n como "par?metros" (variables) del reporte

especialista  <- c ("NATHALI", "PETER")

#(2)
# Definir funci?n para generaci?n de reportes
for ( i in especialista ) {
  rmarkdown :: render ( "Reporte_EQREG.Rmd" ,
                        params  =  list(espec=i),
                        output_file  = paste0 ("Informe-",i)
  )
}

### VI.3 ESPECIALISTAS EQUIPO 1 ATENCION RPTAS EFA ----

### Valores que se usar?n como "par?metros" (variables) del reporte

especialista  <- c ("PAUL", "INGRIT", "RAUL")

#(2)
# Definir funci?n para generaci?n de reportes
for ( i in especialista ) {
  rmarkdown :: render ( "Reporte_EQRPTA1.Rmd" ,
                        params  =  list(espec=i),
                        output_file  = paste0 ("Informe-",i)
  )
}
