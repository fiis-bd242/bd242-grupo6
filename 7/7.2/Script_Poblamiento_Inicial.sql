
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
('CT000003', '2023-03-05', '2024-03-04', '2024-02-28', 'resuelto', 'CL00003', 'AS0001'),
('CT000004', '2023-04-20', '2025-04-19', '2024-12-15', 'resuelto', 'CL00004', 'AS0002'),
('CT000005', '2023-05-18', '2024-05-17', '2024-05-01', 'resuelto', 'CL00005', 'AS0003'),
('CT000006', '2023-06-15', '2026-06-14', '2024-07-30', 'resuelto', 'CL00006', 'AS0004'),
('CT000009', '2023-09-12', '2024-09-11', '2024-08-30', 'resuelto', 'CL00009', 'AS0005');

-- Liquidaciones para clientes liquidados (Distribuidor E y F)
INSERT INTO Liquidacion (COD_LIQUIDACION, FECHA_EMISION, TIPO_LIQ, FECHA_LIM_OBS, FECHA_FINALIZACION, MONTO_DEUDA_ACUM, MONTO_GARANTIAS, MONTO_COMISIONES, COD_CLIENTE, COD_ANALISTA_AC) VALUES
('LQ0001', '2024-05-05', 'pre-liquidacion', '2024-07-04', '2024-11-01', 3500.00, 1750.00, 100.00, 'CL00005', 'AC0004'),
('LQ0002', '2024-11-01', 'liquidacion final', '2024-11-06', '2024-11-11', 3500.00, 1750.00, 100.00, 'CL00005', 'AC0004'),
('LQ0003', '2024-08-05', 'pre-liquidacion', '2024-10-04', '2025-02-01', 2000.00, 1000.00, 150.00, 'CL00006', 'AC0001'),
('LQ0004', '2025-02-01', 'liquidacion final', '2025-02-06', '2025-02-11', 2000.00, 1000.00, 150.00, 'CL00006', 'AC0001');

-- Liquidaciones para clientes en proceso de liquidación (Distribuidor C, D e I)
INSERT INTO Liquidacion (COD_LIQUIDACION, FECHA_EMISION, TIPO_LIQ, FECHA_LIM_OBS, FECHA_FINALIZACION, MONTO_DEUDA_ACUM, MONTO_GARANTIAS, MONTO_COMISIONES, COD_CLIENTE, COD_ANALISTA_AC) VALUES
('LQ0005', '2024-03-04', 'pre-liquidacion', '2024-05-03', '2024-08-31', 8000.00, 4000.00, 200.00, 'CL00003', 'AC0002'),
('LQ0006', '2024-12-25', 'pre-liquidacion', '2025-02-23', '2025-06-23', 6000.00, 3000.00, 150.00, 'CL00004', 'AC0004'),
('LQ0007', '2024-09-07', 'pre-liquidacion', '2024-11-06', '2025-03-06', 1500.00, 200.00, 50.00, 'CL00009', 'AC0001'),
('LQ0008', '2025-03-06', 'liquidacion final', '2025-03-11', '2025-03-16', 1500.00, 200.00, 50.00, 'CL00009', 'AC0001');

