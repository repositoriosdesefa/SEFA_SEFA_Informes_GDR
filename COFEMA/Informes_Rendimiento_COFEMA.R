#######################################          
#############    COFEMA   #############
######## DATA PARA ENTREGABLES ########
####################################### 

# I. Parámetros y directorio ----
{
  setwd("")
 
} # Setear directorio
{
  library(lubridate)
  library(ggplot2)
  library(dplyr)
  library(reshape)
  library(reshape2)
  library(stringr)
  library(knitr)
  library(kableExtra)
  library(googledrive)
  library(googlesheets4)
  library(forcats)
  library(readxl)
  library(WriteXLS)
  library(openxlsx)
  library(reshape)
  library(scales)
  
} # Activar librerias
{
  Correo_electronico <- ""
  drive_auth(email = Correo_electonico)
  gs4_auth(token = drive_token())
  
} # Identificaci?n en Google Drive, vinculada al correo electr?nico colocado
{
  
  # II. Descarga de información ----
  BASE_COFEMA <- ""
  EQUIPO1 <- read_sheet(BASE_COFEMA, sheet = "EQUIPO 1", skip = 3)
  
  EQUIPO2<-read_sheet(BASE_COFEMA, sheet = "EQUIPO 2", skip = 3)
  
  DILIGENCIAS<-read_sheet(BASE_COFEMA, sheet = "DILIGENCIAS", skip = 3)
  
  LINEAS<-""
  LINEAS<-read_sheet(LINEAS, sheet = "Registro")
 
  
} # Descarga de GoogleSheets
{
  
  ######################
  #####  EQUIPO I  #####
  ######################
  
  # III. Procesamiento de datos ----
  EQUIPO1 <- select(EQUIPO1, 
                    Caso_Cofema="EXPEDIENTE COFEMA",
                    FECHAI_COFEMA="FECHA INGRESO COFEMA",
                    HT="HT",
                    Tipo_pedido="TIPO DE SOLICITUD",
                    Tarea= "TAREA",
                    FECHA_ASIG="FECHA DE ASIGNACION",
                    ESPECIALISTA="ENCARGADO",
                    F_PRO="FECHA DE ENTREGA DE PROYECTO",
                    F_RESP="FECHA DEL DOCUMENTO DE RESPUESTA",
                    Documento_Respuesta="DOCUMENTO DE RESPUESTA",
                    ESTADO_GENERAL="ESTADO GENERAL",
                    TIEMPO_RESP="TIEMPO TOTAL DE RESPUESTA",
                    F_APROB="FECHA DE APROBACION DEL PROYECTO")
  
  EQUIPO1 <- filter(EQUIPO1, Tipo_pedido != "REITERATIVO")
  EQUIPO1= EQUIPO1[!is.na(EQUIPO1$F_PRO), ]
  EQUIPO1= EQUIPO1[!is.na(EQUIPO1$F_RESP), ]
  #ARREGLAR LOS DE TRAMITE
  
  EQUIPO1IF<-filter(EQUIPO1, Tarea == "INFORME FUNDAMENTADO")
  EQUIPO1IF <- select(EQUIPO1IF, Caso_Cofema,FECHAI_COFEMA,HT,Tipo_pedido,Tarea,FECHA_ASIG,ESPECIALISTA,F_PRO,TIEMPO_RESP,F_APROB)
  EQUIPO1IF["Detalle"] <- "Trámite de IF"
  
  #ARREGLAR LOS QUE TIENEN DOC
  
  EQUIPO1ATEN <- filter(EQUIPO1, Tarea != "INFORME FUNDAMENTADO")
  EQUIPO1ATEN= EQUIPO1ATEN[!is.na(EQUIPO1ATEN$Documento_Respuesta), ]
  EQUIPO1ATEN <- select(EQUIPO1ATEN, Caso_Cofema,FECHAI_COFEMA,HT,Tipo_pedido,Tarea,FECHA_ASIG,ESPECIALISTA,F_PRO,TIEMPO_RESP,F_APROB,"Detalle"=Documento_Respuesta)
  
  #ARREGLAR LOS NO TIENEN DOC
  
  EQUIPO1NOATEN <- filter(EQUIPO1, Tipo_pedido != "INFORME FUNDAMENTADO")
  EQUIPO1NOATEN = EQUIPO1NOATEN[is.na(EQUIPO1NOATEN$Documento_Respuesta), ]
  EQUIPO1NOATEN <- select(EQUIPO1NOATEN, Caso_Cofema,FECHAI_COFEMA,HT,Tipo_pedido,Tarea,FECHA_ASIG,ESPECIALISTA,F_PRO,TIEMPO_RESP,F_APROB)
  
  EQUIPO1NOATEN["Detalle"] <- "Elaboración de proyecto"
  
  rm(EQUIPO1)
  
  #######################
  #####  EQUIPO II  #####
  #######################
  
  EQUIPO2 <- select(EQUIPO2, 
                    Caso_Cofema="EXPEDIENTE COFEMA",
                    HT="HT",
                    FECHA_ASIG="FECHA DE ASIGNACION",
                    ESPECIALISTA="ENCARGADO",
                    F_PRO="FECHA DE ENTREGA AL REVISOR",
                    Documento_Respuesta="ESTADO ACTUAL",
                    F_RESP="FECHA DE REMISION",
                    ESTADO_GENERAL="ESTADO GENERAL",
                    TIEMPO_RESP="TIEMPO DE ELABORACION")
  
  EQUIPO2= EQUIPO2[!is.na(EQUIPO2$F_PRO), ]
  EQUIPO2= EQUIPO2[!is.na(EQUIPO2$F_RESP), ]
  
  #ARREGLAR LOS QUE TIENEN DOC
  EQUIPO2ATEN = EQUIPO2[!is.na(EQUIPO2$Documento_Respuesta), ]
  
  EQUIPO2ATEN <- select(EQUIPO2ATEN,Caso_Cofema,HT,FECHA_ASIG,ESPECIALISTA,F_PRO,TIEMPO_RESP,"Detalle"=Documento_Respuesta)
  
  EQUIPO2ATEN["Tipo_pedido"] <- "NUEVO PEDIDO"
  EQUIPO2ATEN["Tarea"] <- "Elaboración de IF"
  EQUIPO2ATEN["FECHAI_COFEMA"] <- ""
  EQUIPO2ATEN["F_APROB"] <- ""
  EQUIPO2ATEN$FECHAI_COFEMA <- as.Date(EQUIPO2ATEN$FECHAI_COFEMA)
  EQUIPO2ATEN$F_APROB <- as.Date(EQUIPO2ATEN$F_APROB)
  #ARREGLAR LOS QUE TIENEN NO DOC
  EQUIPO2NOATEN = EQUIPO2[is.na(EQUIPO2$Documento_Respuesta), ]
  
  EQUIPO2NOATEN <- select(EQUIPO2NOATEN,Caso_Cofema,HT,FECHA_ASIG,ESPECIALISTA,F_PRO,TIEMPO_RESP)
  
  EQUIPO2NOATEN["Detalle"] <- "Elaboración de proyecto de IF"
  EQUIPO2NOATEN["Tipo_pedido"] <- "NUEVO PEDIDO"
  EQUIPO2NOATEN["Tarea"] <- "Elaboración de IF"
  EQUIPO2NOATEN["FECHAI_COFEMA"] <- ""
  EQUIPO2NOATEN["F_APROB"] <- ""
  EQUIPO2NOATEN$FECHAI_COFEMA <- as.Date(EQUIPO2NOATEN$FECHAI_COFEMA)
  EQUIPO2NOATEN$F_APROB <- as.Date(EQUIPO2NOATEN$F_APROB)
  
  rm(EQUIPO2)
  
  
  #######################
  ####  DILIGENCIAS  ####
  #######################
  
  #SETEANDO LA DIRECCION DEL DRIVE
 
  DILIGENCIAS <- select(DILIGENCIAS, 
                        Caso_Cofema="EXPEDIENTE COFEMA",
                        FECHAI_COFEMA="FECHA INGRESO COFEMA",
                        HT="HT",
                        FECHA_ASIG="FECHA DE ASIGNACION",
                        ESPECIALISTA="ENCARGADO",
                        F_PRO="FECHA DE ENTREGA DE PROYECTO",
                        Documento_Respuesta="DOCUMENTO DE RESPUESTA",
                        F_RESP="FECHA DEL OFICIO DE RESPUESTA",
                        ESTADO_GENERAL="ESTADO GENERAL",
                        TIEMPO_RESP="TIEMPO DE ELABORACION",
                        AMER_RPT="¿AMERITA RESPUESTA?",
                        F_APROB="FECHA DE APROBACION DEL PROYECTO")
  DILIGENCIAS["Tarea"] <- "DILIGENCIAS"
  DILIGENCIAS <- filter(DILIGENCIAS, AMER_RPT == "SI")
  DILIGENCIAS = DILIGENCIAS[!is.na(DILIGENCIAS$F_PRO), ]
  DILIGENCIAS = DILIGENCIAS[!is.na(DILIGENCIAS$F_RESP), ]
  DILIGENCIAS <- select(DILIGENCIAS,-AMER_RPT)
  
  #ARREGLAR LOS QUE TIENEN DOC
  DILIGENCIASATEN = DILIGENCIAS[!is.na(DILIGENCIAS$Documento_Respuesta), ]
  
  DILIGENCIASATEN <- select(DILIGENCIASATEN,Caso_Cofema,FECHAI_COFEMA,HT, FECHA_ASIG,ESPECIALISTA,F_PRO,TIEMPO_RESP,F_APROB,"Detalle"=Documento_Respuesta)
  
  DILIGENCIASATEN["Tipo_pedido"] <- "NUEVO PEDIDO"
  DILIGENCIASATEN["Tarea"] <- "Diligencias"
  
  #ARREGLAR LOS QUE TIENEN NO DOC
  DILIGENCIASNOATEN = DILIGENCIAS[is.na(DILIGENCIAS$Documento_Respuesta), ]
  
  DILIGENCIASNOATEN <- select(DILIGENCIASNOATEN,Caso_Cofema,FECHAI_COFEMA,HT, FECHA_ASIG,ESPECIALISTA,F_PRO,TIEMPO_RESP,F_APROB)
  
  DILIGENCIASNOATEN["Detalle"] <- "Elaboración de proyecto"
  DILIGENCIASNOATEN["Tipo_pedido"] <- "NUEVO PEDIDO"
  DILIGENCIASNOATEN["Tarea"] <- "Diligencias"
  
  rm(DILIGENCIAS)
  
  ###########################
  ##### PEDIDOS LINEAS  #####
  ###########################
  

  # LINEAS <- select(LINEAS, 
  #                  Caso_Cofema="EXP. COFEMA",
  #                  HT="HOJA DE TRAMITE",
  #                  Tarea= "VIA",
  #                  ESPECIALISTA="ESPECIALISTA A CARGO EN COFEMA",
  #                  F_PRO="FECHA DE SOLICITUD",
  #                  TIEMPO_RESP="DIAS HABILES TRANSCURRIDOS")
  # 
  # 
  # LINEAS["Tipo_pedido"] <- "PEDIDO_LINEAS"
  # LINEAS["Detalle"] <- "Pedido a lineas"
  # LINEAS["FECHAI_COFEMA"] <- ""
  # LINEAS["FECHA_ASIG"] <- ""
  # LINEAS["F_APROB"] <- ""
  # LINEAS$FECHAI_COFEMA <- as.Date(LINEAS$FECHAI_COFEMA)
  # LINEAS$FECHA_ASIG <- as.Date(LINEAS$FECHA_ASIG)
  # LINEAS$F_APROB <- as.Date(LINEAS$F_APROB)
  # LINEAS= LINEAS[!is.na(LINEAS$F_PRO), ]
  
  
  
} # Procesando las bases
{
  
  # III.1 Consolidado de información ----
  COFEMA_ENTREGABLES<-rbind(EQUIPO1ATEN,EQUIPO1NOATEN,EQUIPO1IF,EQUIPO2ATEN,EQUIPO2NOATEN,DILIGENCIASNOATEN,DILIGENCIASATEN)
  COFEMA_ENTREGABLES <- COFEMA_ENTREGABLES %>%
                       filter(ESPECIALISTA == "UGARRIZA, MARIANA") %>%
                       filter(TIEMPO_RESP > 0 & TIEMPO_RESP <=30)
  
  rm(EQUIPO1ATEN,EQUIPO1NOATEN,EQUIPO1IF,EQUIPO2ATEN,EQUIPO2NOATEN,DILIGENCIASNOATEN,DILIGENCIASATEN)
  
  
} # Consolidado de bases
{
  
  # IV. Generación de exportable ----
  COFEMA_ENTREGABLES <- as.data.frame(COFEMA_ENTREGABLES)
  write.xlsx(COFEMA_ENTREGABLES,file="BASE_ENTREGABLE.xlsx", sheetName="DATA")
} # Exportar archivo excel






