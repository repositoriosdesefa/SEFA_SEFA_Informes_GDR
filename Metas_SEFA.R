####################################################################-
###############  Generación de entregables SEFA  ###################-
############################# By LE ################################-

################ I. Librerias, drivers y directorio ################

# I.1 Librerias e identificación ----
# i) Librerías
library(dplyr)
library(readxl)
library(xlsx)
library(rmarkdown)
library(purrr)
library(lubridate)
library(stringi)
library(googledrive)
library(googlesheets4)
library(bizdays)
# ii) Identificación
Correo_electrónico <- "" # Correo especialista
drive_auth(email = Correo_electrónico)
gs4_auth(token = drive_token())
# iii) Determinar el periodo comprendido en el informe
# Fecha actual
Mes_actual <- month(now(), label=TRUE, abbr = FALSE)
Mes_actual <- str_to_lower(Mes_actual)
# Inicio de periodo
primer_dia <- function(x) {
  as.Date(format(x, "%Y-%m-01"))
}
Inicio_mes <- primer_dia(Sys.Date())
Inicio_periodo <- Inicio_mes %m-% months(4)
Mes_inicio <- month(Inicio_periodo, label=TRUE, abbr = FALSE)
Mes_inicio <- str_to_lower(Mes_inicio)
MES_INICIO <- str_to_upper(Mes_inicio)
# Último día del periodo
ultimo_dia <- function(x) {
  as.Date(format(x, "%Y-%m-30"))
}
Fin_periodo <- ultimo_dia(Sys.Date()) %m-% months(1)
Mes_fin <- month(Fin_periodo, label=TRUE, abbr = FALSE)
Mes_fin <- str_to_lower(Mes_fin)
# Feriados
feriados_maestro <- ""

# v) Definición de calendario
feriados <- read_sheet(ss = feriados_maestro,
                       sheet = "Feriados")
cal_peru <- create.calendar("Perú/OEFA", 
                            feriados$FERIADOS, 
                            weekdays=c("saturday", "sunday"))

# I.2 Parametros y descarga de matrices ----
# Directorio donde se guaradarn los documentos generados
dir <- ""
# Metas
GDR <- ""
MODELO_RMD <- file.path(dir, "Especialista_Entregable.Rmd")

# I.3 Función de generación de documentos ----
auto_lec_rep <- function(especialista, nombre, 
                         equipo_sefa, nombre_equipo_sefa,
                         equipo_interno, puesto, 
                         m1, m2, mpropuesta, 
                         m1_logrado, m2_logrado){
  
  # i) Se eliminan carácteres especiales
  nombre_n = gsub("Ñ", "N", nombre)
  # Eliminación de tildes
  con_tilde_may <- c("Á", "É", "Í", "Ó", "Ú")
  sin_tilde_may <- c("A", "E", "I", "O", "U")
  con_tilde_min <- c("á", "é", "í", "ó", "ú")
  sin_tilde_min <- c("a", "e", "i", "o", "u")
  # Reemplazo
  nombre_f = stri_replace_all_regex(nombre_n, con_tilde_may, sin_tilde_may, vectorize = F)
  nombre_f = stri_replace_all_regex(nombre_n, con_tilde_min, sin_tilde_min, vectorize = F)
  
  # ii) Definición de ruta a pegar
  ruta <- file.path(dir, equipo_sefa)
  # Nombre de archivo
  if (is.na(equipo_interno)) {
    n_archivo = paste0(equipo_sefa, " - ", nombre_f)
  } else {
    n_archivo = paste0(equipo_sefa," - ", equipo_interno, " - ", nombre_f)
  }
  
  
  # iii) Generación de documentos
  rmarkdown::render(input = MODELO_RMD,
                    # Definimos los parámetros de la plantilla
                    params = list(ESPECIALISTA = nombre,
                                  EQUIPO = nombre_equipo_sefa,
                                  PUESTO = puesto,
                                  META_1 = m1,
                                  META_2 = m2,
                                  M_PROPUESTA = mpropuesta,
                                  M1_LOGRADO = m1_logrado,
                                  M2_LOGRADO = m2_logrado,
                                  EQ_SEFA = equipo_sefa),
                    output_file = paste0(ruta,
                                         "/",
                                         n_archivo))
  
}

