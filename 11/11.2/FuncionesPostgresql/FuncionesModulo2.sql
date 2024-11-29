SELECT 
    p.COD_PEDIDO, 
    p.COD_CLIENTE, 
    c.NOMBRE, 
    p.ESTADO_PEDIDO, 
    p.FECHA_REG_PEDIDO
FROM Cliente c
JOIN Pedido p ON c.COD_CLIENTE = p.COD_CLIENTE
WHERE c.ESTADO_CLIENTE IN ('OPERATIVO CON MOVIMIENTO', 'OPERATIVO SIN MOVIMIENTO')
  AND p.TIPO_PEDIDO = 'Equipo';



CREATE OR REPLACE FUNCTION obtener_pedidos()
RETURNS TABLE(
    COD_PEDIDO VARCHAR(10), 
    COD_CLIENTE VARCHAR(7), 
    NOMBRE VARCHAR(100), 
    ESTADO_PEDIDO VARCHAR(10), 
    FECHA_REG_PEDIDO DATE
) AS
$$
BEGIN
    RETURN QUERY
    SELECT p.COD_PEDIDO, 
           p.COD_CLIENTE, 
           c.NOMBRE, 
           p.ESTADO_PEDIDO, 
           p.FECHA_REG_PEDIDO
    FROM Cliente c
    JOIN Pedido p ON c.COD_CLIENTE = p.COD_CLIENTE
    WHERE c.ESTADO_CLIENTE IN ('OPERATIVO CON MOVIMIENTO', 'OPERATIVO SIN MOVIMIENTO')
      AND p.TIPO_PEDIDO = 'Equipo'
    ORDER BY p.FECHA_REG_PEDIDO DESC, p.COD_PEDIDO DESC; 
END;
$$ LANGUAGE plpgsql;

SELECT * FROM obtener_pedidos();