-- Observaciones para clientes liquidados y en proceso de liquidación
INSERT INTO Observacion (COD_OBSERVACION, FECHA_OBS, FECHA_ABS, DESCRIPCION, COD_LIQUIDACION, COD_CLIENTE, COD_ANALISTA_AC) VALUES
('OBS0001', '2024-06-01', '2024-06-02', 'Observación sobre la pre-liquidación.', 'LQ0001', 'CL00005', 'AC0004'),  -- Observación para Distribuidor E sobre su pre-liquidación
('OBS0002', '2024-09-01', '2024-09-02', 'Observación sobre la pre-liquidación.', 'LQ0003', 'CL00006', 'AC0001'),  -- Observación para Distribuidor F sobre su pre-liquidación
('OBS0003', '2025-02-05', '2025-02-06', 'Observación sobre la liquidación final.', 'LQ0004', 'CL00006', 'AC0001'),  -- Observación para Distribuidor F sobre su liquidación final
('OBS0004', '2024-12-30', '2024-12-31', 'Observación sobre la pre-liquidación.', 'LQ0006', 'CL00004', 'AC0004'),  -- Observación para Distribuidor D sobre su pre-liquidación
('OBS0005', '2025-03-10', '2025-03-11', 'Observación sobre la liquidación final.', 'LQ0008', 'CL00009', 'AC0001');  -- Observación para Distribuidor I sobre su liquidación final

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
INSERT INTO Documento_adm (COD_DOCUMENTO, NOMBRE_DOC, TIPO_DOC, RUTA_DOC, FECHA_RECIBIDO, VERSION, COD_SOLICITUD, COD_ANALISTA_CREDITO) VALUES
('DOC001', 'Solicitud de Crédito', 'PDF', '/docs/solicitud_credito.pdf', '2024-01-02', 1, 'SOL001', 'ANAL001'),
('DOC002', 'Contrato', 'PDF', '/docs/contrato.pdf', '2024-02-03', 1, 'SOL002', 'ANAL002'),
('DOC003', 'Informe de Evaluación', 'DOCX', '/docs/informe_evaluacion.docx', '2024-03-05', 1, 'SOL003', 'ANAL003');

-- Poblamiento inicial para la tabla Entrevista
INSERT INTO Entrevista (COD_ENTREVISTA, FECHA_ENTREVISTA, HORA_INICIO_ENTREVISTA, HORA_FIN_ENTREVISTA, RESULTADOS_ENTREVISTA, OBSERVACIONES_ENTREVISTA, COD_SOLICITUD) VALUES
('ENT001', '2024-01-03', '10:00:00', '10:30:00', 'Aprobada', 'El postulante mostró buena actitud.', 'SOL001'),
('ENT002', '2024-02-05', '11:00:00', '11:30:00', 'Rechazada', 'No cumplió con los requisitos.', 'SOL002'),
('ENT003', '2024-03-06', '09:00:00', '09:30:00', 'Pendiente', 'Se requiere más información.', 'SOL003');

-- Poblamiento inicial para la tabla Analista_admision
INSERT INTO Analista_admision (COD_ANALISTA_ADM, NOMBRE_AD, CORREO_ELECTRONICO_AD, TELEFONO_AD, DIRECCION, NUM_ACEPTADOS, NUM_RECHAZADOS, NUM_PENDIENTES) VALUES
('ANAL001', 'Carlos Ruiz', 'carlos.ruiz@example.com', '987654310', 'Calle Cuarta 123', 1, 0, 0),
('ANAL002', 'María López', 'maria.lopez@example.com', '987654311', 'Calle Quinta 456', 0, 1, 0),
('ANAL003', 'Pedro Fernández', 'pedro.fernandez@example.com', '987654312', 'Calle Sexta 789', 0, 0, 1);

-- Poblamiento inicial para la tabla Solicitud_Analista_admision
INSERT INTO Solicitud_Analista_admision (COD_SOL_ANALISTA_ADM, FECHA_INICIO, FECHA_FINAL, COD_ANALISTA_ADM, COD_SOLICITUD) VALUES
('SOL_ANAL001', '2024-01-01', '2024-01-10', 'ANAL001', 'SOL001'),
('SOL_ANAL002', '2024-02-01', '2024-02-15', 'ANAL002', 'SOL002'),
('SOL_ANAL003', '2024-03-01', '2024-03-20', 'ANAL003', 'SOL003');


--INSERT CREDITO EN FINANCIAMIENTO

