SELECT 
    p.COD_SOLICITUD, 
    p.COD_CLIENTE, 
    c.NOMBRE, 
    p.ESTADO_SOLICITUD, 
    p.FECHA_SOLICITUD
FROM Cliente c
JOIN Solicitud p ON c.COD_CLIENTE = p.COD_CLIENTE
WHERE c.ESTADO_SOLICITUD IN ('EN REVISION', 'APROBADO', 'RECHAZADO')
  AND p.TIPO_CREDITO = 'PERSONAL';



CREATE OR REPLACE FUNCTION solicitud_credito()
RETURNS TABLE(
    COD_SOLICITUD VARCHAR(10), 
    COD_CLIENTE VARCHAR(7), 
    NOMBRE VARCHAR(100), 
    ESTADO_SOLICITUD VARCHAR(10), 
    FECHA_SOLICITUD DATE
) AS
$$
BEGIN
    RETURN QUERY
    SELECT p.COD_SOLICITUD, 
           p.COD_CLIENTE, 
           c.NOMBRE, 
           p.ESTADO_SOLICITUD, 
           p.FECHA_SOLICITUD
    FROM Cliente c
    JOIN Solicitud p ON c.COD_CLIENTE = p.COD_CLIENTE
    WHERE c.ESTADO_SOLICITUD IN ('EN REVISION', 'APROBADO', 'RECHAZADO')
      AND p.TIPO_CREDITO = 'PERSONAL'
    ORDER BY p.FECHA_SOLICITUD DESC, p.COD_SOLICITUD DESC; 
END;
$$ LANGUAGE plpgsql;

SELECT * FROM solicitud_credito();

