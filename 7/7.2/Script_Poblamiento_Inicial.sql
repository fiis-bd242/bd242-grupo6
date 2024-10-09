
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


INSERT INTO Cliente (COD_CLIENTE, NOMBRE, RAZON_SOCIAL, TELEFONO, CORREO_EMPRESA, DIRECCION_CLIENTE, CREDITO_MAXIMO, ESTADO_CLIENTE, FECHA_REGISTRO, LINEA_CREDITO, CLASE_PERSONA, REGION, REP_LEGAL) VALUES
('CL00001', 'Distribuidor A', 'Distribuciones A S.A.C.', '123456789', 'distribuidora@a.com', 'Av. Siempre Viva 123', 5000.00, 'OPERATIVO CON MOVIMIENTO', '2023-01-15', 2500.00, 'Jurídica', 'Lima', 'Juan Pérez'),
('CL00002', 'Distribuidor B', 'Suministros B E.I.R.L.', '987654321', 'distribuidorb@b.com', 'Calle Falsa 456', 3000.00, 'OPERATIVO SIN MOVIMIENTO', '2023-02-10', 1500.00, 'Jurídica', 'Cusco', 'María López'),
('CL00003', 'Distribuidor C', 'Importaciones C S.A.C.', '456789123', 'distribuidorC@c.com', 'Av. Central 789', 8000.00, 'PROCESO DE LIQUIDACION', '2023-03-05', 4000.00, 'Natural', 'Arequipa', 'Carlos García'),
('CL00004', 'Distribuidor D', 'Servicios D S.A.C.', '321654987', 'distribuidoresD@d.com', 'Calle Verde 321', 6000.00, 'PROCESO DE LIQUIDACION', '2023-04-20', 3000.00, 'Jurídica', 'Piura', 'Luisa Sánchez'),
('CL00005', 'Distribuidor E', 'Productos E S.A.', '123123123', 'distribuidore@e.com', 'Av. Libertad 111', 7000.00, 'LIQUIDADO', '2023-05-18', 3500.00, 'Natural', 'Trujillo', 'Alberto Castillo'),
('CL00006', 'Distribuidor F', 'Comercial F E.I.R.L.', '987987987', 'distribuidorF@f.com', 'Av. Puno 333', 4000.00, 'LIQUIDADO', '2023-06-15', 2000.00, 'Jurídica', 'Iquitos', 'Ana Martínez'),
('CL00007', 'Distribuidor G', 'Distribuciones G S.A.C.', '147258369', 'distribuidorg@g.com', 'Calle Lima 222', 2000.00, 'OPERATIVO CON MOVIMIENTO', '2023-07-10', 1000.00, 'Natural', 'Tacna', 'Pedro Jiménez'),
('CL00008', 'Distribuidor H', 'Suministros H E.I.R.L.', '963258741', 'distribuidorH@h.com', 'Av. Arequipa 444', 5000.00, 'OPERATIVO SIN MOVIMIENTO', '2023-08-22', 2500.00, 'Jurídica', 'Chiclayo', 'Gabriela Torres'),
('CL00009', 'Distribuidor I', 'Importaciones I S.A.C.', '852369741', 'distribuidorI@i.com', 'Calle Real 555', 3000.00, 'PROCESO DE LIQUIDACION', '2023-09-12', 1500.00, 'Natural', 'Huancayo', 'Luis Vargas'),
('CL00010', 'Distribuidor J', 'Servicios J S.A.C.', '741258963', 'distribuidorJ@j.com', 'Av. Independencia 888', 9000.00, 'OPERATIVO CON MOVIMIENTO', '2023-10-01', 4500.00, 'Jurídica', 'Moquegua', 'Patricia Ruiz');
--POBLAMIENTO INCIAL MODULO ADMISION
-- Poblamiento inicial para la tabla Solicitante
INSERT INTO Solicitante (COD_SOLICITANTE, NOMBRE_SOL, RUC_SOL, DNI_SOL, UBICACION_SOL, CORREO_ELECTRONICO_SOL, TELEFONO_SOL) VALUES
('S001', 'Juan Pérez', '12345678912', '12345678', 'Av. Principal 123', 'juan.perez@example.com', '987654321'),
('S002', 'Ana Gómez', '12345678913', '87654321', 'Av. Secundaria 456', 'ana.gomez@example.com', '987654322'),
('S003', 'Luis Martínez', '12345678914', '23456789', 'Calle Tercera 789', 'luis.martinez@example.com', '987654323');

-- Poblamiento inicial para la tabla Solicitud
INSERT INTO Solicitud (COD_SOLICITUD, FECHA_INICIO_SOLICITUD, FECHA_FIN_SOLICITUD, ESTADO_SOLICITUD, TIPO_SOLICITUD, COD_SOLICITANTE) VALUES
('SOL001', '2024-01-01', '2024-01-05', 'PENDIENTE', 'DAC', 'S001'),
('SOL002', '2024-02-01', '2024-02-10', 'COMPLETADA', 'CAC', 'S002'),
('SOL003', '2024-03-01', '2024-03-15', 'CANCELADA', 'DAC', 'S003');