-- Poblamiento inicial para la tabla Solicitud de Credito
INSERT INTO Solicitud_Credito (COD_SOLICITUD, FECHA_SOLICITUD, COD_CLIENTE, DOCUMENTOS, MONTO_SOLICITADO, ESTADO_SOLICITUD, FECHA_APROBACION, TIPO_CREDITO) VALUES
('SOL0000001', '2024-04-21', 'CL00001', 'TEXT1.PDF', '1500.00', 'EN REVISION', '2024-04-22', 'PERSONAL'),
('SOL0000002', '2024-05-25', 'CL00002', 'TEXT2.PDF', '5000.00', 'APROBADO', '2024-05-26', 'PERSONAL'),
('SOL0000003', '2024-06-27', 'CL00003', 'TEXT3.PDF', '3000.00', 'RECHAZADO', '2024-04-28', 'HIPOTECARIO');

-- Poblamiento inicial para la tabla Credito
INSERT INTO Credito (COD_CREDITO, TASA_INTERES, COD_SOLICITUD, PLAZO_CREDITO, MONTO_TOTAL, TIPO_CREDITO, TASA_MORA, ESTADO_CREDITO, COD_DESEMBOLSO) VALUES
('CRE000001', '5.25%', 'SOL0000001', '12', '5000.00', 'PERSONAL','8.25%', 'ACTIVO', 'DES0001'),
('CRE000002', '10.50%', 'SOL0000002', '06', '7500.00', 'PERSONAL','5.25%', 'EN MORA', 'DES0002'),
('CRE000003', '7.50%', 'SOL0000003', '18', '2500.00', 'HIPOTECARIO','11.50%', 'PAGADO', 'DES0003');

-- Poblamiento inicial para la tabla Pago
INSERT INTO Pago (COD_PAGO, FECHA_PAGO, METODO_PAGO, MONTO_PAGO, COD_CREDITO, ESTADO_PAGO) VALUES
('P00001', '2024-01-01', 'TRANSFERENCIA', '1200.00', 'CRE000001', 'PENDIENTE'), 
('P00002', '2024-02-02', 'CHEQUE', '2000.00', 'CRE000002', 'COMPLETADO'), 
('P00003', '2024-02-03', 'EFECTIVO', '2500.00', 'CRE000003', 'RECHAZADO');

-- Poblamiento inicial para la tabla Departamento_Desembolso
INSERT INTO Departamento_Desembolso (COD_DESEMBOLSO, FECHA_DESEMBOLSO, METODO_ABONADO, MONTO_TOTAL) VALUES
('DES0001', '2024-01-03', 'TRANSFERENCIA', '10000.00'),
('DES0002', '2024-02-07', 'TRANSFERENCIA', '15000.00'),
('DES0003', '2024-03-08', 'CHEQUE', '25000.00');

-- Poblamiento inicial para la tabla Oficial_Credito
INSERT INTO Oficial_Credito (COD_OFICIAL, NOMBRE_CRED, CORREO_CRED, COD_SOLICITUD, TELEFONO_CRED, DIRECCION_CRED, ID_SUCURSAL, ESTADO_OFICIAL, FECHA_CONTRATACION) VALUES
('OFIC001', 'Miguel Ruiz', 'miguel.ruiz@example.com', 'SOL0000001', '987654313', 'Avenida 123', 'SUCUR001', '2024-07-15'),
('OFIC002', 'Sharon López', 'sharon.lopez@example.com', 'SOL0000002', '987654315', 'Avenida 456', 'SUCUR002', '2024-08-01'),
('OFIC003', 'Jennifer Miranda', 'jennifer.miranda@example.com', 'SOL0000003','987654317', 'Avenida 789', 'SUCUR003', '2024-05-15');