# I.4 Funcion robustecida
R_auto_lec_rep <- function(especialista, nombre, 
                           equipo_sefa, nombre_equipo_sefa,
                           equipo_interno, puesto, 
                           m1, m2, mpropuesta, 
                           m1_logrado, m2_logrado){
  out = tryCatch(auto_lec_rep(especialista, nombre, 
                              equipo_sefa, nombre_equipo_sefa,
                              equipo_interno, puesto, 
                              m1, m2, mpropuesta, 
                              m1_logrado, m2_logrado),
                 error = function(e){
                   auto_lec_rep(especialista, nombre, 
                                equipo_sefa, nombre_equipo_sefa,
                                equipo_interno, puesto, 
                                m1, m2, mpropuesta, 
                                m1_logrado, m2_logrado) 
                 })
  return(out)
}

# I.4 Generación de exportables
gen_exportable <- function(especialista, nombre, 
                           equipo_sefa, equipo_interno) {
  
  # Seleccionamos la base que corresponde
  if (equipo_sefa == "SUPERVISION"){
    base_evidencia_1 = SUPER_EVIDENCIA_M1
    base_evidencia_2 = SUPER_EVIDENCIA_M2
  } else if (equipo_sefa == "OSPA" & equipo_interno == "EQUIPO 1") {
    base_evidencia_1 = OSPA_EQ1_EVIDENCIA_M1
    base_evidencia_2 = OSPA_EQ1_EVIDENCIA_M2
  } else if (equipo_sefa == "OSPA" & equipo_interno == "EQUIPO 2"){
    base_evidencia_1 = OSPA_EQ2_EVIDENCIA_M1
    base_evidencia_2 = OSPA_EQ2_EVIDENCIA_M2
  }
  
  # La base de evidencia debe tener una columna llamada especialista
  # La variable especialista contiene el nombre según la base y se usa para filtrar
  base_1_especialista <- filter(base_evidencia_1,
                                ESPECIALISTA == especialista)
  base_2_especialista <- filter(base_evidencia_2,
                                ESPECIALISTA == especialista)
  
  # Pegado de información
  carpeta = file.path(dir, equipo_sefa)
  # La variable nombre es según la tabla de URH
  if (is.na(equipo_interno)) {
    n_archivo = paste0(equipo_sefa, " - ", nombre, ".xlsx")
  } else {
    n_archivo = paste0(equipo_sefa," - ", equipo_interno, " - ", nombre, ".xlsx")
  }
  
  write.xlsx(base_1_especialista, 
             file = file.path(carpeta, n_archivo),
             sheetName = "Meta 1")
  
  write.xlsx(base_2_especialista, 
             file = file.path(carpeta, n_archivo),
             sheetName = "Meta 2",
             append = TRUE)
  
}

# I.5 Generación de exportables robustecida ----
R_gen_exportable <- function(especialista, nombre, 
                             equipo_sefa, equipo_interno){
  out = tryCatch(gen_exportable(especialista, nombre, 
                                equipo_sefa, equipo_interno),
                 error = function(e){
                   gen_exportable(especialista, nombre, 
                                  equipo_sefa, equipo_interno) 
                 })
  return(out)
}

#--------------------------------------------------------------

################ II. Descarga de información ################

# II.1 Supervisión ----
METAS_SUPER <- read_sheet(GDR, sheet = "Supervisión")
# i) Conexion de la base
SUPER_ESTADISTICA <- ""

# ii) Descarga de información de Equipo 1
SUPER_METAS <- read_sheet(SUPER_ESTADISTICA, sheet = "SISEFA")

#--------------------------------------------------------------

# II.2 OSPA ----
METAS_OSPA <- read_sheet(GDR, sheet = "Observatorio")
# i) Conexion de la base Equipo 1
OSPA_ESTADISTICAS_EQ1 <- ""

# ii) Descarga de información de Equipo 1
OSPA_E1_META_1 <- read_sheet(OSPA_ESTADISTICAS_EQ1, sheet = "ASIGNACIONES")
OSPA_E1_META_2 <- read_sheet(OSPA_ESTADISTICAS_EQ1, sheet = "METAS - Equipo 1")

# iii) Conexion de la base Equipo 2
OSPA_ESTADISTICAS_EQ2 <- ""

# iv) Descarga de información de Equipo 2
OSPA_E2_META_1 <- read_sheet(OSPA_ESTADISTICAS_EQ2, sheet = "SEGUIMIENTO")
OSPA_E2_META_2 <- read_sheet(OSPA_ESTADISTICAS_EQ2, sheet = "METAS - Equipo 2")
OSPA_E2_META_2_PROG <- read_sheet(OSPA_ESTADISTICAS_EQ2, sheet = "TOTAL_PROGRAMACIONES")

