-- DROP TABLE -> Modulo de equipos y  modulo de recargas
DROP TABLE IF EXISTS Notificacion;
DROP TABLE IF EXISTS Factura;
DROP TABLE IF EXISTS Recarga;
DROP TABLE IF EXISTS Pedido_Equipo;
DROP TABLE IF EXISTS Equipo;
DROP TABLE IF EXISTS Pedido;
DROP TABLE IF EXISTS Cliente;

-- DROP TABLE -> Modulo de liquidacion

DROP TABLE IF exists Observacion;
DROP TABLE IF exists Liquidacion;
DROP TABLE IF exists Contrato;
DROP TABLE IF exists Analista_credito;
DROP TABLE IF exists Analista_soporte;

--DROP TABLE --> Modulo cobranzas
DROP TABLE IF exists Analista_cobranza;
DROP TABLE IF exists Notificacion_cobranza;
DROP TABLE IF exists Deuda;
DROP TABLE IF exists Coordinador_Zonal;

-- DROP TABLE --> Módulo de admisión
DROP TABLE IF EXISTS Documento_adm;
DROP TABLE IF EXISTS Entrevista;
DROP TABLE IF EXISTS Solicitud_Analista_admision;
DROP TABLE IF EXISTS Solicitud;
DROP TABLE IF EXISTS Solicitante;
DROP TABLE IF EXISTS Analista_admision;

-- DROP TABLE --> Módulo de Credito

DROP TABLE IF exists Credito;
DROP TABLE IF exists Solicitud_Credito;
DROP TABLE IF exists Oficial_Credito;
DROP TABLE IF exists Pago;
DROP TABLE IF exists Departamento_Desembolso;

-- CREATE TABLES 

-- CREATE TABLE -> Modulo de equipos y recargas

-- Tabla Cliente
CREATE TABLE Cliente (
    COD_CLIENTE VARCHAR(7) PRIMARY KEY,
    NOMBRE VARCHAR(100) NOT NULL,
    RAZON_SOCIAL VARCHAR(150),
    TELEFONO VARCHAR(15),
    CORREO_EMPRESA VARCHAR(100),
    DIRECCION_CLIENTE VARCHAR(150),
    CREDITO_MAXIMO DECIMAL(10, 2),
    ESTADO_CLIENTE VARCHAR(50) CHECK (ESTADO_CLIENTE IN ('OPERATIVO CON MOVIMIENTO', 'OPERATIVO SIN MOVIMIENTO', 'PROCESO DE LIQUIDACION', 'LIQUIDADO')),
    FECHA_REGISTRO DATE,
    LINEA_CREDITO DECIMAL(10, 2),
    CLASE_PERSONA VARCHAR(50),
    REGION VARCHAR(50),
    REP_LEGAL VARCHAR(100)
);

-- Tabla Equipo
CREATE TABLE Equipo (
    COD_EQUIPO CHAR(11) PRIMARY KEY,
    NOMBRE_EQUIPO VARCHAR(100) NOT NULL,
    MARCA VARCHAR(50),
    MODELO VARCHAR(50),
    CATEGORIA VARCHAR(50),
    PRECIO_UNITARIO DECIMAL(10,2),
    CANTIDAD_STOCK INT
);


-- Tabla Pedido
CREATE TABLE Pedido (
    COD_PEDIDO VARCHAR(10) PRIMARY KEY,
    COD_CLIENTE VARCHAR(7) NOT NULL,  
    FECHA_REG_PEDIDO DATE ,
    FECHA_EVALUACION DATE ,
    ESTADO_PEDIDO VARCHAR(10) CHECK (ESTADO_PEDIDO IN ('Aceptado', 'Rechazado', 'Pendiente')) NOT NULL,
    METODO_PAGO VARCHAR(15) CHECK (METODO_PAGO IN ('Credito', 'Contado', 'Transferencia')) NOT NULL,
    OBSERVACIONES VARCHAR(50),
    TIPO_PEDIDO VARCHAR(10) CHECK (TIPO_PEDIDO IN ('Equipo', 'Recarga')) NOT NULL,
	MONTO_PEDIDO INTEGER,
    FOREIGN KEY (COD_CLIENTE) REFERENCES Cliente(COD_CLIENTE)  -- Cambiado a Cliente
);


