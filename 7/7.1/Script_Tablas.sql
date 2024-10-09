-- DROP TABLE -> Modulo de equipos y recargas
DROP TABLE IF EXISTS Pedido_Equipo;
DROP TABLE IF EXISTS Factura;
DROP TABLE IF EXISTS SAP;
DROP TABLE IF EXISTS SUNAT;
DROP TABLE IF EXISTS Recarga;
DROP TABLE IF EXISTS Pedido;
DROP TABLE IF EXISTS Equipo;
DROP TABLE IF EXISTS Cliente;

-- DROP TABLE -> Modulo de liquidacion

DROP TABLE IF exists Observacion;
DROP TABLE IF exists Liquidacion;
DROP TABLE IF exists Contrato;
DROP TABLE IF exists Analista_credito;
DROP TABLE IF exists Analista_soporte;

-- DROP TABLE -> Modulo de Credito en Financiamiento

DROP TABLE IF exists Credito;
DROP TABLE IF exists Solicitud_Credito;
DROP TABLE IF exists Oficial_Credito;
DROP TABLE IF exists Pago;
DROP TABLE IF exists Departamento_Desembolso;

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
    COD_EQUIPO VARCHAR(9) PRIMARY KEY,
    NOMBRE_EQUIPO VARCHAR(100) NOT NULL,
    MARCA VARCHAR(50),
    MODELO VARCHAR(50),
    CATEGORIA VARCHAR(50),
    PRECIO_UNITARIO DECIMAL(10, 2),
    CANTIDAD_STOCK INT
);

-- Tabla Pedido
CREATE TABLE Pedido (
    COD_PEDIDO VARCHAR(9) PRIMARY KEY,
    FECHA_PEDIDO DATE NOT NULL,
    CANTIDAD_TOTAL INT,
    ESTADO_PEDIDO VARCHAR(50) CHECK (ESTADO_PEDIDO IN ('PENDIENTE', 'COMPLETADO', 'CANCELADO')),
    FECHA_ENTREGA DATE,
    METODO_PAGO VARCHAR(50),
    OBSERVACIONES VARCHAR(255),
    DEMORA_PEDIDO INT,
    COD_CLIENTE VARCHAR(7),
    COD_RECARGA VARCHAR(9),
    FOREIGN KEY (COD_CLIENTE) REFERENCES Cliente(COD_CLIENTE),
    FOREIGN KEY (COD_RECARGA) REFERENCES Recarga(COD_RECARGA)
);

-- Tabla Pedido_Equipo
CREATE TABLE Pedido_Equipo (
    COD_PEDIDO_EQUIPO VARCHAR(9) PRIMARY KEY,
    COD_PEDIDO VARCHAR(9),
    COD_EQUIPO VARCHAR(9),
    CANTIDAD_PEDIDA INT,
    FOREIGN KEY (COD_PEDIDO) REFERENCES Pedido(COD_PEDIDO),
    FOREIGN KEY (COD_EQUIPO) REFERENCES Equipo(COD_EQUIPO)
);

-- Tabla Recarga
CREATE TABLE Recarga (
    COD_RECARGA VARCHAR(9) PRIMARY KEY,
    FECHA_SOLICITUD_RECARGA DATE NOT NULL,
    MONTO_RECARGA DECIMAL(10, 2),
    ESTADO_RECARGA VARCHAR(50) CHECK (ESTADO_RECARGA IN ('PENDIENTE', 'VALIDADA', 'RECHAZADA')),
    FECHA_LIBERACION_RECARGA DATE
);

-- Tabla SAP
CREATE TABLE SAP (
    COD_SAP VARCHAR(10) PRIMARY KEY,
    FECHA_VALIDACION DATE NOT NULL,
    ESTADO_VALIDACION VARCHAR(50),
    OBSERVACION_VALIDACION VARCHAR(255),
    LIMITE_CREDITO DECIMAL(10, 2),
    NUM_REFERENCIA_SAP_SUNAT VARCHAR(50),
    COD_PEDIDO VARCHAR(9),
    FOREIGN KEY (COD_PEDIDO) REFERENCES Pedido(COD_PEDIDO)
);