################ III. Procesamiento de datos ################

# III.1 Supervisión ----
SUPER_EVIDENCIA_M1 <- SUPER_METAS %>%
  mutate(ESPECIALISTA = RESPONSABLE_NOMBRE,
         FECHA_FIN_SUPERVISION = ymd_hms(FECHA_FIN),
         FECHA_CARGA_INFORME = ymd_hms(FECHA_INFORME_SUPERVISION)) %>%
  filter(FECHA_FIN_SUPERVISION >= Inicio_periodo, # Por fecha de asignación
         FECHA_FIN_SUPERVISION <= Fin_periodo) %>% 
  mutate(DIAS_HABILES_TRANSCURRIDOS = bizdays(FECHA_FIN_SUPERVISION, 
                                              FECHA_CARGA_INFORME, cal_peru)) %>%
  filter(DIAS_HABILES_TRANSCURRIDOS < 30) %>%
  select(CODIGO_ACTIVIDAD, CODIGO_EXPEDIENTE, ESPECIALISTA, 
         FECHA_FIN_SUPERVISION, FECHA_CARGA_INFORME, DIAS_HABILES_TRANSCURRIDOS) %>%
  arrange(FECHA_FIN_SUPERVISION)

# Tabla resumen
SUPER_M1 <- SUPER_EVIDENCIA_M1 %>%
  group_by(ESPECIALISTA) %>%
  mutate(LOGRO = case_when(DIAS_HABILES_TRANSCURRIDOS < 30 ~ 1,
                           TRUE ~ 0)) %>%
  summarize(M1_LOGRADO=mean(LOGRO))

# Meta 2
SUPER_EVIDENCIA_M2 <- SUPER_METAS %>%
  mutate(ESPECIALISTA = RESPONSABLE_NOMBRE,
         FECHA_FIN_SUPERVISION = ymd_hms(FECHA_FIN),
         FECHA_INFORME = ymd_hms(FECHA_INFORME_SUPERVISION)) %>%
  filter(FECHA_FIN_SUPERVISION >= Inicio_periodo, # Por fecha de asignación
         FECHA_FIN_SUPERVISION <= Fin_periodo,
         UNIDAD_ORGANICA == "SEFA") %>% 
  select(CODIGO_EXPEDIENTE, NRO_INFORME_SUPERVISION,
         ESPECIALISTA, FECHA_FIN_SUPERVISION, FECHA_INFORME) %>%
  arrange(FECHA_FIN_SUPERVISION)

# Tabla resumen
SUPER_M2 <- SUPER_EVIDENCIA_M2 %>%
  group_by(ESPECIALISTA) %>%
  mutate(LOGRO = case_when(!is.na(FECHA_INFORME) ~ 1,
                           TRUE ~ 0)) %>%
  summarize(M2_LOGRADO=mean(LOGRO))%>%
  select(ESPECIALISTA, M2_LOGRADO)

# Consolidado Equipo
SUPERVISION <- merge(SUPER_M1, SUPER_M2)
SUPERVISION_AUTO <- merge(SUPERVISION, METAS_SUPER)
SUPERVISION_AUTO <- SUPERVISION_AUTO %>%
  mutate(NOMBRE_EQUIPO = "Supervisión de Entidades de Fiscalización Ambiental",
         META_PROPUESTA = "100%",
         N_EQUIPO = NA) %>%
  select(ESPECIALISTA, EQUIPO_SEFA, NOMBRE_EQUIPO, N_EQUIPO, 
         NOMBRE,  PUESTO, `META 1`, `META 2`, META_PROPUESTA,
         M1_LOGRADO, M2_LOGRADO, EVALUADOR, ROL)

# Consolidado Jefe
JEFE_METAS_SUPER <- SUPERVISION_AUTO %>%
  mutate(NOMBRE = EVALUADOR) %>%
  filter(ROL != "EVALUADOR Y EVALUADO")
# Meta 1
JEFE_M1 <- JEFE_METAS_SUPER %>%
  mutate(NOMBRE_META = `META 1`,
         LOGRADO = M1_LOGRADO)  %>%
  select(NOMBRE, ESPECIALISTA, 
         NOMBRE_META, LOGRADO)