-- Poblamiento inicial para la tabla Documento_adm
INSERT INTO Documento_adm (COD_DOCUMENTO, NOMBRE_DOC, TIPO_DOC, RUTA_DOC, FECHA_RECIBIDO, VERSION, ID_SOLICITUD, COD_ANALISTA_CREDITO) VALUES
('DOC001', 'Solicitud de Crédito', 'PDF', '/docs/solicitud_credito.pdf', '2024-01-02', 1, 'SOL001', 'AC0001'), 
('DOC002', 'Contrato', 'PDF', '/docs/contrato.pdf', '2024-02-03', 1, 'SOL002', 'AC0002'), 
('DOC003', 'Informe de Evaluación', 'DOCX', '/docs/informe_evaluacion.docx', '2024-03-05', 1, 'SOL003', 'AC0003'), 
('DOC004', 'Carta de Aprobación', 'PDF', '/docs/carta_aprobacion.pdf', '2024-04-10', 1, 'SOL004', 'AC0004'), 
('DOC005', 'Reporte de Riesgo', 'PDF', '/docs/reporte_riesgo.pdf', '2024-05-12', 1, 'SOL005', 'AC0005'); 

-- Poblamiento inicial para la tabla Entrevista
INSERT INTO Entrevista (COD_ENTREVISTA, FECHA_ENTREVISTA, HORA_INICIO_ENTREVISTA, HORA_FIN_ENTREVISTA, RESULTADOS_ENTREVISTA, OBSERVACIONES_ENTREVISTA, COD_SOLICITUD) VALUES
('ENT001', '2024-01-03', '10:00:00', '10:30:00', 'Aprobada', 'El postulante mostró buena actitud.', 'SOL001'),
('ENT002', '2024-02-05', '11:00:00', '11:30:00', 'Rechazada', 'No cumplió con los requisitos.', 'SOL002'),
('ENT003', '2024-03-06', '09:00:00', '09:30:00', 'Pendiente', 'Se requiere más información.', 'SOL003');

-- Poblamiento inicial para la tabla Analista_admision
INSERT INTO Analista_admision (COD_ANALISTA_ADM, NOMBRE_AD, CORREO_ELECTRONICO_AD, TELEFONO_AD, DIRECCION, NUM_ACEPTADOS, NUM_RECHAZADOS, NUM_PENDIENTES, COD_SOL_ANALISTA_ADM) VALUES
('ANAL001', 'Carlos Ruiz', 'carlos.ruiz@example.com', '987654310', 'Calle Cuarta 123', 1, 0, 0, 'SOL_ANAL001'),
('ANAL002', 'María López', 'maria.lopez@example.com', '987654311', 'Calle Quinta 456', 0, 1, 0, 'SOL_ANAL002'),
('ANAL003', 'Pedro Fernández', 'pedro.fernandez@example.com', '987654312', 'Calle Sexta 789', 0, 0, 1, 'SOL_ANAL003');

-- Poblamiento inicial para la tabla Solicitud_Analista_admision
INSERT INTO Solicitud_Analista_admision (COD_SOL_ANALISTA_ADM, FECHA_INICIO, FECHA_FINAL, COD_ANALISTA_ADM, COD_SOLICITUD) VALUES
('SOL_ANAL001', '2024-01-01', '2024-01-10', 'ANAL001', 'SOL001'),
('SOL_ANAL002', '2024-02-01', '2024-02-15', 'ANAL002', 'SOL002'),
('SOL_ANAL003', '2024-03-01', '2024-03-20', 'ANAL003', 'SOL003');

-- Inserts para la tabla Analista_credito
INSERT INTO Analista_credito (COD_ANALISTA_AC, NOMBRE_AC, CORREO_AC, FECHA_CONTRATACION, TELEFONO_AC, DIRECCION_AC, ID_SUCURSAL, ESTADO_ANALISTA_AC) VALUES
('AC0001', 'Juan Pérez', 'juan.perez@empresa.com', '2023-01-10', '987654321', 'Calle 123', 'SUC001', 'activo'),
('AC0002', 'Maria Gomez', 'maria.gomez@empresa.com', '2023-02-15', '987654322', 'Calle 456', 'SUC002', 'activo'),
('AC0003', 'Luis Torres', 'luis.torres@empresa.com', '2023-03-20', '987654323', 'Calle 789', 'SUC003', 'inactivo'),
('AC0004', 'Ana Sánchez', 'ana.sanchez@empresa.com', '2023-04-25', '987654324', 'Calle 321', 'SUC004', 'activo'),
('AC0005', 'Carlos Díaz', 'carlos.diaz@empresa.com', '2023-05-30', '987654325', 'Calle 654', 'SUC005', 'inactivo');