---Inserts para la tabla Analista_cobranza
INSERT INTO Analista_cobranza (COD_ANALISTA_COBRANZAS, NOMBRE_ANALISTA_COBRANZA, FECHA_DE_CONTRATACION_COBRANZA, TELEFONO_ANALISTA_COBRANZA, CORREO_ANALISTA_COBRANZA, REGION_ANALISTA_COBRANZA)
VALUES
('ANL000001', 'Analista 1', '2022-01-15', '999111222', 'analista1@cobranza.com', 'Lima'),
('ANL000002', 'Analista 2', '2021-06-20', '999333444', 'analista2@cobranza.com', 'Cusco'),
('ANL000003', 'Analista 3', '2020-05-18', '999555666', 'analista3@cobranza.com', 'Arequipa'),
('ANL000004', 'Analista 4', '2022-11-30', '999777888', 'analista4@cobranza.com', 'Piura'),
('ANL000005', 'Analista 5', '2023-03-22', '999888999', 'analista5@cobranza.com', 'Trujillo');

INSERT INTO Coordinador_Zonal (COD_COORDINADOR_ZONAL, NOMBRE_COORDINADOR, FECHA_CONTRATACION_COORDINADOR, TELEFONO_COORDINADOR, ZONA_ASIGNADA)
VALUES
('COZ0000001', 'Coordinador 1', '2020-02-01', '911111111', 'Lima'),
('COZ0000002', 'Coordinador 2', '2019-07-15', '922222222', 'Cusco'),
('COZ0000003', 'Coordinador 3', '2018-09-10', '933333333', 'Arequipa'),
('COZ0000004', 'Coordinador 4', '2021-01-25', '944444444', 'Piura'),
('COZ0000005', 'Coordinador 5', '2022-03-10', '955555555', 'Trujillo');

INSERT INTO Deuda (COD_DEUDA, ESTADO_DEUDA, MONTO_DEUDA, DIAS_RETRASO, ESTADO_COBRANZA, FECHA_VENCIMIENTO, COD_ANALISTA_COBRANZA, COD_CLIENTE, COD_COORDINADOR_ZONAL)
VALUES
('DEU00000001', 'Atrasado', 5000.00, 120, 'Prejudicial', '2024-06-11', 'ANL000001', 'CL00003', 'COZ0000001'),
('DEU00000002', 'Atrasado', 3000.00, 90, 'Administrativa', '2024-07-11', 'ANL000002', 'CL00004', 'COZ0000005'),
('DEU00000003', 'Al dia', 8000.00, 0, 'En fecha de pago', '2024-10-09', 'ANL000003', 'CL00001', 'COZ0000003'),
('DEU00000005', 'Atrasado', 7000.00, 60, 'Regular', '2024-08-10', 'ANL000002', 'CL00009', 'COZ0000002'),

INSERT INTO Notificacion_cobranza (COD_NOTIFICACION_COBRANZA, FECHA_ENVIO, TIPO_NOTIFICACION, COD_COORDINADOR_ZONAL, COD_CLIENTE, COD_DEUDA)
VALUES
('NOTC0001', '2024-08-15', 'Correo electrónico', 'COOR000002', 'CL00009', 'DEU00000005'),
('NOTC0002', '2024-09-10', 'Llamada telefónica', 'COOR000002', 'CL00009', 'DEU00000005');
('NOTC0003', '2024-07-15', 'Correo electrónico', 'COZ0000005', 'CL00004', 'DEU00000002'),
('NOTC0004', '2024-08-01', 'Llamada telefónica', 'COZ0000005', 'CL00004', 'DEU00000002'),
('NOTC005', '2024-08-15', 'Visita presencial', 'COZ0000005', 'CL00004', 'DEU00000002'),
('NOTC006', '2024-09-01', 'Carta de cobranza', 'COZ0000005', 'CL00004', 'DEU00000002');
('NOTC007', '2024-06-15', 'Correo electrónico', 'COZ0000001', 'CL00003', 'DEU00000001'),
('NOTC008', '2024-07-01', 'Llamada telefónica', 'COZ0000001', 'CL00003', 'DEU00000001'),
('NOTC009', '2024-07-15', 'Visita presencial', 'COZ0000001', 'CL00003', 'DEU00000001'),
('NOTC010', '2024-08-01', 'Carta de cobranza', 'COZ0000001', 'CL00003', 'DEU00000001'),
('NOTC011', '2024-09-01', 'Derivación a área legal', 'COZ0000001', 'CL00003', 'DEU00000001');

