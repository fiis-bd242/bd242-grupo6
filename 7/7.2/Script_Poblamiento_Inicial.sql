
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
-- INSERT PARA LAS TABLAS 

--INSERT EQUIPOS Y RECARGAS 

-- Inserts para la tabla Cliente
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

-- Inserts para la tabla Recarga
INSERT INTO Recarga (COD_RECARGA, FECHA_SOLICITUD_RECARGA, MONTO_RECARGA, ESTADO_RECARGA, FECHA_LIBERACION_RECARGA) VALUES
('RC000001', '2023-01-20', 1000.00, 'VALIDADA', '2023-01-21'),
('RC000002', '2023-02-12', 500.00, 'PENDIENTE', NULL),
('RC000003', '2023-03-07', 1500.00, 'VALIDADA', '2023-03-08'),
('RC000004', '2023-04-22', 2000.00, 'RECHAZADA', NULL),
('RC000005', '2023-05-15', 2500.00, 'VALIDADA', '2023-05-16'),
('RC000006', '2023-06-25', 1200.00, 'PENDIENTE', NULL),
('RC000007', '2023-07-14', 800.00, 'VALIDADA', '2023-07-15'),
('RC000008', '2023-08-30', 3000.00, 'RECHAZADA', NULL),
('RC000009', '2023-09-01', 600.00, 'VALIDADA', '2023-09-02'),
('RC000010', '2023-10-05', 900.00, 'PENDIENTE', NULL);

-- Inserts para la tabla Pedido
INSERT INTO Pedido (COD_PEDIDO, FECHA_PEDIDO, CANTIDAD_TOTAL, ESTADO_PEDIDO, FECHA_ENTREGA, METODO_PAGO, OBSERVACIONES, DEMORA_PEDIDO, COD_CLIENTE, COD_RECARGA) VALUES
('PD000001', '2023-01-22', 10, 'COMPLETADO', '2023-01-25', 'Transferencia', 'Pedido completado con éxito.', 3, 'CL00001', 'RC000001'),
('PD000002', '2023-02-15', 5, 'CANCELADO', '2023-02-20', 'Efectivo', 'Pedido cancelado por falta de stock.', 0, 'CL00002', 'RC000002'),
('PD000003', '2023-03-10', 15, 'PENDIENTE', NULL, 'Tarjeta', 'En espera de aprobación.', 5, 'CL00003', 'RC000003'),
('PD000004', '2023-04-25', 7, 'PENDIENTE', NULL, 'Efectivo', 'En espera de validación.', 2, 'CL00004', 'RC000004'),
('PD000005', '2023-05-20', 12, 'COMPLETADO', '2023-05-22', 'Transferencia', 'Pedido completado.', 1, 'CL00005', 'RC000005'),
('PD000006', '2023-06-30', 20, 'COMPLETADO', '2023-07-01', 'Transferencia', 'Pedido procesado correctamente.', 0, 'CL00006', 'RC000006'),
('PD000007', '2023-07-10', 8, 'PENDIENTE', NULL, 'Efectivo', 'En espera de aprobación.', 4, 'CL00007', 'RC000007'),
('PD000008', '2023-08-15', 3, 'COMPLETADO', '2023-08-18', 'Tarjeta', 'Pedido completado.', 2, 'CL00008', 'RC000008'),
('PD000009', '2023-09-10', 5, 'PENDIENTE', NULL, 'Efectivo', 'En espera de validación.', 3, 'CL00009', 'RC000009'),
('PD000010', '2023-10-01', 9, 'COMPLETADO', '2023-10-05', 'Transferencia', 'Pedido finalizado.', 1, 'CL00010', 'RC000010');