-- Tabla Factura
CREATE TABLE Factura (
    COD_FACTURA VARCHAR(10) PRIMARY KEY,
    MONTO_FACTURA DECIMAL(10, 2),
    FECHA_FACTURA DATE NOT NULL,
    ESTADO_FACTURA VARCHAR(50) CHECK (ESTADO_FACTURA IN ('EMITIDA', 'PAGADA', 'ANULADA')),
    NUM_REFERENCIA_SUNAT VARCHAR(50),
    COD_SAP VARCHAR(10),
    FOREIGN KEY (COD_SAP) REFERENCES SAP(COD_SAP)
);

-- Tabla SUNAT
CREATE TABLE SUNAT (
    COD_SUNAT VARCHAR(10) PRIMARY KEY,
    FECHA_ASIGNACION DATE NOT NULL,
    MONTO_SUNAT DECIMAL(10, 2),
    NUM_REFERENCIA_SUNAT VARCHAR(50),
    COD_SAP VARCHAR(10),
    FOREIGN KEY (COD_SAP) REFERENCES SAP(COD_SAP)
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
    TIPO_LIQ VARCHAR(20) CHECK (TIPO_LIQ IN ('PRE-LIQUIDACION', 'LIQUIDACION FINAL'))
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
-------------CREACION DE TABLAS PARA MODULO COBRANZAS

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

-- CREATE TABLE -> Modulo de Credito en Financiamento

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
CREATE TABLE Credito (
    COD_PAGO VARCHAR(6) PRIMARY KEY,
    FECHA_PAGO DATE NOT NULL,
    METODO_PAGO VARCHAR(20) CHECK (METODO_PAGO IN ('TRANSFERENCIA', 'CHEQUE', 'EFECTIVO')),
    MONTO_PAGO VARCHAR(2) NOT NULL,
    COD_CREDITO VARCHAR(9) NOT NULL,
	ESTADO_PAGO VARCHAR(20) CHECK (TIPO_CREDITO IN ('PENDIENTE', 'COMPLETADO', 'RECHAZADO')),
    FOREIGN KEY (COD_CREDITO) REFERENCES Credito(COD_CREDITO)
);


-------------------------------------------- CREACION DE TABLAS PARA EL DW
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


-- INSERTS ETL DESDE EL MODULO DE COBRANZA
INSERT INTO Dim_Analista (COD_ANALISTA_COBRANZAS, NOMBRE_ANALISTA_COBRANZA, REGION_ANALISTA_COBRANZA)
SELECT COD_ANALISTA_COBRANZAS, NOMBRE_ANALISTA_COBRANZA, REGION_ANALISTA_COBRANZA
FROM Analista_cobranza;


INSERT INTO Dim_Cliente (COD_CLIENTE, CREDITO_MAXIMO, ESTADO_CLIENTE, LINEA_CREDITO, REGION)
SELECT COD_CLIENTE, CREDITO_MAXIMO, ESTADO_CLIENTE, LINEA_CREDITO, REGION
FROM Cliente;


INSERT INTO Dim_Deuda (COD_DEUDA, ESTADO_DEUDA, MONTO_DEUDA, DIAS_RETRASO, ESTADO_COBRANZA, FECHA_VENCIMIENTO)
SELECT COD_DEUDA, ESTADO_DEUDA, MONTO_DEUDA, DIAS_RETRASO, ESTADO_COBRANZA, FECHA_VENCIMIENTO
FROM Deuda;


INSERT INTO Dim_Tiempo (FECHA, YEAR, MONTH, DAY_MONTH, WEEK_YEAR, DAY_WEEK)
SELECT 
    FECHA_VENCIMIENTO, 
    EXTRACT(YEAR FROM FECHA_VENCIMIENTO), 
    EXTRACT(MONTH FROM FECHA_VENCIMIENTO), 
    EXTRACT(DAY FROM FECHA_VENCIMIENTO),
    EXTRACT(WEEK FROM FECHA_VENCIMIENTO), 
    EXTRACT(DOW FROM FECHA_VENCIMIENTO)
FROM Deuda;


INSERT INTO Fact_Rep_Deuda (FECHA_REPORTE, COD_ANALISTA_COBRANZA, COD_TIEMPO, COD_CLIENTE, COD_DEUDA)
SELECT 
    CURRENT_DATE,
    D.COD_ANALISTA_COBRANZA, 
    T.COD_TIEMPO, 
    C.COD_CLIENTE, 
    D.COD_DEUDA
FROM 
    Deuda D
JOIN Cliente C ON D.COD_CLIENTE = C.COD_CLIENTE
JOIN Dim_Tiempo T ON D.FECHA_VENCIMIENTO = T.FECHA;    



-----------------------------------------------------
