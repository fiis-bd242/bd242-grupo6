## Módulo 1: Evaluación y liberación de equipos

### 1. Lista de pedidos filtrados por Estado de Cliente y Equipos  

| Codigo Requerimiento  |R-101| 
|-----------------------|-------|
| Codigo Interfaz       |A-101| 
| Imagen interfaz       |A-101|
<div align="center">
<a>
    <img src="https://github.com/fiis-bd242/bd242-grupo6/blob/main/8/8.1/PantallasModulo4/Seleccion%20de%20procesos%20-%20creditos%20en%20financiamiento.jpeg?raw=true" alt="Prototipo" width="750" style=" padding-right: 120px;">
</a>
</div>

#### En esta interfaz se puede visualizar todos los pedidos relacionados a los equipos, teniendo la consideracion que los clientes que tengan estado 'OPERATIVO CON MOVIMIENTO' y 'OPERATIVO SIN MOVIMIENTO' ya que en este modulo se evalua a fondo los clientes que realizan pedidos y si estan en estado de liquidacion el sistema no les dejaria realizar algun pedido.

## Sentencias SQL

### Eventos:


**Visualizació de pedidos:** Filtrar por ESTADO_CLIENTE y TIPO_PEDIDO

```sql
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
```

### 2. Búsqueda de Pedido  

| Codigo Requerimiento  |R-102| 
|-----------------------|-------|
| Codigo Interfaz       |A-102| 
| Imagen interfaz       |A-102| 
<div align="center">
<a>
    <img src="https://github.com/fiis-bd242/bd242-grupo6/blob/main/8/8.1/Folder%208.1%20Modulo1/A-102.png?raw=true" alt="Prototipo" width="750" style=" padding-right: 120px;">
</a>
</div>

#### En esta parte se crea una pequeña interfaz la cual permite poder realizar una busqueda a partir de diferentes parametros relacionados al pedido.

## Sentencias SQL

### Eventos:

**Busqueda de cliente:** Se realiza una busqueda a partir de diferentes parametros del cliente y su pedido.

```sql
-- Busqueda por nombre del cliente 'Distribuidor EPKI'

SELECT 
    Pedido.COD_PEDIDO,
    Pedido.COD_CLIENTE,
    Cliente.NOMBRE AS NOMBRE_CLIENTE,
    Pedido.ESTADO_PEDIDO,
    Pedido.FECHA_REG_PEDIDO,
    Pedido.MONTO_PEDIDO
FROM 
    Pedido
JOIN 
    Cliente ON Pedido.COD_CLIENTE = Cliente.COD_CLIENTE
WHERE 
    Cliente.NOMBRE = 'Distribuidor EPKI'
ORDER BY 
    Pedido.FECHA_REG_PEDIDO;

-- Búsqueda por Fecha de Registro de Pedido

SELECT 
    Pedido.COD_PEDIDO,
    Pedido.COD_CLIENTE,
    Cliente.NOMBRE AS NOMBRE_CLIENTE,
    Pedido.ESTADO_PEDIDO,
    Pedido.FECHA_REG_PEDIDO,
    Pedido.MONTO_PEDIDO
FROM 
    Pedido
JOIN 
    Cliente ON Pedido.COD_CLIENTE = Cliente.COD_CLIENTE
WHERE 
    Pedido.FECHA_REG_PEDIDO = '13-08-2024'  -- Modificar la fecha según el requerimiento
ORDER BY 
    Pedido.FECHA_REG_PEDIDO;

-- Búsqueda por Código de Cliente

SELECT 
    Pedido.COD_PEDIDO,
    Pedido.COD_CLIENTE,
    Cliente.NOMBRE AS NOMBRE_CLIENTE,
    Pedido.ESTADO_PEDIDO,
    Pedido.FECHA_REG_PEDIDO,
    Pedido.MONTO_PEDIDO
FROM 
    Pedido
JOIN 
    Cliente ON Pedido.COD_CLIENTE = Cliente.COD_CLIENTE
WHERE 
    Pedido.COD_CLIENTE = 'CL00159'  -- Modificar con el código de cliente deseado
ORDER BY 
    Pedido.FECHA_REG_PEDIDO;

-- Búsqueda por Estado del Pedido
SELECT 
    Pedido.COD_PEDIDO,
    Pedido.COD_CLIENTE,
    Cliente.NOMBRE AS NOMBRE_CLIENTE,
    Pedido.ESTADO_PEDIDO,
    Pedido.FECHA_REG_PEDIDO,
    Pedido.MONTO_PEDIDO
FROM 
    Pedido
JOIN 
    Cliente ON Pedido.COD_CLIENTE = Cliente.COD_CLIENTE
WHERE 
    Pedido.ESTADO_PEDIDO = 'Aceptado'  -- Modificar el estado según sea necesario (Ej: 'Rechazado', 'Pendiente')

-- Para ordenar los pedidos se utiliza el ORDER BY

ORDER BY 
    Pedido.FECHA_REG_PEDIDO;

```