-- Inserts para la tabla Equipo
INSERT INTO Equipo (COD_EQUIPO, NOMBRE_EQUIPO, MARCA, MODELO, CATEGORIA, PRECIO_UNITARIO, CANTIDAD_STOCK) VALUES
('EQ000001', 'Equipo A', 'Marca A', 'Modelo A1', 'Categoria A', 1000.00, 50),
('EQ000002', 'Equipo B', 'Marca B', 'Modelo B1', 'Categoria B', 1500.00, 30),
('EQ000003', 'Equipo C', 'Marca C', 'Modelo C1', 'Categoria C', 2000.00, 20),
('EQ000004', 'Equipo D', 'Marca D', 'Modelo D1', 'Categoria D', 2500.00, 10),
('EQ000005', 'Equipo E', 'Marca E', 'Modelo E1', 'Categoria E', 3000.00, 5),
('EQ000006', 'Equipo F', 'Marca F', 'Modelo F1', 'Categoria F', 1200.00, 25),
('EQ000007', 'Equipo G', 'Marca G', 'Modelo G1', 'Categoria G', 1800.00, 15),
('EQ000008', 'Equipo H', 'Marca H', 'Modelo H1', 'Categoria H', 2200.00, 8),
('EQ000009', 'Equipo I', 'Marca I', 'Modelo I1', 'Categoria I', 1400.00, 18),
('EQ000010', 'Equipo J', 'Marca J', 'Modelo J1', 'Categoria J', 1600.00, 12);

-- Inserts para la tabla Equipo_Pedido
INSERT INTO Pedido_Equipo (COD_PEDIDO_EQUIPO, COD_PEDIDO, COD_EQUIPO, CANTIDAD_PEDIDA) VALUES
('PE000001', 'PD000001', 'EQ000001', 5),
('PE000002', 'PD000001', 'EQ000002', 5),
('PE000003', 'PD000002', 'EQ000003', 5), 
('PE000004', 'PD000003', 'EQ000004', 10),
('PE000005', 'PD000003', 'EQ000005', 5);

-- Inserts para la tabla SAP
INSERT INTO SAP (COD_SAP, FECHA_VALIDACION, ESTADO_VALIDACION, OBSERVACION_VALIDACION, LIMITE_CREDITO, NUM_REFERENCIA_SAP_SUNAT, COD_PEDIDO) VALUES
('SAP0001', '2023-01-23', 'VALIDADA', 'Validación exitosa para el pedido PD000001.', 5000.00, 'REF0001', 'PD000001'),
('SAP0002', '2023-02-16', 'RECHAZADA', 'Pedido PD000002 rechazado.', 0.00, 'REF0002', 'PD000002'),
('SAP0003', '2023-03-11', 'VALIDADA', 'Validación exitosa para el pedido PD000003.', 8000.00, 'REF0003', 'PD000003');

-- Inserts para la tabla Factura
INSERT INTO Factura (COD_FACTURA, MONTO_FACTURA, FECHA_FACTURA, ESTADO_FACTURA, NUM_REFERENCIA_SUNAT, COD_SAP) VALUES
('FAC0001', 16000.00, '2023-01-26', 'EMITIDA', 'REF0001', 'SAP0001'),
('FAC0002', 0.00, '2023-02-21', 'ANULADA', 'REF0002', 'SAP0002'),  
('FAC0003', 15000.00, '2023-03-12', 'EMITIDA', 'REF0003', 'SAP0003');

--Inserts para la tabla SUNAT
INSERT INTO SUNAT (COD_SUNAT, FECHA_ASIGNACION, MONTO_SUNAT, NUM_REFERENCIA_SUNAT, COD_SAP) VALUES
('SUNAT0001', '2023-01-27', 16000.00, 'REF0001', 'SAP0001'),
('SUNAT0002', '2023-02-22', 0.00, 'REF0002', 'SAP0002'),  
('SUNAT0003', '2023-03-13', 15000.00, 'REF0003', 'SAP0003');

--INSERT LIQUIDACION

-- Inserts para la tabla Analista_credito
INSERT INTO Analista_credito (COD_ANALISTA_AC, NOMBRE_AC, CORREO_AC, FECHA_CONTRATACION, TELEFONO_AC, DIRECCION_AC, ID_SUCURSAL, ESTADO_ANALISTA_AC) VALUES
('AC0001', 'Juan Pérez', 'juan.perez@empresa.com', '2023-01-10', '987654321', 'Calle 123', 'SUC001', 'activo'),
('AC0002', 'Maria Gomez', 'maria.gomez@empresa.com', '2023-02-15', '987654322', 'Calle 456', 'SUC002', 'activo'),
('AC0003', 'Luis Torres', 'luis.torres@empresa.com', '2023-03-20', '987654323', 'Calle 789', 'SUC003', 'inactivo'),
('AC0004', 'Ana Sánchez', 'ana.sanchez@empresa.com', '2023-04-25', '987654324', 'Calle 321', 'SUC004', 'activo'),
('AC0005', 'Carlos Díaz', 'carlos.diaz@empresa.com', '2023-05-30', '987654325', 'Calle 654', 'SUC005', 'inactivo');