# Evidencia para jefe
JEFE_EVIDENCIA_M1 <- SUPER_EVIDENCIA_M1  %>%
  # Selecciono solo especialistas evaluados
  filter(ESPECIALISTA %in% JEFE_METAS_SUPER$ESPECIALISTA) %>%
  arrange(ESPECIALISTA)

# Meta 2
JEFE_M2 <- JEFE_METAS_SUPER %>%
  mutate(NOMBRE_META = `META 2`,
         LOGRADO = M2_LOGRADO)  %>%
  select(NOMBRE, ESPECIALISTA, 
         NOMBRE_META, LOGRADO)
# Evidencia para jefe
JEFE_EVIDENCIA_M2 <- SUPER_EVIDENCIA_M2  %>%
  # Selecciono solo especialistas evaluados
  filter(ESPECIALISTA %in% JEFE_METAS_SUPER$ESPECIALISTA) %>%
  arrange(ESPECIALISTA)

#--------------------------------------------------------------

# III.2 OSPA ----
# III.2.1 OSPA - Equipo 1 ----

# Meta 1
# Evidencia
OSPA_EQ1_EVIDENCIA_M1 <- OSPA_E1_META_1 %>%
  mutate(FECHA_ASIGNACION = ymd(`FECHA DE ASIGNACIÓN`)) %>%
  filter(FECHA_ASIGNACION >= Inicio_periodo, # Por fecha de asignación
         FECHA_ASIGNACION <= Fin_periodo,
         !is.na(`N° REGISTRO SIGED`),
         !is.na(ESPECIALISTA)) %>% 
  select(`N° REGISTRO SIGED`, `COD DE PROBLEMA`, ESPECIALISTA,
         FECHA_ASIGNACION, `FECHA DE EJECUCIÓN DE LA ACCIÓN`,
          `TIEMPO DE EJECUCIÓN`) %>%
  arrange(FECHA_ASIGNACION)
# Tabla resumen
OSPA_EQ1_M1 <- OSPA_EQ1_EVIDENCIA_M1 %>%
  group_by(ESPECIALISTA) %>%
  mutate(LOGRO = case_when(`TIEMPO DE EJECUCIÓN` <= 30 ~ 1,
                           TRUE ~ 0)) %>%
  summarize(M1_LOGRADO=mean(LOGRO))

# Meta 2
# Evidencia
OSPA_EQ1_EVIDENCIA_M2 <- OSPA_E1_META_1 %>% # Caso especial
  mutate(FECHA_ACCION = ymd(`FECHA DE EJECUCIÓN DE LA ACCIÓN`))  %>% 
  filter(FECHA_ACCION >= Inicio_periodo,
         FECHA_ACCION <= Fin_periodo,
         !is.na(`N° REGISTRO SIGED`),
         !is.na(ESPECIALISTA)) %>%
  select(`N° REGISTRO SIGED`, `COD DE PROBLEMA`, ESPECIALISTA,
         `APORTE DEL DOCUMENTO AL PROBLEMA IDENTIFICADO`, `ACCIÓN`, FECHA_ACCION) %>%
  arrange(FECHA_ACCION)
# Tabla resumen
OSPA_EQ1_M2 <- OSPA_E1_META_2 %>%
  group_by(ESPECIALISTA) %>%
  filter(INICIO_MES >= Inicio_periodo, # Por fecha de ejecución
         FIN_MES <= Fin_periodo)  %>%
  summarize(META = sum(`Meta mensual`),
            LOGRO = sum(`Acciones realizadas`)) %>%
  mutate(M2_LOGRADO = LOGRO/META) %>%
  select(ESPECIALISTA, M2_LOGRADO)

# Consolidado Equipo 1
OSPA_EQ1 <- merge(OSPA_EQ1_M1, OSPA_EQ1_M2)
OSPA_EQ1_AUTO <- merge(OSPA_EQ1, METAS_OSPA)
OSPA_EQ1_AUTO <- OSPA_EQ1_AUTO %>%
  mutate(NOMBRE_EQUIPO = "Observatorio de Solución de Problemas Ambientales",
         META_PROPUESTA = "100%") %>%
  select(ESPECIALISTA, EQUIPO_SEFA, NOMBRE_EQUIPO, N_EQUIPO, 
         NOMBRE,  PUESTO, `META 1`, `META 2`, META_PROPUESTA,
         M1_LOGRADO, M2_LOGRADO)

# III.2.2 OSPA - Equipo 2 ----