-- Tabla Notificacion
CREATE TABLE Notificacion (
    COD_NOTIFICACION VARCHAR(10) PRIMARY KEY,
    COD_PEDIDO VARCHAR(10) NOT NULL,
    FECHA_NOTIFICACION DATE NOT NULL,
    OBSERVACION_NOTIFICACION TEXT,
    TIPO_NOTIFICACION VARCHAR(10) CHECK (TIPO_NOTIFICACION IN ('Aceptado', 'Rechazado')) NOT NULL,
    FOREIGN KEY (COD_PEDIDO) REFERENCES Pedido(COD_PEDIDO)  -- Cambiado a Pedido
);

-- Tabla Pedido_Equipo
CREATE TABLE Pedido_Equipo (
    COD_PEDIDO_EQUIPO CHAR(10) PRIMARY KEY,
    COD_PEDIDO VARCHAR(10) NOT NULL,
    COD_EQUIPO CHAR(11) NOT NULL,
    CANTIDAD_PEDIDA INTEGER NOT NULL,
	MONTO_EQUIPO INTEGER NOT NULL,
    FOREIGN KEY (COD_PEDIDO) REFERENCES Pedido(COD_PEDIDO),
    FOREIGN KEY (COD_EQUIPO) REFERENCES Equipo(COD_EQUIPO)
);

-- Tabla Recarga
CREATE TABLE Recarga (
    COD_RECARGA VARCHAR(10) PRIMARY KEY,
    COD_PEDIDO VARCHAR(10) NOT NULL,
    FECHA_SOLICITUD_RECARGA DATE NOT NULL,
    MONTO_RECARGA DECIMAL(10, 2) NOT NULL CHECK (MONTO_RECARGA > 0),
    ESTADO_RECARGA VARCHAR(10) NOT NULL CHECK (ESTADO_RECARGA IN ('Aceptado', 'Rechazado', 'Pendiente')),
    FECHA_LIBERACION_RECARGA DATE,
    FOREIGN KEY (COD_PEDIDO) REFERENCES Pedido(COD_PEDIDO)  
);

-- Tabla Factura
CREATE TABLE Factura (
    COD_FACTURA VARCHAR(10) PRIMARY KEY,
    COD_PEDIDO VARCHAR(10) NOT NULL,
    MONTO_FACTURA DECIMAL(10, 2) CHECK (MONTO_FACTURA > 0) NOT NULL,
    FECHA_FACTURA DATE NOT NULL,
    NUM_REFERENCIA_SUNAT VARCHAR(10) NOT NULL,
    FOREIGN KEY (COD_PEDIDO) REFERENCES Pedido(COD_PEDIDO)  
);



-- CREATE TABLE -> Modulo de liquidacion

-- Tabla Analista_credito
CREATE TABLE Analista_credito (
    COD_ANALISTA_AC VARCHAR(7) PRIMARY KEY,
    NOMBRE_AC VARCHAR(50) NOT NULL,
    CORREO_AC VARCHAR(50) NOT NULL,
    FECHA_CONTRATACION DATE NOT NULL,
    TELEFONO_AC VARCHAR(9),
    DIRECCION_AC VARCHAR(100),
    ID_SUCURSAL VARCHAR(8) NOT NULL,
    ESTADO_ANALISTA_AC VARCHAR(10) CHECK (ESTADO_ANALISTA_AC IN ('activo', 'inactivo'))
);

-- Tabla Analista_soporte
CREATE TABLE Analista_soporte (
    COD_ANALISTA_S VARCHAR(7) PRIMARY KEY,
    NOMBRE_S VARCHAR(50) NOT NULL,
    CORREO_S VARCHAR(50) NOT NULL,
    FECHA_CONTRATACION_S DATE NOT NULL,
    TELEFONO_S VARCHAR(9),
    DIRECCION_S VARCHAR(100),
    ID_SUCURSAL_S VARCHAR(8) NOT NULL
);