-- Inserts para la tabla Analista_soporte
INSERT INTO Analista_soporte (COD_ANALISTA_S, NOMBRE_S, CORREO_S, FECHA_CONTRATACION_S, TELEFONO_S, DIRECCION_S, ID_SUCURSAL_S) VALUES
('AS0001', 'Sofia Morales', 'sofia.morales@empresa.com', '2023-01-11', '987654326', 'Calle 987', 'SUC001'),
('AS0002', 'Pedro Jiménez', 'pedro.jimenez@empresa.com', '2023-02-16', '987654327', 'Calle 876', 'SUC002'),
('AS0003', 'Lucía Fernández', 'lucia.fernandez@empresa.com', '2023-03-21', '987654328', 'Calle 765', 'SUC003'),
('AS0004', 'Roberto Ramírez', 'roberto.ramirez@empresa.com', '2023-04-26', '987654329', 'Calle 654', 'SUC004'),
('AS0005', 'Elena Ruiz', 'elena.ruiz@empresa.com', '2023-05-31', '987654330', 'Calle 543', 'SUC005');

-- Inserts para la tabla Contrato
INSERT INTO Contrato (COD_CONTRATO, FECHA_INICIO, FECHA_FIN_NORMAL, FECHA_FIN_REAL, ESTADO_CONTRATO, COD_CLIENTE, COD_ANALISTA_S) VALUES
('CT0001', '2023-01-01', '2023-12-31', NULL, 'vigente', 'CL00003', 'AS0001'),
('CT0002', '2023-02-01', '2023-12-31', NULL, 'vigente', 'CL00004', 'AS0002'),
('CT0003', '2023-03-01', '2023-12-31', NULL, 'vigente', 'CL00009', 'AS0003'),
('CT0004', '2023-04-01', '2023-12-31', NULL, 'vigente', 'CL00005', 'AS0004'),
('CT0005', '2023-05-01', '2023-12-31', NULL, 'vigente', 'CL00006', 'AS0005');

-- Inserts para la tabla Liquidacion
INSERT INTO Liquidacion (COD_LIQUIDACION, FECHA_EMISION, FECHA_LIM_OBS, FECHA_FINALIZACION, MONTO_DEUDA_ACUM, MONTO_GARANTIAS, MONTO_COMISIONES, COD_CLIENTE, COD_ANALISTA_AC) VALUES
('LQ0001', '2023-01-05', '2023-01-10', NULL, 5000.00, 1000.00, 200.00, 'CL00003', 'AC0001'),
('LQ0002', '2023-02-05', '2023-02-10', NULL, 3000.00, 800.00, 150.00, 'CL00004', 'AC0002'),
('LQ0003', '2023-03-05', '2023-03-10', NULL, 1500.00, 500.00, 100.00, 'CL00009', 'AC0003'),
('LQ0004', '2023-04-05', '2023-04-10', NULL, 3500.00, 700.00, 120.00, 'CL00005', 'AC0004'),
('LQ0005', '2023-05-05', '2023-05-10', NULL, 2500.00, 600.00, 130.00, 'CL00006', 'AC0005');

-- Inserts para la tabla Observacion
INSERT INTO Observacion (COD_OBSERVACION, FECHA_OBS, FECHA_ABS, DESCRIPCION, COD_LIQUIDACION, COD_CLIENTE, COD_ANALISTA_AC) VALUES
('OBS0001', '2023-01-06', NULL, 'Primera observación de liquidación', 'LQ0001', 'CL00003', 'AC0001'),
('OBS0002', '2023-02-06', NULL, 'Segunda observación de liquidación', 'LQ0002', 'CL00004', 'AC0002'),
('OBS0003', '2023-03-06', NULL, 'Tercera observación de liquidación', 'LQ0003', 'CL00009', 'AC0003'),
('OBS0004', '2023-04-06', NULL, 'Cuarta observación de liquidación', 'LQ0004', 'CL00005', 'AC0004'),
('OBS0005', '2023-05-06', NULL, 'Quinta observación de liquidación', 'LQ0005', 'CL00006', 'AC0005');

