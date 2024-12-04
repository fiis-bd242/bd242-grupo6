## Módulo 1: Evaluación y liberación de equipos

### 1. Lista de procesos del modulo de creditos  

| Codigo Requerimiento  |R-101| 
|-----------------------|-------|
| Codigo Interfaz       |A-101| 
| Imagen interfaz       |A-101|
<div align="center">
<a>
    <img src="https://github.com/fiis-bd242/bd242-grupo6/blob/main/8/8.1/PantallasModulo4/Solicitud%20de%20credito%20-%20creditos%20en%20financiamiento.jpeg?raw=true" alt="Prototipo" width="750" style=" padding-right: 120px;">
</a>
</div>

#### En esta interfaz se puede visualizar todos las solicitud de credito, teniendo la consideracion que los clientes que tengan estado 'OPERATIVO CON MOVIMIENTO' y 'OPERATIVO SIN MOVIMIENTO' ya que en este modulo se evalua a fondo los clientes que realizan pedidos y si estan en estado de liquidacion el sistema no les dejaria realizar algun pedido.

## Sentencias SQL

### Eventos:


**Visualizació de solicitudes:** Filtrar por COD_CLIENTE y TIPO_CREDITO

```sql
SELECT 
    p.COD_SOLICITUD, 
    p.COD_CLIENTE, 
    c.NOMBRE, 
    p.ESTADO_SOLICITUD, 
    p.FECHA_SOLICITUD
FROM Cliente c
JOIN Solicitud p ON c.COD_CLIENTE = p.COD_CLIENTE
WHERE c.ESTADO_SOLICITUD IN ('EN REVISION', 'APROBADO', 'RECHAZADO' )
  AND p.TIPO_CREDITO = 'Personal';
```

### 2. Búsqueda de creditos  

| Codigo Requerimiento  |R-102| 
|-----------------------|-------|
| Codigo Interfaz       |A-102| 
| Imagen interfaz       |A-102| 
<div align="center">
<a>
    <img src="https://github.com/fiis-bd242/bd242-grupo6/blob/main/8/8.1/PantallasModulo4/Oferta%20de%20credito%20-%20creditos%20en%20financiamiento.jpeg?raw=true" alt="Prototipo" width="750" style=" padding-right: 120px;">
</a>
</div>

#### En esta parte se crea una pequeña interfaz la cual permite poder realizar una busqueda a partir de diferentes parametros relacionados al credito.

## Sentencias SQL

### Eventos:

**Busqueda de cliente:** Se realiza una busqueda a partir de diferentes parametros del cliente y su credito.

```sql
-- Busqueda por nombre del cliente 'Distribuidor EPKI'

SELECT 
    Pedido.COD_CREDITO,
    Pedido.COD_CLIENTE,
    Cliente.NOMBRE AS NOMBRE_CLIENTE,
    Pedido.ESTADO_CREDITO,
    Pedido.FECHA_CREDITO,
    Pedido.MONTO_SOLICITADO
FROM 
    Solicitud
JOIN 
    Cliente ON Solicitud.COD_CLIENTE = Cliente.COD_CLIENTE
WHERE 
    Cliente.NOMBRE = 'Distribuidor EPKI'
ORDER BY 
    Pedido.FECHA_SOLICITUD;

-- Búsqueda por Fecha de Registro de Credito

SELECT 
    Pedido.COD_CREDITO,
    Pedido.COD_CLIENTE,
    Cliente.NOMBRE AS NOMBRE_CLIENTE,
    Pedido.ESTADO_CREDITO,
    Pedido.FECHA_CREDITO,
    Pedido.MONTO_SOLICITADO
FROM 
    Solicitud
JOIN 
    Cliente ON Solicitud.COD_CLIENTE = Cliente.COD_CLIENTE
WHERE 
    Pedido.FECHA_CREDITO = '13-08-2024'  -- Modificar la fecha según el requerimiento
ORDER BY 
    Pedido.FECHA_CREDITO;

-- Búsqueda por Código de Cliente

SELECT 
    Pedido.COD_CREDITO,
    Pedido.COD_CLIENTE,
    Cliente.NOMBRE AS NOMBRE_CLIENTE,
    Pedido.ESTADO_CREDITO,
    Pedido.FECHA_CREDITO,
    Pedido.MONTO_SOLICITADO
FROM 
    Solicitud
JOIN 
    Cliente ON Solicitud.COD_CLIENTE = Cliente.COD_CLIENTE
WHERE 
    Pedido.COD_CLIENTE = 'CL00159'  -- Modificar con el código de cliente deseado
ORDER BY 
    Pedido.FECHA_CREDITO;

-- Búsqueda por Estado del Credito
SELECT 
    Pedido.COD_CREDITO,
    Pedido.COD_CLIENTE,
    Cliente.NOMBRE AS NOMBRE_CLIENTE,
    Pedido.ESTADO_CREDITO,
    Pedido.FECHA_CREDITO,
    Pedido.MONTO_SOLICITADO
FROM 
    Solicitud
JOIN 
    Cliente ON Solicitud.COD_CLIENTE = Cliente.COD_CLIENTE
WHERE 
    Pedido.ESTADO_CREDITO = 'APROBADO'  -- Modificar el estado según sea necesario (Ej: 'RECHAZADO', 'PENDIENTE')

-- Para ordenar los creditos se utiliza el ORDER BY

ORDER BY 
    Solicitud.FECHA_CREDITO;



