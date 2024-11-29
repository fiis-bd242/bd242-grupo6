CREATE OR REPLACE FUNCTION obtener_recargas_pedidos()
RETURNS TABLE (
    cod_pedido VARCHAR(10),
    cod_recarga VARCHAR(10),
    cod_cliente VARCHAR(7),
    nombre_cliente VARCHAR(100),
    estado_pedido VARCHAR(10),
    monto_recarga DECIMAL(10, 2),
    fecha_solicitud_recarga DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.cod_pedido,
        r.cod_recarga,
        c.cod_cliente,
        c.nombre,
        p.estado_pedido,
        r.monto_recarga,
        r.fecha_solicitud_recarga
    FROM 
        pedido p
    INNER JOIN 
        recarga r ON p.cod_pedido = r.cod_pedido
    INNER JOIN 
        cliente c ON p.cod_cliente = c.cod_cliente
    WHERE 
        p.tipo_pedido = 'Recarga'
    ORDER BY 
        CASE 
            WHEN p.estado_pedido = 'Pendiente' THEN 1
            ELSE 2
        END,
        r.fecha_solicitud_recarga DESC,
        p.cod_pedido DESC;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION obtener_detalles_recarga(p_cod_pedido VARCHAR)
RETURNS TABLE (
    cod_pedido VARCHAR,
    fecha_reg_pedido DATE,
    cod_cliente VARCHAR,
    cod_recarga VARCHAR,
    estado_recarga VARCHAR,
    metodo_pago VARCHAR,
    linea_credito DECIMAL,
    monto_recarga DECIMAL,
    credito_maximo DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.cod_pedido,
        p.fecha_reg_pedido,
        p.cod_cliente,
        r.cod_recarga,
        r.estado_recarga,
        p.metodo_pago,
        cl.linea_credito,
        r.monto_recarga,
        cl.credito_maximo
    FROM 
        pedido p
    JOIN cliente cl ON p.cod_cliente = cl.cod_cliente
    JOIN recarga r ON p.cod_pedido = r.cod_pedido
    WHERE p.cod_pedido = p_cod_pedido;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vista_verificar_recarga(p_cod_pedido VARCHAR)
RETURNS TABLE(
    nombre_cliente VARCHAR,
    codigo_pedido VARCHAR,
    monto_credito DECIMAL,
    observaciones VARCHAR,  
    fecha_liberacion_recarga DATE,
    estado_pedido VARCHAR,
    limite_credito DECIMAL,
    codigo_recarga VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cl.nombre AS nombre_cliente,
        p.cod_pedido AS codigo_pedido,
        cl.linea_credito AS monto_credito,
        p.observaciones AS observaciones,  
        r.fecha_liberacion_recarga AS fecha_liberacion_recarga,
        p.estado_pedido AS estado_pedido,
        cl.credito_maximo AS limite_credito,
        r.cod_recarga AS codigo_recarga
    FROM 
        pedido p
    JOIN cliente cl ON p.cod_cliente = cl.cod_cliente
    JOIN recarga r ON p.cod_pedido = r.cod_pedido
    WHERE p.cod_pedido = p_cod_pedido;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION actualizar_recarga_y_pedido(
    p_cod_pedido VARCHAR,
    p_observaciones VARCHAR,
    p_fecha_liberacion DATE,
    p_estado_pedido VARCHAR
) RETURNS TEXT AS $$
DECLARE
    monto_recarga NUMERIC;
    linea_credito_actual NUMERIC;
BEGIN
    IF LENGTH(p_observaciones) > 50 THEN
        RETURN 'Error: Observaciones no puede exceder 50 caracteres.';
    END IF;

    -- Obtener monto de recarga y línea de crédito actual
    SELECT r.monto_recarga, cl.linea_credito
    INTO monto_recarga, linea_credito_actual
    FROM recarga r
    JOIN pedido p ON r.cod_pedido = p.cod_pedido
    JOIN cliente cl ON p.cod_cliente = cl.cod_cliente
    WHERE p.cod_pedido = p_cod_pedido;

    -- Verificar si línea de crédito es suficiente
    IF monto_recarga > linea_credito_actual THEN
        RETURN 'Error: Línea de crédito insuficiente.';
    END IF;

    -- Actualizar estado y observaciones del pedido
    UPDATE pedido
    SET estado_pedido = p_estado_pedido,
        fecha_evaluacion = p_fecha_liberacion,
        observaciones = p_observaciones
    WHERE cod_pedido = p_cod_pedido;

    -- Actualizar estado y fecha de liberación de la recarga
    UPDATE recarga
    SET estado_recarga = p_estado_pedido,
        fecha_liberacion_recarga = p_fecha_liberacion
    WHERE cod_pedido = p_cod_pedido;

    -- Restar monto de recarga a la línea de crédito del cliente
    UPDATE cliente
    SET linea_credito = linea_credito_actual - monto_recarga
    WHERE cod_cliente = (
        SELECT cod_cliente
        FROM pedido
        WHERE cod_pedido = p_cod_pedido
    );

    -- Retornar mensaje de confirmación según el estado del pedido
    IF p_estado_pedido = 'Aceptado' THEN
        RETURN 'Confirmación correcta. Puede seguir liberando recargas.';
    ELSE
        RETURN 'Pedido pendiente a liberación.';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION actualizar_recarga(
    p_cod_pedido VARCHAR,
    p_observaciones VARCHAR,
    p_fecha_liberacion_recarga DATE,
    p_estado_pedido VARCHAR
) RETURNS VOID AS $$
DECLARE
    v_estado_pedido VARCHAR;
    v_estado_recarga VARCHAR;
    v_monto_recarga DECIMAL;
    v_linea_credito DECIMAL;
BEGIN
    -- Recuperar el estado actual del pedido y recarga
    SELECT p.estado_pedido, r.estado_recarga, r.monto_recarga, cl.linea_credito
    INTO v_estado_pedido, v_estado_recarga, v_monto_recarga, v_linea_credito
    FROM pedido p
    JOIN recarga r ON p.cod_pedido = r.cod_pedido
    JOIN cliente cl ON p.cod_cliente = cl.cod_cliente
    WHERE p.cod_pedido = p_cod_pedido;

    -- Validar que el estado de pedido es 'Aceptado' o 'Rechazado' (Pendiente no actualiza)
    IF v_estado_pedido IN ('Aceptado', 'Rechazado') THEN
        -- Actualizar observaciones
        UPDATE pedido SET observaciones = p_observaciones WHERE cod_pedido = p_cod_pedido;
        
        -- Si el estado de pedido o recarga es cambiado, actualizamos ambos
        IF p_estado_pedido IN ('Aceptado', 'Rechazado') THEN
            UPDATE pedido SET estado_pedido = p_estado_pedido WHERE cod_pedido = p_cod_pedido;
            UPDATE recarga SET estado_recarga = p_estado_pedido WHERE cod_pedido = p_cod_pedido;
        END IF;

        -- Actualizar fecha de liberación y fecha de evaluación si es necesario
        IF p_fecha_liberacion_recarga IS NOT NULL THEN
            UPDATE recarga SET fecha_liberacion_recarga = p_fecha_liberacion_recarga WHERE cod_pedido = p_cod_pedido;
            UPDATE pedido SET fecha_evaluacion = p_fecha_liberacion_recarga WHERE cod_pedido = p_cod_pedido;
        END IF;

        -- Si el estado es 'Aceptado', restar monto recarga de la línea de crédito
        IF p_estado_pedido = 'Aceptado' THEN
            UPDATE cliente
            SET linea_credito = v_linea_credito - v_monto_recarga
            WHERE cod_cliente = (SELECT cod_cliente FROM pedido WHERE cod_pedido = p_cod_pedido);
        END IF;
    END IF;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Función para buscar recargas por código de pedido
CREATE OR REPLACE FUNCTION obtener_recargas_por_codigo_pedido(cod_pedido_buscar VARCHAR)
RETURNS TABLE(cod_pedido VARCHAR, cod_recarga VARCHAR, cod_cliente VARCHAR, nombre_cliente VARCHAR, estado_pedido VARCHAR, monto_recarga DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT p.cod_pedido, r.cod_recarga, p.cod_cliente, c.nombre, p.estado_pedido, r.monto_recarga
    FROM Pedido p
    JOIN Recarga r ON p.cod_pedido = r.cod_pedido
    JOIN Cliente c ON p.cod_cliente = c.cod_cliente
    WHERE p.cod_pedido = cod_pedido_buscar;
END;
$$ LANGUAGE plpgsql;

-- INDICE COMPUESTO
CREATE INDEX idx_cod_estado_recarga ON Recarga (COD_PEDIDO, ESTADO_RECARGA);