-- Tabla Contrato
CREATE TABLE Contrato (
    COD_CONTRATO VARCHAR(9) PRIMARY KEY,
    FECHA_INICIO DATE NOT NULL,
    FECHA_FIN_NORMAL DATE,
    FECHA_FIN_REAL DATE,
    ESTADO_CONTRATO VARCHAR(20) CHECK (ESTADO_CONTRATO IN ('vigente', 'resuelto')),
    COD_CLIENTE VARCHAR(7) NOT NULL,
    COD_ANALISTA_S VARCHAR(7) NOT NULL,
    FOREIGN KEY (COD_CLIENTE) REFERENCES Cliente(COD_CLIENTE),
    FOREIGN KEY (COD_ANALISTA_S) REFERENCES Analista_soporte(COD_ANALISTA_S)
);

-- Tabla Liquidacion
CREATE TABLE Liquidacion (
    COD_LIQUIDACION VARCHAR(9) PRIMARY KEY,
    FECHA_EMISION DATE NOT NULL,
    TIPO_LIQ VARCHAR(20) CHECK (TIPO_LIQ IN ('pre-liquidacion', 'liquidacion final')),
    FECHA_LIM_OBS DATE,
    FECHA_FINALIZACION DATE,
    MONTO_DEUDA_ACUM NUMERIC(10,2),
    MONTO_GARANTIAS NUMERIC(10,2),
    MONTO_COMISIONES NUMERIC(10,2),
    COD_CLIENTE VARCHAR(7) NOT NULL,
    COD_ANALISTA_AC VARCHAR(7) NOT NULL,
    FOREIGN KEY (COD_CLIENTE) REFERENCES Cliente(COD_CLIENTE),
    FOREIGN KEY (COD_ANALISTA_AC) REFERENCES Analista_credito(COD_ANALISTA_AC)
);

-- Tabla Observacion
CREATE TABLE Observacion (
    COD_OBSERVACION VARCHAR(9) PRIMARY KEY,
    FECHA_OBS DATE NOT NULL,
    FECHA_ABS DATE,
    DESCRIPCION TEXT,
    COD_LIQUIDACION VARCHAR(9) NOT NULL,
    COD_CLIENTE VARCHAR(7) NOT NULL,
    COD_ANALISTA_AC VARCHAR(7) NOT NULL,
    FOREIGN KEY (COD_LIQUIDACION) REFERENCES Liquidacion(COD_LIQUIDACION),
    FOREIGN KEY (COD_CLIENTE) REFERENCES Cliente(COD_CLIENTE),
    FOREIGN KEY (COD_ANALISTA_AC) REFERENCES Analista_credito(COD_ANALISTA_AC)
);

-- CREATE TABLE -> Modulo de Cobranza

---Tabla analista de cobranza
CREATE TABLE Analista_cobranza (
    COD_ANALISTA_COBRANZAS VARCHAR(9) PRIMARY KEY,
    NOMBRE_ANALISTA_COBRANZA VARCHAR(100) NOT NULL,
    FECHA_DE_CONTRATACION_COBRANZA DATE NOT NULL,
    TELEFONO_ANALISTA_COBRANZA VARCHAR(20) NOT NULL,
    CORREO_ANALISTA_COBRANZA VARCHAR(100) NOT NULL,
	REGION_ANALISTA_COBRANZA VARCHAR(100) NOT NULL);

---Tabla coodinador zonal
CREATE TABLE Coordinador_Zonal (
    COD_COORDINADOR_ZONAL VARCHAR(10) PRIMARY KEY,
    NOMBRE_COORDINADOR VARCHAR(100) NOT NULL,
    FECHA_CONTRATACION_COORDINADOR DATE NOT NULL,
    TELEFONO_COORDINADOR VARCHAR(15),
    ZONA_ASIGNADA VARCHAR(100)
);

---Tabla deuda
CREATE TABLE Deuda (
    COD_DEUDA VARCHAR(11) PRIMARY KEY,
    ESTADO_DEUDA VARCHAR(50) CHECK (ESTADO_DEUDA IN ('Atrasado', 'Al dia')),
    MONTO_DEUDA DECIMAL(10, 2),
    DIAS_RETRASO INT,
    ESTADO_COBRANZA VARCHAR(50) CHECK (ESTADO_COBRANZA IN ('En fecha de pago', 'Regular', 'Administrativa', 'Prejudicial')),
    FECHA_VENCIMIENTO DATE,
    COD_ANALISTA_COBRANZA VARCHAR(9),
    COD_CLIENTE VARCHAR(11),
    COD_COORDINADOR_ZONAL VARCHAR(10),
    FOREIGN KEY (COD_ANALISTA_COBRANZA) REFERENCES Analista_cobranza(COD_ANALISTA_COBRANZAS),
    FOREIGN KEY (COD_CLIENTE) REFERENCES Cliente(COD_CLIENTE),
    FOREIGN KEY (COD_COORDINADOR_ZONAL) REFERENCES Coordinador_Zonal(COD_COORDINADOR_ZONAL)
);