# Meta 1
# Evidencia
OSPA_EQ2_EVIDENCIA_M1 <- OSPA_E2_META_1 %>%
  mutate(ESPECIALISTA = ESPECIALISTA_ASIGNADO,
         FECHA_ULTIMO_MOV = `FECHA ULTIMO MOV_AUX`) %>%
  filter(!is.na(`DIAS TRANSCURRIDOS ULTIMO MOV_AUX`)) %>% 
  select(`N° REGISTRO SIGED (ORIGEN)`, `COD DE PROBLEMA`, ESPECIALISTA,
         FECHA_ULTIMO_MOV, `DIAS TRANSCURRIDOS ULTIMO MOV_AUX`) %>%
  arrange(FECHA_ULTIMO_MOV)
# Tabla resumen
OSPA_EQ2_M1 <- OSPA_EQ2_EVIDENCIA_M1 %>%
  group_by(ESPECIALISTA) %>%
  mutate(LOGRO = case_when(`DIAS TRANSCURRIDOS ULTIMO MOV_AUX` <= 60 ~ 1,
                           TRUE ~ 0)) %>%
  summarize(M1_LOGRADO=mean(LOGRO))

# Meta 2
# Evidencia de pedidos
OSPA_EQ2_ACCIONES <- OSPA_E2_META_1 %>%
  mutate(FECHA_ACCION = ymd(`FECHA DE VERSION FINAL DEL PROYECTO`),
         HT = `N° REGISTRO SIGED (ORIGEN)`) %>%
  filter(FECHA_ACCION  >= Inicio_periodo,
         FECHA_ACCION  <= Fin_periodo,
         TAREA != "Archivo por conocimiento",
         TAREA != "Programación") %>%
  select(HT, `COD DE PROBLEMA`, ESPECIALISTA, TAREA, FECHA_ACCION)
# Evidencia de programación
OSPA_EQ2_PROG <- OSPA_E2_META_2_PROG %>%
  mutate(FECHA_ACCION = ymd(`FECHA DE PROGRAMACION`))  %>%
  filter(FECHA_ACCION >= Inicio_periodo,
         FECHA_ACCION <= Fin_periodo) %>%
  mutate(HT = `N° REGISTRO SIGED [2]`,
         TAREA = TIPO)  %>%
  select(HT, `COD DE PROBLEMA`, ESPECIALISTA, TAREA, FECHA_ACCION)

# Consolidado de evidencia
OSPA_EQ2_EVIDENCIA_M2 <- rbind(OSPA_EQ2_ACCIONES, OSPA_EQ2_PROG)
OSPA_EQ2_EVIDENCIA_M2 <- OSPA_EQ2_EVIDENCIA_M2 %>%
  arrange(FECHA_ACCION)

# Tabla resumen
OSPA_EQ2_M2 <- OSPA_E2_META_2 %>%
  group_by(ESPECIALISTA) %>%
  filter(INICIO_MES >= Inicio_periodo, # Por fecha de ejecución
         FIN_MES <= Fin_periodo)  %>%
  summarize(META = sum(`Meta mensual`),
            LOGRO = sum(`Tareas realizadas final`)) %>%
  mutate(M2_LOGRADO = LOGRO/META) %>%
  select(ESPECIALISTA, M2_LOGRADO)

# Consolidado Equipo 2
OSPA_EQ2 <- merge(OSPA_EQ2_M1, OSPA_EQ2_M2)
OSPA_EQ2_AUTO <- merge(OSPA_EQ2, METAS_OSPA)
OSPA_EQ2_AUTO <- OSPA_EQ2_AUTO %>%
  mutate(NOMBRE_EQUIPO = "Observatorio de Solución de Problemas Ambientales",
         META_PROPUESTA = "100%") %>%
  select(ESPECIALISTA, EQUIPO_SEFA, NOMBRE_EQUIPO, N_EQUIPO, 
         NOMBRE,  PUESTO, `META 1`, `META 2`, META_PROPUESTA,
         M1_LOGRADO, M2_LOGRADO)

# III.3.3 OSPA - Jefe ----
OSPA_AUTO <- rbind(OSPA_EQ1_AUTO, OSPA_EQ2_AUTO)
# Resumen para jefe
RESUMEN_EQ1 <- OSPA_EQ1_AUTO %>%
  mutate(NOMBRE_META = `META 2`,
         META_LOGRADA = M2_LOGRADO) %>%
  select(ESPECIALISTA, EQUIPO_SEFA, NOMBRE_EQUIPO, 
         NOMBRE_META, META_LOGRADA)