-- Insert para modulos de equipos y modulo de recargas (Correciones)
-- En este caso se realiza las correcciones y se detalla mas el funcionamiento y relacion de las tablas:

-- Insert Cliente

INSERT INTO Cliente (COD_CLIENTE, NOMBRE, RAZON_SOCIAL, TELEFONO, CORREO_EMPRESA, DIRECCION_CLIENTE, CREDITO_MAXIMO, ESTADO_CLIENTE, FECHA_REGISTRO, LINEA_CREDITO, CLASE_PERSONA, REGION, REP_LEGAL) VALUES
('CL00001', 'Distribuidor A', 'Distribuciones A S.A.C.', '923456789', 'distribuidora@a.com', 'Av. Siempre Viva 123', 5000, 'OPERATIVO CON MOVIMIENTO', '2023-01-15', 2500, 'Jurídica', 'Lima', 'Juan Pérez'),
('CL00002', 'Distribuidor B', 'Suministros B E.I.R.L.', '987654321', 'distribuidorb@b.com', 'Calle Falsa 456', 3000, 'OPERATIVO SIN MOVIMIENTO', '2023-02-10', 1500, 'Jurídica', 'Cusco', 'María López'),
('CL00003', 'Distribuidor C', 'Importaciones C S.A.C.', '956789123', 'distribuidorC@c.com', 'Av. Central 789', 8000, 'PROCESO DE LIQUIDACION', '2023-03-05', 4000, 'Natural', 'Arequipa', 'Carlos García'),
('CL00004', 'Distribuidor D', 'Servicios D S.A.C.', '921654987', 'distribuidoresD@d.com', 'Calle Verde 321', 6000, 'PROCESO DE LIQUIDACION', '2023-04-20', 3000, 'Jurídica', 'Piura', 'Luisa Sánchez'),
('CL00005', 'Distribuidor E', 'Productos E S.A.', '923123123', 'distribuidore@e.com', 'Av. Libertad 111', 0, 'LIQUIDADO', '2023-05-18', 0, 'Natural', 'Trujillo', 'Alberto Castillo'),
('CL00006', 'Distribuidor F', 'Comercial F E.I.R.L.', '987987987', 'distribuidorF@f.com', 'Av. Puno 333', 0, 'LIQUIDADO', '2023-06-15', 0, 'Jurídica', 'Iquitos', 'Ana Martínez'),
('CL00007', 'Distribuidor G', 'Distribuciones G S.A.C.', '947258369', 'distribuidorg@g.com', 'Calle Lima 222', 2000, 'OPERATIVO CON MOVIMIENTO', '2023-07-10', 1000, 'Natural', 'Tacna', 'Pedro Jiménez'),
('CL00008', 'Distribuidor H', 'Suministros H E.I.R.L.', '963258741', 'distribuidorH@h.com', 'Av. Arequipa 444', 5000, 'OPERATIVO SIN MOVIMIENTO', '2023-08-22', 2500, 'Jurídica', 'Chiclayo', 'Gabriela Torres'),
('CL00009', 'Distribuidor I', 'Importaciones I S.A.C.', '952369741', 'distribuidorI@i.com', 'Calle Real 555', 3000, 'PROCESO DE LIQUIDACION', '2023-09-12', 1500, 'Natural', 'Huancayo', 'Luis Vargas'),
('CL00010', 'Distribuidor J', 'Servicios J S.A.C.', '941258963', 'distribuidorJ@j.com', 'Av. Independencia 888', 9000, 'OPERATIVO CON MOVIMIENTO', '2023-10-01', 4500, 'Jurídica', 'Moquegua', 'Patricia Ruiz');