### 3. Evaluación de Equipo  


| Codigo Requerimiento  |R-103| 
|-----------------------|-------|
| Codigo Interfaz       |A-103,A-104| 
| Imagen interfaz       |A-103,A-104| 
<div align="center">
<a>
    <img src="https://github.com/fiis-bd242/bd242-grupo6/blob/main/8/8.1/Folder%208.1%20Modulo1/A-103.png?raw=true" alt="Prototipo" width="750" style=" padding-right: 120px;">
</a>
</div>

<div align="center">
<a>
    <img src="https://github.com/fiis-bd242/bd242-grupo6/blob/main/8/8.1/Folder%208.1%20Modulo1/A-104.png?raw=true" alt="Prototipo" width="750" style=" padding-right: 120px;">
</a>
</div>

#### En esta parte se muestra más detalles del pedido del cliente y esta la opción para poder hacer modificaciones respecto al estado, 

## Sentencias SQL

### Eventos:
**Visualizar equipos por pedido**: Se puede revisar los equipos solicitados en cada pedido, para poder ver si se cuenta con el stock necesario en cada uno de ellos y poder ver como se va manejando esto, esto se observa en la interfaz A-104.

```sql
-- Informacion de equipos del pedido 'PD005573'

SELECT 
    Pedido_Equipo.COD_EQUIPO,
    Equipo.MODELO,
    Equipo.MARCA,
    Pedido_Equipo.CANTIDAD_PEDIDA,
    Equipo.PRECIO_UNITARIO,
    Pedido_Equipo.MONTO_EQUIPO,
    Equipo.CANTIDAD_STOCK
FROM 
    Pedido_Equipo
JOIN 
    Equipo ON Pedido_Equipo.COD_EQUIPO = Equipo.COD_EQUIPO
WHERE 
    Pedido_Equipo.COD_PEDIDO = 'PD005573';

```
**Modificar y actualizar estado del pedido:** Se puede poner una obsercacion en la interfaz A-103 y actualizar el estado del cliente, para poder asignar una fecha en la que se realizo la evaluacion de ese pedido (es importante saber en que pedido se esta efectuando), una vez que se ingresa todos esos datos se actualiza. Entonces todo esto se registra a partir de un codigo de pedido como base, en el prototipo se selecciona el punto donde dice Aceptado, en la parte de Observacion se pone las observaciones, la fecha en sí se debe registrar de forma automatica de tal manera coincida con la fecha real en la que acepta la evaluacion a su vez todo esto se ejecuta cuando le da al boton ACEPTAR. Ahora internamente el stock se actualiza a partir de la diferencia del stock con las cantidades solicitadas, lo mismo para su linea de credito con el monto del pedido.