---tabla notificacion de cobranza
CREATE TABLE Notificacion_cobranza (
    COD_NOTIFICACION_COBRANZA VARCHAR(8) PRIMARY KEY,
    FECHA_ENVIO DATE NOT NULL,
    TIPO_NOTIFICACION VARCHAR(50) NOT NULL,
    COD_COORDINADOR_ZONAL VARCHAR(10),
    COD_CLIENTE VARCHAR(11),
    COD_DEUDA VARCHAR(11),
    FOREIGN KEY (COD_COORDINADOR_ZONAL) REFERENCES Coordinador_Zonal(COD_COORDINADOR_ZONAL),
    FOREIGN KEY (COD_CLIENTE) REFERENCES Cliente(COD_CLIENTE),
    FOREIGN KEY (COD_DEUDA) REFERENCES Deuda(COD_DEUDA)
);

-- CREATE TABLE -> Modulo de Admision

-- Tabla Solicitante
CREATE TABLE Solicitante (
    COD_SOLICITANTE VARCHAR(9) PRIMARY KEY,
    NOMBRE_SOL VARCHAR(100),
    RUC_SOL VARCHAR(11),
    DNI_SOL VARCHAR(8),
    UBICACION_SOL VARCHAR(150),
    CORREO_ELECTRONICO_SOL VARCHAR(100),
    TELEFONO_SOL VARCHAR(15)
);

-- Tabla Solicitud (se crea antes de las tablas que la referencian)
CREATE TABLE Solicitud (
    COD_SOLICITUD VARCHAR(9) PRIMARY KEY,
    FECHA_INICIO_SOLICITUD DATE,
    FECHA_FIN_SOLICITUD DATE,
    FECHA_NOTIFICACION DATE,
    ESTADO_SOLICITUD VARCHAR(50) CHECK (ESTADO_SOLICITUD IN ('PENDIENTE', 'COMPLETADA', 'CANCELADA')),
    TIPO_SOLICITUD VARCHAR(50),
    COD_SOLICITANTE_ID VARCHAR(9),
    FOREIGN KEY (COD_SOLICITANTE_ID) REFERENCES Solicitante(COD_SOLICITANTE)
);

-- Tabla Documento_adm
CREATE TABLE Documento_adm (
    COD_DOCUMENTO VARCHAR(9) PRIMARY KEY,
    NOMBRE_DOC VARCHAR(100),
    TIPO_DOC VARCHAR(50),
    RUTA_DOC VARCHAR(255),
    FECHA_RECIBIDO DATE,
    VERSION INT,
    ESTADO_VALIDACION VARCHAR(20) CHECK (ESTADO_VALIDACION IN ('VALIDADO', 'RECHAZADO', 'PENDIENTE')),
    SOLICITUD_ID VARCHAR(9),
    COD_ANALISTA_AC_ID VARCHAR(9),
    FOREIGN KEY (COD_SOLICITUD) REFERENCES Solicitud(COD_SOLICITUD),
    FOREIGN KEY (COD_ANALISTA_AC) REFERENCES Analista_credito(COD_ANALISTA_AC)
);

-- Tabla Entrevista
CREATE TABLE Entrevista (
    COD_ENTREVISTA VARCHAR(9) PRIMARY KEY,
    FECHA_ENTREVISTA DATE,
    HORA_INICIO_ENTREVISTA TIME,
    HORA_FIN_ENTREVISTA TIME,
    RESULTADOS_ENTREVISTA VARCHAR(255),
    OBSERVACIONES_ENTREVISTA TEXT,
    SOLICITUD_ID VARCHAR(9),
    FOREIGN KEY (SOLICITUD_ID) REFERENCES Solicitud(COD_SOLICITUD)
);