--Insert Pedido

INSERT INTO Pedido (COD_PEDIDO, COD_CLIENTE, FECHA_REG_PEDIDO, FECHA_EVALUACION, ESTADO_PEDIDO, METODO_PAGO, OBSERVACIONES, TIPO_PEDIDO) VALUES
('PD000001', 'CL00001', '2024-01-05', '2024-01-07', 'Aceptado', 'Crédito', 'Aceptado', 'Equipo'),
('PD000002', 'CL00001', '2024-01-10', '2024-01-12', 'Aceptado', 'Contado', 'Aceptado', 'Equipo'),
('PD000003', 'CL00002', '2024-01-15', '2024-01-17', 'Aceptado', 'Crédito', 'Aceptado', 'Recarga'),
('PD000004', 'CL00001', '2024-01-20', '2024-01-22', 'Rechazado', 'Transferencia', 'Credito insuficiente', 'Recarga'),
('PD000005', 'CL00002', '2024-01-25', '2024-01-27', 'Rechazado', 'Contado', 'Credito insuficiente', 'Equipo'),
('PD000006', 'CL00003', '2024-02-01', '2024-02-03', 'Rechazado', 'Crédito', 'En proceso de liquidacion', 'Equipo'),
('PD000007', 'CL00004', '2024-02-05', '2024-02-07', 'Rechazado', 'Contado', 'En proceso de liquidacion', 'Equipo'),
('PD000008', 'CL00005', '2024-02-10', '2024-02-12', 'Rechazado', 'Transferencia', 'Liquidado', 'Recarga'),
('PD000009', 'CL00006', '2024-02-15', '2024-02-17', 'Rechazado', 'Crédito', 'Liquidado', 'Equipo'),
('PD000010', 'CL00004', '2024-02-20', '2024-02-22', 'Rechazado', 'Contado', 'En proceso de liquidacion', 'Equipo'),
('PD000011', 'CL00007', '2024-03-01', '2024-03-03', 'Aceptado', 'Crédito', 'Aceptado', 'Recarga'),
('PD000012', 'CL00008', '2024-03-05', '2024-03-07', 'Rechazado', 'Transferencia', 'Deuda pendiente', 'Equipo'),
('PD000013', 'CL00002', '2024-03-10', '2024-03-12', 'Rechazado', 'Contado', 'Credito insuficiente', 'Recarga'),
('PD000014', 'CL00009', '2024-03-15', '2024-03-17', 'Rechazado', 'Crédito', 'En proceso de liquidacion', 'Recarga'),
('PD000015', 'CL00004', '2024-03-20', '2024-03-22', 'Rechazado', 'Transferencia', 'En proceso de liquidacion', 'Recarga'),
('PD000016', 'CL00006', '2024-03-25', '2024-03-27', 'Rechazado', 'Contado', 'Liquidado', 'Equipo'),
('PD000017', 'CL00007', '2024-04-01', '2024-04-03', 'Aceptado', 'Crédito', 'Aceptado', 'Equipo'),
('PD000018', 'CL00008', '2024-04-05', '2024-04-07', 'Rechazado', 'Transferencia', 'Deuda pendiente', 'Equipo'),
('PD000019', 'CL00009', '2024-04-10', '2024-04-12', 'Rechazado', 'Contado', 'En proceso de liquidacion', 'Recarga'),
('PD000020', 'CL00010', '2024-04-15', '2024-04-17', 'Aceptado', 'Crédito', 'Aceptado', 'Recarga');

--Los clientes que se encuentran en ESTADO_PEDIDO: "En proceso de liquidcacion y Liquidado" no pueden realizar pedidos, automaticamente se les rechaza.
-- Las observaciones se alineas a los estados del cliente.ATTACH
-- Hay una diferenciacion en el pedido donde se divide por tipo (Recarga o Equipo), son pedidos individuales que se reciben.