RESUMEN_EQ2 <- OSPA_EQ2_AUTO %>%
  mutate(NOMBRE_META = `META 2`,
         META_LOGRADA = M2_LOGRADO) %>%
  select(ESPECIALISTA, EQUIPO_SEFA, NOMBRE_EQUIPO, 
         NOMBRE_META, META_LOGRADA)


################ IV. Generación de documentos y exportables ################
# IV.1 Supervisión ----
# Equipo
pwalk(list(SUPERVISION_AUTO$ESPECIALISTA,
           SUPERVISION_AUTO$NOMBRE,
           SUPERVISION_AUTO$EQUIPO_SEFA,
           SUPERVISION_AUTO$NOMBRE_EQUIPO,
           SUPERVISION_AUTO$N_EQUIPO,
           SUPERVISION_AUTO$PUESTO, 
           SUPERVISION_AUTO$`META 1`,
           SUPERVISION_AUTO$`META 2`,
           SUPERVISION_AUTO$META_PROPUESTA,
           SUPERVISION_AUTO$M1_LOGRADO, 
           SUPERVISION_AUTO$M2_LOGRADO),
      slowly(R_auto_lec_rep, 
             rate_backoff(10, max_times = Inf)))
# Creación de exportable
pwalk(list(SUPERVISION_AUTO$ESPECIALISTA,
           SUPERVISION_AUTO$NOMBRE,
           SUPERVISION_AUTO$EQUIPO_SEFA,
           SUPERVISION_AUTO$N_EQUIPO),
      slowly(R_gen_exportable, 
             rate_backoff(10, max_times = Inf)))

# Jefe de equipo
ruta_resumen_SUPER <- file.path(dir, "SUPERVISION", # Ruta de archivo
                                "SUPERVISION - Resumen.xlsx")
# Tabla resumen
write.xlsx(JEFE_M1,
           file = ruta_resumen_SUPER,
           sheetName = "META 1",
           append = TRUE)
write.xlsx(JEFE_EVIDENCIA_M1,
           file = ruta_resumen_SUPER,
           sheetName = "META 1 - EVIDENCIA",
           append = TRUE)
write.xlsx(JEFE_M2,
           file = ruta_resumen_SUPER,
           sheetName = "META 2",
           append = TRUE)
write.xlsx(JEFE_EVIDENCIA_M2,
           file = ruta_resumen_SUPER,
           sheetName = "META 2 - EVIDENCIA",
           append = TRUE)

#--------------------------------------------------------------

# IV.2 OSPA ----

# Creación del documento y exportable
pwalk(list(OSPA_AUTO$ESPECIALISTA,
           OSPA_AUTO$NOMBRE,
           OSPA_AUTO$EQUIPO_SEFA,
           OSPA_AUTO$NOMBRE_EQUIPO,
           OSPA_AUTO$N_EQUIPO,
           OSPA_AUTO$PUESTO, 
           OSPA_AUTO$`META 1`,
           OSPA_AUTO$`META 2`,
           OSPA_AUTO$META_PROPUESTA,
           OSPA_AUTO$M1_LOGRADO, 
           OSPA_AUTO$M2_LOGRADO),
      slowly(R_auto_lec_rep, 
             rate_backoff(10, max_times = Inf)))

# Creación de exportable
pwalk(list(OSPA_AUTO$ESPECIALISTA,
           OSPA_AUTO$NOMBRE,
           OSPA_AUTO$EQUIPO_SEFA,
           OSPA_AUTO$N_EQUIPO),
      slowly(R_gen_exportable, 
             rate_backoff(10, max_times = Inf)))

# Jefe de equipo
ruta_resumen_OSPA <- file.path(dir, "OSPA", # Ruta de archivo
                                "OSPA - Resumen.xlsx")
# Tabla resumen
write.xlsx(RESUMEN_EQ1, 
           file = ruta_resumen_OSPA,
           sheet = "META 1",
           append = TRUE)

write.xlsx(OSPA_EQ1_EVIDENCIA_M2, 
           file = ruta_resumen_OSPA,
           sheet = "META 1 - EVIDENCIA",
           append = TRUE)

write.xlsx(RESUMEN_EQ2, 
           file = ruta_resumen_OSPA,
           sheet = "META 2",
           append = TRUE)

write.xlsx(OSPA_EQ2_EVIDENCIA_M1, 
           file = ruta_resumen_OSPA,
           sheet = "META 2 - EVIDENCIA",
           append = TRUE)