--INSERT COBRANZA

-- Inserción en la tabla Analista_cobranza
INSERT INTO Analista_cobranza (COD_ANALISTA_COBRANZAS, NOMBRE_ANALISTA_COBRANZA, FECHA_DE_CONTRATACION_COBRANZA, TELEFONO_ANALISTA_COBRANZA, CORREO_ANALISTA_COBRANZA, REGION_ANALISTA_COBRANZA) VALUES
('AN00001', 'Carlos Pérez', '2022-01-10', '123456789', 'carlos.perez@cobranza.com', 'Lima'),
('AN00002', 'María González', '2022-02-15', '987654321', 'maria.gonzalez@cobranza.com', 'Arequipa'),
('AN00003', 'Juan Martínez', '2022-03-20', '456789123', 'juan.martinez@cobranza.com', 'Trujillo'),
('AN00004', 'Laura Fernández', '2022-04-25', '321654987', 'laura.fernandez@cobranza.com', 'Cusco'),
('AN00005', 'Javier Rodríguez', '2022-05-30', '147258369', 'javier.rodriguez@cobranza.com', 'Piura');

-- Inserción en la tabla Coordinador_Zonal
INSERT INTO Coordinador_Zonal (COD_COORDINADOR_ZONAL, NOMBRE_COORDINADOR, FECHA_CONTRATACION_COORDINADOR, TELEFONO_COORDINADOR, ZONA_ASIGNADA) VALUES
('CO00001', 'Pedro López', '2021-11-05', '852963741', 'Zona Norte'),
('CO00002', 'Ana Torres', '2021-12-10', '741258963', 'Zona Sur'),
('CO00003', 'Sofía Morales', '2022-01-15', '369258147', 'Zona Este'),
('CO00004', 'Fernando Díaz', '2022-02-20', '963852741', 'Zona Oeste'),
('CO00005', 'Claudia Ríos', '2022-03-25', '159753486', 'Zona Centro');

-- Inserción en la tabla Deuda
INSERT INTO Deuda (COD_DEUDA, ESTADO_DEUDA, MONTO_DEUDA, DIAS_RETRASO, ESTADO_COBRANZA, FECHA_VENCIMIENTO, COD_ANALISTA_COBRANZA, COD_CLIENTE, COD_COORDINADOR_ZONAL) VALUES
('DE00001', 'Atrasado', 1500.00, 30, 'Regular', '2024-09-01', 'AN00001', 'CL00001', 'CO00001'),
('DE00002', 'Atrasado', 2000.00, 15, 'Administrativa', '2024-09-05', 'AN00002', 'CL00002', 'CO00002'),
('DE00003', 'Al dia', 1000.00, 0, 'En fecha de pago', '2024-10-10', 'AN00003', 'CL00007', 'CO00003'),
('DE00004', 'Al dia', 1200.00, 5, 'En fecha de pago', '2024-10-05', 'AN00004', 'CL00008', 'CO00004'),
('DE00005', 'Atrasado', 500.00, 10, 'Regular', '2024-09-25', 'AN00005', 'CL00009', 'CO00005');

-- Inserción en la tabla Notificacion_cobranza
INSERT INTO Notificacion_cobranza (COD_NOTIFICACION_COBRANZA, FECHA_ENVIO, TIPO_NOTIFICACION, COD_COORDINADOR_ZONAL, COD_CLIENTE, COD_DEUDA) VALUES
('NC00001', '2024-09-02', 'Email', 'CO00001', 'CL00001', 'DE00001'),
('NC00002', '2024-09-06', 'Email', 'CO00002', 'CL00002', 'DE00002'),
('NC00003', '2024-10-11', 'SMS', 'CO00003', 'CL00007', 'DE00003'),
('NC00004', '2024-10-06', 'Llamada', 'CO00004', 'CL00008', 'DE00004'),
('NC00005', '2024-09-26', 'Carta', 'CO00005', 'CL00009', 'DE00005');

--INSERT ADMISION

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