-- Tabla Analista_admision
CREATE TABLE Analista_admision (
    COD_ANALISTA_ADM VARCHAR(9) PRIMARY KEY,
    NOMBRE_AD VARCHAR(100),
    CORREO_ELECTRONICO_AD VARCHAR(100),
    TELEFONO_AD VARCHAR(15),
    DIRECCION VARCHAR(150),
    NUM_ACEPTADOS INT,
    NUM_RECHAZADOS INT,
    NUM_PENDIENTES INT
);

-- Tabla Capacitacion
CREATE TABLE Capacitacion (
    COD_CAPACITACION VARCHAR(9) PRIMARY KEY,
    FECHA_CAPACITACION DATE,
    TEMAS_TRATADOS TEXT,
    ASISTENCIA INT,
    SOLICITUD_ID VARCHAR(9),
    FOREIGN KEY (SOLICITUD_ID) REFERENCES Solicitud(COD_SOLICITUD)
);

-- Tabla seguimiento
CREATE TABLE Seguimiento (
    COD_SEGUIMIENTO VARCHAR(9) PRIMARY KEY,
    FECHA_SEGUIMIENTO DATE,
    INDICADORES JSON, -- Para almacenar métricas clave
    OBSERVACIONES TEXT,
    SOLICITUD_ID VARCHAR(9),
    FOREIGN KEY (SOLICITUD_ID) REFERENCES Solicitud(COD_SOLICITUD)
);

-- Tabla Solicitud_Analista_admision
CREATE TABLE Solicitud_Analista_admision (
    COD_SOL_ANALISTA_ADM VARCHAR(9) PRIMARY KEY,
    FECHA_INICIO DATE,
    FECHA_FINAL DATE,
    COD_ANALISTA_ADM_ID VARCHAR(9),
    SOLICITUD_ID VARCHAR(9),
    FOREIGN KEY (COD_ANALISTA_ADM_ID) REFERENCES Analista_admision(COD_ANALISTA_ADM),
    FOREIGN KEY (SOLICITUD_ID) REFERENCES Solicitud(COD_SOLICITUD)
);



-- CREATE TABLE -> Modulo de Creditos

---Tabla Solicitud de Crédito
CREATE TABLE Solicitud_Credito (
    COD_SOLICITUD VARCHAR(10) PRIMARY KEY,
    FECHA_SOLICITUD DATE NOT NULL,
    COD_CLIENTE VARCHAR(7) NOT NULL,
    DOCUMENTOS TEXT NOT NULL,
    MONTO_SOLICITADO DECIMAL(9, 2) NOT NULL,
	ESTADO_SOLICITUD VARCHAR(20) CHECK (ESTADO_SOLICITUD IN ('EN ESPERA', ' EN REVISION', 'APROBADO', 'RECHAZADO')),
    FECHA_APROBACION DATE NOT NULL,
    TIPO_CREDITO VARCHAR(20) CHECK (TIPO_CREDITO IN ('PERSONAL', 'HIPOTECARIO')),
    FOREIGN KEY (COD_CLIENTE) REFERENCES Cliente(COD_CLIENTE)
);

---Tabla Oficial de Crédito
CREATE TABLE Oficial_Credito (
    COD_OFICIAL VARCHAR(7) PRIMARY KEY,
    NOMBRE_CRED VARCHAR(50) NOT NULL,
    CORREO_CRED VARCHAR(50) NOT NULL,
    COD_SOLICITUD VARCHAR(10) NOT NULL,
    TELEFONO_CRED VARCHAR(9) NOT NULL,
	DIRECCION_CRED VARCHAR(100) NOT NULL,
    ID_SUCURSAL VARCHAR(8) NOT NULL,
    ESTADO_OFICIAL VARCHAR(20) CHECK (ESTADO_OFICIAL IN ('ACTIVO', 'INACTIVO')),
    FECHA_CONTRATACION DATE NOT NULL,
    FOREIGN KEY (COD_SOLICITUD) REFERENCES Solicitud_Credito(COD_SOLICITUD)
);