```sql
-- Modificar estado del pedido
DO $$
DECLARE
    nuevo_estado VARCHAR(10) := 'Aceptado';  -- Estado nuevo para el pedido
    codigo_pedido VARCHAR(10) := 'PD005573';  -- Código del pedido a modificar
    nueva_fecha_evaluacion DATE := '20/08/2024';  -- Fecha de evaluación a asignar
    nuevas_observaciones VARCHAR(50) := 'Pedido aceptado';  -- Observaciones para el pedido
    monto INTEGER;  -- Monto del pedido
    codigo_cliente VARCHAR(7);  -- Código del cliente asociado al pedido
    equipo_record RECORD;  -- Variable de tipo record para almacenar los resultados del bucle
BEGIN
    -- Obtener el monto y el código del cliente del pedido especificado
    SELECT MONTO_PEDIDO, COD_CLIENTE
    INTO monto, codigo_cliente
    FROM Pedido
    WHERE COD_PEDIDO = codigo_pedido;

    -- Actualizar el estado, la fecha de evaluación y las observaciones del pedido
    UPDATE Pedido
    SET ESTADO_PEDIDO = nuevo_estado,
        FECHA_EVALUACION = nueva_fecha_evaluacion,
        OBSERVACIONES = nuevas_observaciones
    WHERE COD_PEDIDO = codigo_pedido;

    -- Si el estado es 'Aceptado', restar el monto del pedido de la línea de crédito del cliente
    IF nuevo_estado = 'Aceptado' THEN
        -- Restar el monto del pedido de la línea de crédito del cliente
        UPDATE Cliente
        SET LINEA_CREDITO = LINEA_CREDITO - monto
        WHERE COD_CLIENTE = codigo_cliente;

        -- Restar la cantidad pedida de cada equipo del stock disponible
        FOR equipo_record IN
            SELECT COD_EQUIPO, CANTIDAD_PEDIDA
            FROM Pedido_Equipo
            WHERE COD_PEDIDO = codigo_pedido
        LOOP
            -- Actualizar el stock de cada equipo restando la cantidad pedida
            UPDATE Equipo
            SET CANTIDAD_STOCK = CANTIDAD_STOCK - equipo_record.CANTIDAD_PEDIDA
            WHERE COD_EQUIPO = equipo_record.COD_EQUIPO;
        END LOOP;
    END IF;
END $$;
```


4. **Generar Factura** 

| Codigo Requerimiento  |R-104| 
|-----------------------|-------|
| Codigo Interfaz       |A-105, A-106, A-107| 
| Imagen interfaz       |A-105, A-106, A-107| 
<div align="center">
<a>
    <img src="https://github.com/fiis-bd242/bd242-grupo6/blob/main/8/8.1/Folder%208.1%20Modulo1/A-105.png?raw=true" alt="Prototipo" width="750" style=" padding-right: 120px;">
</a>
</div>

<div align="center">
<a>
    <img src="https://github.com/fiis-bd242/bd242-grupo6/blob/main/8/8.1/Folder%208.1%20Modulo1/A-106.png?raw=true" alt="Prototipo" width="750" style=" padding-right: 120px;">
</a>
</div>

<div align="center">
<a>
    <img src="https://github.com/fiis-bd242/bd242-grupo6/blob/main/8/8.1/Folder%208.1%20Modulo1/A-107.png?raw=true" alt="Prototipo" width="750" style=" padding-right: 120px;">
</a>
</div>

#### A Partir de la secuencia anterior se muestran los datos actualizado y salen diferentes opciones como generar FACTURA, enviar NOTIFICACION o volver al INICIA, en este caso se genera la factura solamente cuando el pedido a sido aprobado, caso contrario no se generara nada y eso representaria la interfaz A-107.
## Sentencias SQL

### Eventos:

**Actualización de pedido:**
Se detalla la actualizacion de la evaluacion anterior y muestra diferentes opciones, esto se observa en la interfaz A-105.

```sql
SELECT 
    Pedido.COD_CLIENTE,
    Pedido.COD_PEDIDO,
    Pedido.FECHA_EVALUACION,
    Cliente.LINEA_CREDITO
FROM 
    Pedido
JOIN 
    Cliente ON Pedido.COD_CLIENTE = Cliente.COD_CLIENTE
WHERE 
    Pedido.COD_PEDIDO = 'PD005573'; -- se modifica segun el pedido
```

**Generar factura:** Una vez que el pedido es aprobado y liberado, se genera una factura para el cliente a partir del boton FACTURA el cual se observa en el A-106.