-- Insert Recarga

INSERT INTO Recarga (COD_RECARGA, COD_PEDIDO, FECHA_SOLICITUD_RECARGA, MONTO_RECARGA, ESTADO_RECARGA, FECHA_LIBERACION_RECARGA) VALUES
('RC000001', 'PD000003', '2024-01-15', 1000.00, 'Aceptado', '2024-01-17'),
('RC000002', 'PD000004', '2024-01-20', 100.00, 'Rechazado', NULL),
('RC000003', 'PD000008', '2024-02-10', 2000.00, 'Rechazado', NULL),
('RC000004', 'PD000011', '2024-03-01', 500.00, 'Aceptado', '2024-03-03'),
('RC000005', 'PD000013', '2024-03-10', 300.00, 'Rechazado', NULL),
('RC000006', 'PD000015', '2024-03-20', 500.00, 'Rechazado', NULL),
('RC000007', 'PD000019', '2024-04-10', 190.00, 'Rechazado', NULL),
('RC000008', 'PD000020', '2024-04-15', 2000.00, 'Aceptado', '2024-04-17');

-- Insert Equipo

INSERT INTO Equipo (COD_EQUIPO, NOMBRE_EQUIPO, MARCA, MODELO, CATEGORIA, PRECIO_UNITARIO, CANTIDAD_STOCK) VALUES
('87654321', 'Router Huawei WiFi 6', 'Huawei', 'AX3', 'Router', 350.00, 120),
('34567890', 'Modem Claro 4G LTE', 'Claro', 'LTE X500', 'Modem', 500.00, 75),
('12348765', 'Claro Mifi Portable', 'Claro', 'E5576', 'Router Portátil', 300.00, 90),
('87651234', 'Cargador Claro Rápido', 'Claro', 'EP-TA20', 'Accesorios', 180.00, 100),
('23454321', 'Claro SIM Prepago', 'Claro', 'Prepago', 'Telefonía Prepago', 20.00, 500),
('34565432', 'Modem Huawei Claro LTE', 'Huawei', 'B310s', 'Modem', 450.00, 70),
('56787654', 'Audífonos Inalámbricos Claro', 'Claro', 'BTHS200', 'Accesorios', 200.00, 85),
('67899876', 'Adaptador Claro para Cable Ethernet', 'Claro', 'ADAPT-ETH', 'Accesorios', 80.00, 150),
('78901234', 'Claro SIM Chip Postpago', 'Claro', 'Postpago', 'Telefonía Postpago', 25.00, 400),
('89012345', 'Claro Power Bank 10000mAh', 'Claro', 'PB10000', 'Accesorios', 300.00, 60);

-- Insert Pedido_Equipo

INSERT INTO Pedido_Equipo (COD_PEDIDO_EQUIPO, COD_PEDIDO, COD_EQUIPO, CANTIDAD_PEDIDA) VALUES
('PEQ00001', 'PD000001', '56787654', 2),
('PEQ00002', 'PD000001', '23456789', 3),
('PEQ00003', 'PD000002', '56789012', 1),
('PEQ00004', 'PD000002', '34567890', 4),
('PEQ00005', 'PD000006', '87654321', 4),
('PEQ00006', 'PD000007', '12345678', 2),
('PEQ00007', 'PD000009', '23456789', 5),
('PEQ00008', 'PD000010', '56789012', 3),
('PEQ00009', 'PD000017', '34567890', 2),
('PEQ00010', 'PD000016', '87654321', 7),
('PEQ00011', 'PD000018', '87653321', 2);

-- La relacion de equipo y pedido es de muchos a muchos y se crea esta tabla para poder reducir esa complejidad y gestionar mejor los pedidos de equipos.

-- Insert Notificacion