---Tabla de CréditO
CREATE TABLE Credito (
    COD_CREDITO VARCHAR(9) PRIMARY KEY,
    TASA_INTERES DECIMAL(4, 2) NOT NULL,
    COD_SOLICITUD VARCHAR(10) NOT NULL,
    PLAZO_CREDITO VARCHAR(2) NOT NULL,
    MONTO_TOTAL DECIMAL(8, 2) NOT NULL,
	TIPO_CREDITO VARCHAR(20) CHECK (TIPO_CREDITO IN ('PERSONAL', 'HIPOTECARIO')),
    TASA_MORA DECIMAL(4, 2) NOT NULL,
    ESTADO_CREDITO VARCHAR(20) CHECK (ESTADO_CREDITO IN ('ACTIVO', 'EN MORA', 'PAGADO' )),
    COD_DESEMBOLSO VARCHAR(7) NOT NULL,
    FOREIGN KEY (COD_SOLICITUD) REFERENCES Solicitud_Credito(COD_SOLICITUD),
    FOREIGN KEY (COD_DESEMBOLSO) REFERENCES Departamento_Desembolso(COD_DESEMBOLSO)
);

---Tabla de Departamento de Desembolso
CREATE TABLE Departamento_Desembolso (
    COD_DESEMBOLSO VARCHAR(7) PRIMARY KEY,
    FECHA_DESEMBOLSO DATE NOT NULL,
    METODO_ABONADO VARCHAR(20) CHECK (METODO_ABONADO IN ('TRANSFERENCIA', 'CHEQUE')),
    MONTO_TOTAL DECIMAL(8, 2) NOT NULL
);

---Tabla de Pago
CREATE TABLE Pago (
    COD_PAGO VARCHAR(6) PRIMARY KEY,
    FECHA_PAGO DATE NOT NULL,
    METODO_PAGO VARCHAR(20) CHECK (METODO_PAGO IN ('TRANSFERENCIA', 'CHEQUE', 'EFECTIVO')),
    MONTO_PAGO VARCHAR(2) NOT NULL,
    COD_CREDITO VARCHAR(9) NOT NULL,
	ESTADO_PAGO VARCHAR(20) CHECK (TIPO_CREDITO IN ('PENDIENTE', 'COMPLETADO', 'RECHAZADO')),
    FOREIGN KEY (COD_CREDITO) REFERENCES Credito(COD_CREDITO)
);

-- CREATE TABLE E INSERTS -> Modulo de DW

CREATE TABLE Dim_Analista (
    COD_ANALISTA_COBRANZAS VARCHAR(10) PRIMARY KEY,
    NOMBRE_ANALISTA_COBRANZA VARCHAR(100),
    REGION_ANALISTA_COBRANZA VARCHAR(100)
);
select * from Dim_Analista

CREATE TABLE Dim_Cliente (
    COD_CLIENTE VARCHAR(10) PRIMARY KEY,
    CREDITO_MAXIMO DECIMAL(10, 2),
    ESTADO_CLIENTE VARCHAR(50),
    LINEA_CREDITO DECIMAL(10, 2),
    REGION VARCHAR(50)
);

CREATE TABLE Dim_Deuda (
    COD_DEUDA VARCHAR(10) PRIMARY KEY,
    ESTADO_DEUDA VARCHAR(50),
    MONTO_DEUDA DECIMAL(10, 2),
    DIAS_RETRASO INT,
    ESTADO_COBRANZA VARCHAR(50),
    FECHA_VENCIMIENTO DATE
);

CREATE TABLE Dim_Tiempo (
    COD_TIEMPO SERIAL PRIMARY KEY, 
    FECHA DATE NOT NULL,
    YEAR INT,
    MONTH INT,
    DAY_MONTH INT,
    WEEK_YEAR INT,
    DAY_WEEK INT
);


CREATE TABLE Fact_Rep_Deuda (
    COD_REP_DEUDA SERIAL PRIMARY KEY,
    FECHA_REPORTE DATE NOT NULL,
    COD_ANALISTA_COBRANZA VARCHAR(10),
    COD_TIEMPO INT,
    COD_CLIENTE VARCHAR(10),
    COD_DEUDA VARCHAR(10),
    FOREIGN KEY (COD_ANALISTA_COBRANZA) REFERENCES Dim_Analista(COD_ANALISTA_COBRANZAS),
    FOREIGN KEY (COD_TIEMPO) REFERENCES Dim_Tiempo(COD_TIEMPO),
    FOREIGN KEY (COD_CLIENTE) REFERENCES Dim_Cliente(COD_CLIENTE),
    FOREIGN KEY (COD_DEUDA) REFERENCES Dim_Deuda(COD_DEUDA)
);
DROP TABLE Fact_Rep_Deuda