CREATE OR REPLACE FUNCTION buscar_solicitud(filtro text, valor text)
RETURNS TABLE (
    COD_SOLICITUD VARCHAR(10),
    COD_CLIENTE VARCHAR(7),
    NOMBRE TEXT,
    ESTADO_SOLICITUD VARCHAR(10),
    FECHA_SOLICITUD DATE
) AS $$
BEGIN
    RETURN QUERY
    EXECUTE format(
        'SELECT p.COD_SOLICITUD, p.COD_CLIENTE, c.NOMBRE, p.ESTADO_SOLICITUD, p.FECHA_SOLICITUD
         FROM Solicitud p
         JOIN Cliente c ON p.COD_CLIENTE = c.COD_CLIENTE
         WHERE %I ILIKE %L', filtro, '%' || valor || '%');
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION buscar_solicitud(text,text)


--- segunda interfaz

DROP FUNCTION IF EXISTS detalles_solicitud(VARCHAR);

CREATE OR REPLACE FUNCTION detalles_solicitud(cod_solicitud1 VARCHAR)
RETURNS TABLE(
    COD_SOLICITUD VARCHAR(10),
    COD_CLIENTE VARCHAR(7),
    FECHA_SOLICITUD DATE,
    ESTADO_SOLICITUD VARCHAR(10),
    MONTO_SOLICITADO VARCHAR(15),
    OBSERVACIONES VARCHAR(50),
    NOMBRE VARCHAR(100),
    LINEA_CREDITO DECIMAL(10, 2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.COD_SOLICITUD, p.COD_CLIENTE, p.FECHA_SOLICITUD, p.ESTADO_SOLICITUD, 
           p.MONTO_SOLICITADO, p.OBSERVACIONES,
           c.NOMBRE, c.LINEA_CREDITO
    FROM Solicitud p
    JOIN Cliente c ON p.COD_CLIENTE = c.COD_CLIENTE
    WHERE p.COD_SOLICITUD = cod_solicitud1;
END;
$$ LANGUAGE plpgsql;

-- actualizar observaciones

CREATE OR REPLACE FUNCTION actualizar_observaciones(
    p_cod_solicitud VARCHAR, 
    p_act_observacion TEXT
) RETURNS VOID AS $$
BEGIN
    UPDATE Solicitud
    SET OBSERVACIONES = p_act_observacion
    WHERE COD_SOLICITUD = p_cod_solicitud; 
END;
$$ LANGUAGE plpgsql;


-- actualizar estado solicitud

CREATE OR REPLACE FUNCTION actualizar_estado_solicitud(
    p_cod_solicitud VARCHAR, 
    p_act_estado VARCHAR
) RETURNS VOID AS $$
BEGIN
    UPDATE Solicitud
    SET ESTADO_SOLICITUD = p_act_estado
    WHERE COD_SOLICITUD = p_cod_solicitud; 
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION actualizar_estado_solicitud


SELECT * FROM detalles_solicitud('SOL0000007');


CREATE OR REPLACE FUNCTION obtener_credito_por_cliente(p_cod_credito character varying)
RETURNS TABLE (
    COD_CREDITO VARCHAR, 
    TIPO_CREDITO VARCHAR,
    PLAZO_CREDITO VARCHAR,
    MONTO_TOTAL DECIMAL(8, 2),
    TASA_INTERES DECIMAL(4, 2), 
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CAST(Solicitud_Credito.COD_CREDITO AS VARCHAR),  
        Credito.TIPO_CREDITO, 
        Credito.PLAZO_CREDITO, 
        Solicitud_Credito.MONTO_TOTAL, 
        Credito.TASA_INTERES, 
        CAST(Solicitud_Credito.MONTO_TOTAL AS DECIMAL(8, 2)),  
        Credito.TASA_INTERES 
    FROM Solicitud_Credito
    JOIN Credito ON Solicitud_Credito.COD_CREDITO = Credito.COD_CREDITO
    WHERE Solicitud_Credito.COD_SOLICITUD = p_cod_solicitud;
END;
$$ LANGUAGE plpgsql;

-- EVALUACION
DROP FUNCTION evaluar_credito

CREATE OR REPLACE FUNCTION evaluar_credito(cod_credito_param VARCHAR) RETURNS VOID AS $$
DECLARE
    act_estado VARCHAR(10) := 'Activo';
    monto INTEGER; 
    codigo_cliente VARCHAR(7);  
    credito_record RECORD;  
    nueva_fecha_evaluacion DATE; 
BEGIN
    -- Obtener el monto del credito y el código del cliente
    SELECT MONTO_SOLICITADO, COD_CLIENTE, FECHA_SOLICITUD
    INTO monto, codigo_cliente, nueva_fecha_evaluacion
    FROM Solicitud
    WHERE COD_SOLICITUD = cod_credito_param;

    -- Ajustar la nueva fecha de evaluación (7 días después de la fecha de registro)
    nueva_fecha_evaluacion := nueva_fecha_evaluacion + INTERVAL '7 days';

    -- Verificar si el cliente tiene línea de crédito
    IF (SELECT LINEA_CREDITO FROM Cliente WHERE COD_CLIENTE = codigo_cliente) < monto THEN
        act_estado := 'Rechazado'; 
    ELSE
        
        FOR credito_record IN
            SELECT COD_CREDITO, MONTO_SOLICITADO
            FROM Solicitud_Credito
            WHERE COD_SOLICITUD = cod_credito_param
        LOOP
            IF (SELECT MONTO_TOTAL FROM Credito WHERE COD_CREDITO = credito_record.COD_CREDITO) < credito_record.MONTO_SOLICITADO THEN
                nuevo_estado := 'Rechazado'; 
                EXIT;
            END IF;
        END LOOP;
    END IF;

    -- Actualizar el estado, la fecha de evaluación y las observaciones del pedido
    UPDATE Pedido
    SET ESTADO_SOLICITUD = act_estado,
        FECHA_EVALUACION = act_fecha_evaluacion,
        OBSERVACIONES = CASE 
                            WHEN act_estado = 'Aceptado' THEN 'Pedido aceptado'
                            ELSE 'Pedido rechazado'
                        END
    WHERE COD_SOLICITUD = cod_credito_param;

    -- Si el estado es 'Aceptado', realizar las actualizaciones correspondientes
    IF act_estado = 'Aceptado' THEN
	
       
        UPDATE Cliente
        SET LINEA_CREDITO = LINEA_CREDITO - monto
        WHERE COD_CLIENTE = codigo_cliente;

        
        FOR credito_record IN
            SELECT COD_CREDITO, MONTO_SOLICITADO
            FROM Solicitud_Credito
            WHERE COD_SOLICITUD = cod_credito_param
        LOOP
            UPDATE Credito
            SET MONTO_TOTAL = MONTO TOTAL + credito_record.MONTO_SOLICITADO
            WHERE COD_CREDITO = credito_record.COD_CREDITO;
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;

--------------------------------------
-- Índice compuesto para la busqueda de Solicitudes de Creditos

CREATE INDEX idx_cod_solicitud_credito ON Solicitud (COD_SOLICITUD);

-- Índice para el campo COD_CLIENTE en la solicitud
CREATE INDEX idx_solicitud_cliente ON Solicitud (COD_CLIENTE);

-- Índice para el campo ESTADO_SOLICITUD en la solicitud
CREATE INDEX idx_estado_solicitud ON Solicitud (ESTADO_SOLICITUD);