INSERT INTO Notificacion (COD_NOTIFICACION, COD_PEDIDO, FECHA_NOTIFICACION, OBSERVACION_NOTIFICACION, TIPO_NOTIFICACION) VALUES
('N0001', 'PD000001', '2024-01-07', 'Se acepto su Equipo con exito.', 'Aceptado'),
('N0002', 'PD000002', '2024-01-12', 'Se acepto su Equipo con exito.', 'Aceptado'),
('N0003', 'PD000003', '2024-01-17', 'Se acepto su Recarga con exito.', 'Aceptado'),
('N0004', 'PD000004', '2024-01-22', 'Se ha rechazado su Recarga debido a Credito insuficiente.', 'Rechazado'),
('N0005', 'PD000005', '2024-01-27', 'Se ha rechazado su Equipo debido a Credito insuficiente.', 'Rechazado'),
('N0006', 'PD000006', '2024-02-03', 'Se ha rechazado su Equipo debido a En proceso de liquidacion.', 'Rechazado'),
('N0007', 'PD000007', '2024-02-07', 'Se ha rechazado su Equipo debido a En proceso de liquidacion.', 'Rechazado'),
('N0008', 'PD000008', '2024-02-12', 'Se ha rechazado su Recarga debido a Liquidado.', 'Rechazado'),
('N0009', 'PD000009', '2024-02-17', 'Se ha rechazado su Equipo debido a Liquidado.', 'Rechazado'),
('N0010', 'PD000010', '2024-02-22', 'Se ha rechazado su Equipo debido a Liquidado.', 'Rechazado'),
('N0011', 'PD000011', '2024-03-03', 'Se acepto su Recarga con exito.', 'Aceptado'),
('N0012', 'PD000012', '2024-03-07', 'Se ha rechazado su Equipo debido a Deuda pendiente.', 'Rechazado'),
('N0013', 'PD000013', '2024-03-12', 'Se ha rechazado su Recarga debido a Credito insuficiente.', 'Rechazado'),
('N0014', 'PD000014', '2024-03-17', 'Se ha rechazado su Recarga debido a En proceso de liquidacion.', 'Rechazado'),
('N0015', 'PD000015', '2024-03-22', 'Se ha rechazado su Recarga debido a En proceso de liquidacion.', 'Rechazado'),
('N0016', 'PD000016', '2024-03-27', 'Se ha rechazado su Equipo debido a Liquidado.', 'Rechazado'),
('N0017', 'PD000017', '2024-04-03', 'Se acepto su Equipo con exito.', 'Aceptado'),
('N0018', 'PD000018', '2024-04-07', 'Se ha rechazado su Equipo debido a Deuda pendiente.', 'Rechazado'),
('N0019', 'PD000019', '2024-04-12', 'Se ha rechazado su Recarga debido a En proceso de liquidacion.', 'Rechazado'),
('N0020', 'PD000020', '2024-04-17', 'Se acepto su Recarga con exito.', 'Aceptado');

-- Em base al proceso de evaluacion se notifica al cliente si su pedido fue aprobado o rechazo y se le justifica el porque.

-- Insert Factura

INSERT INTO Factura (COD_FACTURA, COD_PEDIDO, MONTO_FACTURA, FECHA_FACTURA, NUM_REFERENCIA_SUNAT) VALUES
('F00001', 'PD000001', 1000, '2024-01-08', '12345678'),
('F00002', 'PD000002', 500, '2024-01-13', '87654321'),
('F00003', 'PD000003', 1000, '2024-01-18', '23456789'),
('F00004', 'PD0010011', 500, '2024-03-04', '45678901'),
('F00007', 'PD001007', 500, '2024-04-04', '89012345'),
('F00009', 'PD002000', 2000, '2024-04-18', '11234567');

-- La Factura solo registra los pedidos que fueron aprobados y registra NUM_REFERENCIA_SUNAT que sirve para referencia la factura en el registro de SUNAT.