```sql
-- Datos para la factura
SELECT 
    f.COD_FACTURA, 
    p.COD_PEDIDO, 
    p.COD_CLIENTE, 
    c.NOMBRE, 
    c.RAZON_SOCIAL, 
    c.TELEFONO, 
    c.CORREO_EMPRESA, 
    c.FECHA_REGISTRO, 
    f.FECHA_FACTURA, 
    p.MONTO_PEDIDO
FROM 
    Factura f
JOIN 
    Pedido p ON f.COD_PEDIDO = p.COD_PEDIDO
JOIN 
    Cliente c ON p.COD_CLIENTE = c.COD_CLIENTE
WHERE 
    p.ESTADO_PEDIDO = 'Aceptado' 
    AND p.COD_PEDIDO = 'PD005573' -- Reemplaza con el código del pedido específico
```

### 5. Enviar notificación

| Codigo Requerimiento  |R-105| 
|-----------------------|-------|
| Codigo Interfaz       |A-105,A-108,A-109| 
| Imagen interfaz       |A-105,A-108,A-109|
<div align="center">
<a>
    <img src="https://github.com/fiis-bd242/bd242-grupo6/blob/main/8/8.1/Folder%208.1%20Modulo1/A-105.png?raw=true" alt="Prototipo" width="750" style=" padding-right: 120px;">
</a>
</div>

<div align="center">
<a>
    <img src="https://github.com/fiis-bd242/bd242-grupo6/blob/main/8/8.1/Folder%208.1%20Modulo1/A-108.png?raw=true" alt="Prototipo" width="750" style=" padding-right: 120px;">
</a>
</div>

<div align="center">
<a>
    <img src="https://github.com/fiis-bd242/bd242-grupo6/blob/main/8/8.1/Folder%208.1%20Modulo1/A-109.png?raw=true" alt="Prototipo" width="750" style=" padding-right: 120px;">
</a>
</div>

En esta parte se envia una notificacion respecto a la evaluacion del pedido del cliente en el caso que se acepto se envia un mensaje al correo que se acepto y si fuese rechazado se el indica el rechazo y la razón.

## Sentencias SQL

### Eventos:
**Actualización de pedido:**
Se detalla la actualizacion de la evaluacion anterior y muestra diferentes opciones, esto se observa en la interfaz A-105.

```sql
SELECT 
    Pedido.COD_CLIENTE,
    Pedido.COD_PEDIDO,
    Pedido.FECHA_EVALUACION,
    Cliente.LINEA_CREDITO
FROM 
    Pedido
JOIN 
    Cliente ON Pedido.COD_CLIENTE = Cliente.COD_CLIENTE
WHERE 
    Pedido.COD_PEDIDO = 'PD005573'; -- se modifica segun el pedido
```

**Envio de notificación:** Se realiza observaciones y luego se envia la notificacion al cliente en base a una cantidad de datos del cliente como su pedido y de la evaluacion realizada esto se observa en la interfaz A-108.

```sql
-- Actualizar o modificar las observacion en la notificacion
UPDATE Notificacion
SET 
    OBSERVACION_NOTIFICACION = 'Nueva observación aquí' 
WHERE 
    COD_PEDIDO = 'PD005573';
-- visualizacion para la notificacion

SELECT 
    n.COD_NOTIFICACION, 
    p.COD_PEDIDO, 
    p.COD_CLIENTE, 
    c.NOMBRE AS nombre_cliente, 
    c.CORREO_EMPRESA AS correo_cliente, 
    CASE 
        WHEN p.ESTADO_PEDIDO = 'Aceptado' THEN 'Aceptado'
        WHEN p.ESTADO_PEDIDO = 'Rechazado' THEN 'Rechazado'
        ELSE 'Otro' 
    END AS tipo_notificacion,
    n.OBSERVACION_NOTIFICACION
FROM 
    Notificacion n
JOIN 
    Pedido p ON n.COD_PEDIDO = p.COD_PEDIDO
JOIN 
    Cliente c ON p.COD_CLIENTE = c.COD_CLIENTE
WHERE 
    p.COD_PEDIDO = 'PD005573'  -- Reemplaza con el código del pedido específico
ORDER BY 
    n.COD_NOTIFICACION DESC;
```