CREATE OR REPLACE FUNCTION buscar_pedidos(filtro text, valor text)
RETURNS TABLE (
    COD_PEDIDO VARCHAR(10),
    COD_CLIENTE VARCHAR(7),
    NOMBRE TEXT,
    ESTADO_PEDIDO VARCHAR(10),
    FECHA_REG_PEDIDO DATE
) AS $$
BEGIN
    RETURN QUERY
    EXECUTE format(
        'SELECT p.COD_PEDIDO, p.COD_CLIENTE, c.NOMBRE, p.ESTADO_PEDIDO, p.FECHA_REG_PEDIDO
         FROM Pedido p
         JOIN Cliente c ON p.COD_CLIENTE = c.COD_CLIENTE
         WHERE %I ILIKE %L', filtro, '%' || valor || '%');
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION buscar_pedidos(text,text)


--- segunda interfaz

DROP FUNCTION IF EXISTS obtener_detalles_pedido(VARCHAR);

CREATE OR REPLACE FUNCTION obtener_detalles_pedido(cod_pedido1 VARCHAR)
RETURNS TABLE(
    COD_PEDIDO VARCHAR(10),
    COD_CLIENTE VARCHAR(7),
    FECHA_REG_PEDIDO DATE,
    ESTADO_PEDIDO VARCHAR(10),
    METODO_PAGO VARCHAR(15),
    OBSERVACIONES VARCHAR(50),
    MONTO_PEDIDO INTEGER,
    NOMBRE VARCHAR(100),
    CREDITO_MAXIMO DECIMAL(10, 2),
    LINEA_CREDITO DECIMAL(10, 2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.COD_PEDIDO, p.COD_CLIENTE, p.FECHA_REG_PEDIDO, p.ESTADO_PEDIDO, 
           p.METODO_PAGO, p.OBSERVACIONES, p.MONTO_PEDIDO,
           c.NOMBRE, c.CREDITO_MAXIMO, c.LINEA_CREDITO
    FROM Pedido p
    JOIN Cliente c ON p.COD_CLIENTE = c.COD_CLIENTE
    WHERE p.COD_PEDIDO = cod_pedido1;
END;
$$ LANGUAGE plpgsql;

-- actualizar observaciones

CREATE OR REPLACE FUNCTION actualizar_observaciones(
    p_cod_pedido VARCHAR, 
    p_nueva_observacion TEXT
) RETURNS VOID AS $$
BEGIN
    UPDATE Pedido
    SET OBSERVACIONES = p_nueva_observacion
    WHERE COD_PEDIDO = p_cod_pedido; 
END;
$$ LANGUAGE plpgsql;


-- actualizar estado pedido

CREATE OR REPLACE FUNCTION cambiar_estado_pedido(
    p_cod_pedido VARCHAR, 
    p_nuevo_estado VARCHAR
) RETURNS VOID AS $$
BEGIN
    UPDATE Pedido
    SET ESTADO_PEDIDO = p_nuevo_estado
    WHERE COD_PEDIDO = p_cod_pedido; 
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION cambiar_estado_pedido


SELECT * FROM obtener_detalles_pedido('PD005570');


CREATE OR REPLACE FUNCTION obtener_equipos_por_pedido(p_cod_pedido character varying)
RETURNS TABLE (
    COD_EQUIPO VARCHAR, 
    MODELO VARCHAR,
    MARCA VARCHAR,
    CANTIDAD_PEDIDA INTEGER,
    PRECIO_UNITARIO DECIMAL(10, 2),
    MONTO_EQUIPO DECIMAL(10, 2), 
    CANTIDAD_STOCK INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CAST(Pedido_Equipo.COD_EQUIPO AS VARCHAR),  
        Equipo.MODELO, 
        Equipo.MARCA, 
        Pedido_Equipo.CANTIDAD_PEDIDA, 
        Equipo.PRECIO_UNITARIO, 
        CAST(Pedido_Equipo.MONTO_EQUIPO AS DECIMAL(10, 2)),  
        Equipo.CANTIDAD_STOCK 
    FROM Pedido_Equipo
    JOIN Equipo ON Pedido_Equipo.COD_EQUIPO = Equipo.COD_EQUIPO
    WHERE Pedido_Equipo.COD_PEDIDO = p_cod_pedido;
END;
$$ LANGUAGE plpgsql;

-- EVALUACION
DROP FUNCTION evaluar_pedido

CREATE OR REPLACE FUNCTION evaluar_pedido(cod_pedido_param VARCHAR) RETURNS VOID AS $$
DECLARE
    nuevo_estado VARCHAR(10) := 'Aceptado';
    monto INTEGER; 
    codigo_cliente VARCHAR(7);  
    equipo_record RECORD;  
    nueva_fecha_evaluacion DATE; 
BEGIN
    -- Obtener el monto del pedido y el código del cliente
    SELECT MONTO_PEDIDO, COD_CLIENTE, FECHA_REG_PEDIDO
    INTO monto, codigo_cliente, nueva_fecha_evaluacion
    FROM Pedido
    WHERE COD_PEDIDO = cod_pedido_param;

    -- Ajustar la nueva fecha de evaluación (7 días después de la fecha de registro)
    nueva_fecha_evaluacion := nueva_fecha_evaluacion + INTERVAL '7 days';

    -- Verificar si el cliente tiene suficiente línea de crédito
    IF (SELECT LINEA_CREDITO FROM Cliente WHERE COD_CLIENTE = codigo_cliente) < monto THEN
        nuevo_estado := 'Rechazado'; -- Si no tiene suficiente crédito, el pedido se rechaza
    ELSE
        -- Verificar si hay suficiente stock para todos los equipos
        FOR equipo_record IN
            SELECT COD_EQUIPO, CANTIDAD_PEDIDA
            FROM Pedido_Equipo
            WHERE COD_PEDIDO = cod_pedido_param
        LOOP
            IF (SELECT CANTIDAD_STOCK FROM Equipo WHERE COD_EQUIPO = equipo_record.COD_EQUIPO) < equipo_record.CANTIDAD_PEDIDA THEN
                nuevo_estado := 'Rechazado'; 
                EXIT;
            END IF;
        END LOOP;
    END IF;

    -- Actualizar el estado, la fecha de evaluación y las observaciones del pedido
    UPDATE Pedido
    SET ESTADO_PEDIDO = nuevo_estado,
        FECHA_EVALUACION = nueva_fecha_evaluacion,
        OBSERVACIONES = CASE 
                            WHEN nuevo_estado = 'Aceptado' THEN 'Pedido aceptado'
                            ELSE 'Pedido rechazado'
                        END
    WHERE COD_PEDIDO = cod_pedido_param;

    -- Si el estado es 'Aceptado', realizar las actualizaciones correspondientes
    IF nuevo_estado = 'Aceptado' THEN
	
        -- Restar el monto del pedido de la línea de crédito del cliente
        UPDATE Cliente
        SET LINEA_CREDITO = LINEA_CREDITO - monto
        WHERE COD_CLIENTE = codigo_cliente;

        -- Restar la cantidad pedida de cada equipo del stock disponible
        FOR equipo_record IN
            SELECT COD_EQUIPO, CANTIDAD_PEDIDA
            FROM Pedido_Equipo
            WHERE COD_PEDIDO = cod_pedido_param
        LOOP
            UPDATE Equipo
            SET CANTIDAD_STOCK = CANTIDAD_STOCK - equipo_record.CANTIDAD_PEDIDA
            WHERE COD_EQUIPO = equipo_record.COD_EQUIPO;
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;

--------------------------------------
-- Idices para la busqueda

-- Índice para el campo COD_CLIENTE
CREATE INDEX idx_cod_cliente ON Pedido (COD_CLIENTE);

-- Índice para el campo ESTADO_PEDIDO
CREATE INDEX idx_estado_pedido ON Pedido (ESTADO_PEDIDO);

-- Índice para el campo NOMBRE en la tabla Cliente
CREATE INDEX idx_nombre_cliente ON Cliente (NOMBRE);
