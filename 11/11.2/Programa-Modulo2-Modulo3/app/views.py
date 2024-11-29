from django.shortcuts import render

def tu_vista(request):
    modulos = [
        {'nombre': 'Admision', 'url': 'modulo', 'numero': 1},
        {'nombre': 'Equipos', 'url': 'modulo', 'numero': 2},
        {'nombre': 'Recargas', 'url': 'modulo', 'numero': 3},
        {'nombre': 'Creditos', 'url': 'modulo', 'numero': 4},
        {'nombre': 'Cobranzas', 'url': 'modulo', 'numero': 5},
        {'nombre': 'Liquidacion', 'url': 'modulo', 'numero': 6},
        {'nombre': 'Reporteria', 'url': 'modulo', 'numero': 7},
    ]
    return render(request, 'app/index.html', {'modulos': modulos})

# Vistas para cada módulo
def modulo_admision(request):
    return render(request, 'modulo1/modulo1.html', {'numero': 1, 'nombre_modulo': 'Admision'})

# Modulo de equipos 

def modulo_equipos(request):
    # Obtención de los parámetros de búsqueda
    search_query = request.GET.get('search_query', '')
    filter_field = request.GET.get('filter_field', 'COD_PEDIDO')  # Default filter is COD_PEDIDO

    # Obtener los pedidos filtrados
    pedidos_structured = obtener_pedidos(filtro=filter_field, query=search_query)

    # Pasa los datos de los pedidos al template
    return render(request, 'modulo2/modulo2.html', {'pedidos_structured': pedidos_structured})

# Modulo de creditos

def modulo_creditos(request):
    return render(request, 'modulo4/modulo4.html', {'numero': 4, 'nombre_modulo': 'Creditos'})

def modulo_cobranzas(request):
    return render(request, 'modulo5/modulo5.html', {'numero': 5, 'nombre_modulo': 'Cobranzas'})

def modulo_liquidacion(request):
    return render(request, 'modulo6/modulo6.html', {'numero': 6, 'nombre_modulo': 'Liquidacion'})

def modulo_reporteria(request):
    return render(request, 'modulo7/modulo7.html', {'numero': 7, 'nombre_modulo': 'Reporteria'})



# Desarrollo modulo 2 - 1era Interfaz
from django.db import connection
from django.shortcuts import render

def obtener_pedidos(filtro=None, query=None):
    pedidos = []
    try:
        with connection.cursor() as cursor:
            # Comprobamos si hay filtros de búsqueda
            if filtro and query:
                # Si hay un filtro y una consulta, construimos la consulta con el filtro
                cursor.execute(f"""
                    SELECT * FROM obtener_pedidos()
                    WHERE {filtro} ILIKE %s;
                """, [f"%{query}%"])
            else:
                # Si no hay filtros, obtenemos todos los pedidos
                cursor.execute("SELECT * FROM obtener_pedidos();")

            pedidos = cursor.fetchall()

        # Estructuramos los resultados para su uso en la plantilla
        pedidos_structured = [
            {
                "COD_PEDIDO": row[0],
                "COD_CLIENTE": row[1],
                "NOMBRE": row[2],
                "ESTADO_PEDIDO": row[3],
                "FECHA_REG_PEDIDO": row[4]
            }
            for row in pedidos
        ]
        return pedidos_structured

    except Exception as e:
        print("Error al obtener pedidos:", e)
        return []


#Desarrollo modulo 2 - 2da Interfaz

from django.shortcuts import render, redirect
from django.db import connection
from django.http import HttpResponse

# Función para obtener los detalles del pedido
def obtener_detalles_pedido(cod_pedido):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM obtener_detalles_pedido(%s)", [cod_pedido])
        return cursor.fetchone()
    
# Vista para mostrar detalles del pedido
def detalle_pedido(request, cod_pedido):
    print("Código de pedido recibido:", cod_pedido) 
    try:
        request.session['cod_pedido'] = cod_pedido
        # Obtener los detalles del pedido
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM obtener_detalles_pedido(%s)", [cod_pedido])
            pedido = cursor.fetchone()
        
        # Si no se encuentra el pedido
        if not pedido:
            return HttpResponse(f"No se encontraron detalles para el pedido: {cod_pedido}", status=404)
        
        estado_pedido = pedido[3]  # Suponiendo que el estado se encuentra en el índice 4 del resultado
        request.session['estado_pedido'] = estado_pedido

        # Obtener los equipos del pedido
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT 
                    COD_EQUIPO,
                    MODELO,
                    MARCA,
                    CANTIDAD_PEDIDA,
                    PRECIO_UNITARIO,
                    MONTO_EQUIPO,
                    CANTIDAD_STOCK
                FROM obtener_equipos_por_pedido(%s)
            """, [cod_pedido])
            equipos = cursor.fetchall()

        # Renderizar la plantilla con los detalles del pedido y los equipos
        return render(request, 'modulo2/pedido.html', {'pedido': pedido, 'equipos': equipos})
    
    except Exception as e:
        return HttpResponse(f"Ha ocurrido un error: {e}", status=500)


# Vista para guardar observaciones
def guardar_observaciones(request, cod_pedido):
    if request.method == 'POST':
        nueva_observacion = request.POST.get('observaciones')
        with connection.cursor() as cursor:
            cursor.execute("SELECT actualizar_observaciones(%s, %s)", [cod_pedido, nueva_observacion])
    return redirect('detalle_pedido', cod_pedido=cod_pedido)

# Vista para cambiar el estado del pedido
def cambiar_estado(request, cod_pedido):
    if request.method == 'POST':
        nuevo_estado = request.POST.get('estado_pedido')

        with connection.cursor() as cursor:
            # Llamada al procedimiento almacenado para cambiar el estado
            cursor.execute("SELECT cambiar_estado_pedido(%s, %s)", [cod_pedido, nuevo_estado])

            # Almacenar el nuevo estado en la sesión para usarlo posteriormente
            cursor.execute("SELECT estado_pedido FROM Pedido WHERE cod_pedido = %s", [cod_pedido])
            nuevo_estado_actualizado = cursor.fetchone()[0]
            request.session['estado_pedido'] = nuevo_estado_actualizado  # Guardar el estado en la sesión

    return redirect('detalle_pedido', cod_pedido=cod_pedido)


from django.http import HttpResponse
from django.shortcuts import render, redirect
from django.db import connection

def evaluacion_view(request):
    # Recuperar el código de pedido desde la sesión
    cod_pedido = request.session.get('cod_pedido')
    if not cod_pedido:
        return HttpResponse("No se ha proporcionado un código de pedido.", status=400)

    # Recuperar o validar el estado del pedido inicial
    estado_pedido = request.session.get('estado_pedido')
    print("Estado inicial del pedido: ", estado_pedido)

    if not estado_pedido:
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT estado_pedido
                    FROM Pedido
                    WHERE cod_pedido = %s
                """, [cod_pedido])
                resultado = cursor.fetchone()
                if not resultado:
                    return HttpResponse("Pedido no encontrado.", status=404)
                estado_pedido = resultado[0]
                request.session['estado_pedido'] = estado_pedido
        except Exception as e:
            return HttpResponse(f"Error al obtener el estado inicial del pedido: {e}", status=500)

    # Verificar si el estado del pedido ha cambiado
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT estado_pedido
                FROM Pedido
                WHERE cod_pedido = %s
            """, [cod_pedido])
            resultado = cursor.fetchone()
            if resultado and resultado[0] != estado_pedido:
                estado_pedido = resultado[0]
                request.session['estado_pedido'] = estado_pedido
    except Exception as e:
        return HttpResponse(f"Error al verificar el estado actualizado del pedido: {e}", status=500)

    # Manejo de estados del pedido
    mensaje = ''
    detalles_pedido = {}

    if estado_pedido == 'Pendiente':
        mensaje = 'El pedido está pendiente de evaluación.'
    elif estado_pedido == 'Rechazado':
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT p.estado_pedido, p.cod_cliente, p.cod_pedido, p.fecha_evaluacion, c.linea_credito
                    FROM Pedido p
                    INNER JOIN Cliente c ON p.cod_cliente = c.cod_cliente
                    WHERE p.cod_pedido = %s
                """, [cod_pedido])
                resultado = cursor.fetchone()
                if not resultado:
                    return HttpResponse("Detalles del pedido no encontrados.", status=404)
                
                detalles_pedido = {
                    'estado_pedido': resultado[0],
                    'cod_cliente': resultado[1],
                    'cod_pedido': resultado[2],
                    'fecha_evaluacion': resultado[3],
                    'linea_credito': resultado[4]
                }
                mensaje = 'El pedido ha sido rechazado.'
        except Exception as e:
            return HttpResponse(f"Error al obtener los detalles del pedido rechazado: {e}", status=500)
    elif estado_pedido == 'Aceptado':
        try:
            with connection.cursor() as cursor:
                # Llamar a la función PL/pgSQL para realizar la evaluación
                cursor.callproc('evaluar_pedido', [cod_pedido])
                mensaje = 'El pedido ha sido validado con éxito.'

                # Obtener detalles actualizados del pedido
                cursor.execute("""
                    SELECT p.estado_pedido, p.cod_cliente, p.cod_pedido, p.fecha_evaluacion, c.linea_credito
                    FROM Pedido p
                    INNER JOIN Cliente c ON p.cod_cliente = c.cod_cliente
                    WHERE p.cod_pedido = %s
                """, [cod_pedido])
                resultado = cursor.fetchone()
                if not resultado:
                    return HttpResponse("Detalles del pedido no encontrados después de la validación.", status=404)

                detalles_pedido = {
                    'estado_pedido': resultado[0],
                    'cod_cliente': resultado[1],
                    'cod_pedido': resultado[2],
                    'fecha_evaluacion': resultado[3],
                    'linea_credito': resultado[4]
                }
        except Exception as e:
            return HttpResponse(f"Error durante la evaluación del pedido: {e}", status=500)
    else:
        return HttpResponse("Estado del pedido no reconocido.", status=400)

    # Renderizar la plantilla con los datos recopilados
    return render(request, 'modulo2/evaluacion.html', {
        'mensaje': mensaje,
        'estado_pedido': detalles_pedido.get('estado_pedido', estado_pedido),
        'cod_cliente': detalles_pedido.get('cod_cliente'),
        'cod_pedido': detalles_pedido.get('cod_pedido'),
        'fecha_evaluacion': detalles_pedido.get('fecha_evaluacion'),
        'linea_credito': detalles_pedido.get('linea_credito')
    })


# Factura

def factura_view(request):
    cod_pedido = request.session.get('cod_pedido', None)
    estado_pedido = request.session.get('estado_pedido', None)
    
    if not cod_pedido:
        return render(request, 'modulo2/factura.html', {'error': 'Código de pedido no encontrado.'})
    
    # Si no hay estado en la sesión o si el estado no es válido, obtenerlo de la base de datos
    if not estado_pedido or estado_pedido not in ['Aceptado', 'Pendiente', 'Rechazado']:
        with connection.cursor() as cursor:
            cursor.execute("SELECT estado_pedido FROM Pedido WHERE cod_pedido = %s", [cod_pedido])
            result = cursor.fetchone()
            if result:
                estado_pedido = result[0]
                request.session['estado_pedido'] = estado_pedido  # Actualiza la sesión con el estado recuperado
            else:
                return render(request, 'modulo2/factura.html', {'error': 'Estado del pedido no encontrado.'})

    # Mostrar mensajes según el estado del pedido
    if estado_pedido == 'Pendiente':
        return render(request, 'modulo2/factura.html', {'error': 'El pedido está pendiente. No se puede generar la factura.'})
    elif estado_pedido == 'Rechazado':
        return render(request, 'modulo2/factura.html', {'error': 'El pedido ha sido rechazado. No se puede generar la factura.'})
    elif estado_pedido != 'Aceptado':
        return render(request, 'modulo2/factura.html', {'error': 'Estado del pedido no válido para generar factura.'})

    # Ejecución del procedimiento almacenado o consulta para obtener los datos de la factura
    cursor = connection.cursor()
    try:
        cursor.execute("""
            SELECT
                f.cod_factura,
                f.cod_pedido,
                c.cod_cliente,
                c.nombre,
                c.razon_social,
                c.telefono,
                c.correo_empresa,
                f.fecha_factura,
                p.monto_pedido
            FROM
                Factura f
            INNER JOIN
                Pedido p ON f.cod_pedido = p.cod_pedido
            INNER JOIN
                Cliente c ON p.cod_cliente = c.cod_cliente
            WHERE
                f.cod_pedido = %s
        """, [cod_pedido])
        factura_data = cursor.fetchone()

        if not factura_data:
            return render(request, 'modulo2/factura.html', {'error': 'Factura no encontrada.'})
        
        # Mapea los datos obtenidos de la base de datos
        context = {
            'cod_factura': factura_data[0],
            'cod_pedido': factura_data[1],
            'cod_cliente': factura_data[2],
            'nombre': factura_data[3],
            'razon_social': factura_data[4],
            'telefono': factura_data[5],
            'correo_empresa': factura_data[6],
            'fecha_factura': factura_data[7],
            'monto_pedido': factura_data[8],
        }
        return render(request, 'modulo2/factura.html', context)

    finally:
        cursor.close()

#Notificacion
# Vista para la página de Notificación
def notificacion_view(request):
    return render(request, 'modulo2/notificacion.html')

# MODULO 3 FUNCIONES -----------------------------------------------

from django.shortcuts import render
from django.db import connection
from app import views  # Si la aplicación se llama "app"

# Función para obtener todos los pedidos y sus recargas

from django.db import connection
from django.shortcuts import render

def modulo_recargas(request):
    # Recuperar el código de pedido de la solicitud si existe
    cod_pedido_buscar = request.GET.get('cod_pedido', None)

    with connection.cursor() as cursor:
        if cod_pedido_buscar:
            # Si hay un código de pedido, llamar a la función para obtener los datos filtrados
            cursor.execute("SELECT * FROM obtener_recargas_por_codigo_pedido(%s)", [cod_pedido_buscar])
        else:
            # Si no hay código de pedido, obtener todos los registros
            cursor.execute("SELECT * FROM obtener_recargas_pedidos()")

        resultados = cursor.fetchall()

    # Organizar los datos para enviarlos al template
    columnas = ['cod_pedido', 'cod_recarga', 'cod_cliente', 'nombre_cliente', 'estado_pedido', 'monto_recarga']
    datos = [dict(zip(columnas, fila)) for fila in resultados]

    return render(request, 'modulo3/modulo3.html', {'datos': datos})


def modulo3_detalles(request, cod_pedido):
    # Ejecutar la función de PostgreSQL
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM obtener_detalles_recarga(%s)", [cod_pedido])
        resultado = cursor.fetchone()

    # Verificar si se encontró un pedido
    if resultado:
        detalles = {
            'cod_pedido': resultado[0],  # Código Pedido
            'fecha_reg_pedido': resultado[1],  # Fecha Registro Pedido
            'cod_cliente': resultado[2],  # Código Cliente
            'cod_recarga': resultado[3],  # Código Recarga
            'estado_recarga': resultado[4],  # Estado Recarga
            'metodo_pago': resultado[5],  # Método de Pago
            'linea_credito': resultado[6],  # Línea de Crédito
            'monto_recarga': resultado[7],  # Monto Recarga
            'credito_maximo': resultado[8],  # Crédito Máximo
        }
    else:
        detalles = None

    return render(request, 'modulo3/recargas.html', {'detalles': detalles})


def modulo3_verificar(request, cod_pedido):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM vista_verificar_recarga(%s)", [cod_pedido])
        resultado = cursor.fetchone()

    if resultado:
        datos = {
            'nombre_cliente': resultado[0],
            'codigo_pedido': resultado[1],
            'monto_credito': resultado[2],
            'observaciones': resultado[3],
            'fecha_liberacion_recarga': resultado[4],
            'estado_pedido': resultado[5],
            'limite_credito': resultado[6],
            'codigo_recarga': resultado[7],
        }
    else:
        datos = None

    return render(request, 'modulo3/verificar_recarga.html', {'datos': datos})

from django.db import connection
from django.http import JsonResponse
from django.shortcuts import render
from . import views

from django.shortcuts import render, redirect
from django.db import connection
from django.contrib import messages

from django.shortcuts import render, redirect
from django.db import connection
from django.urls import reverse

# app/views.py

from django.shortcuts import render, redirect
from django.db import connection
from django.urls import reverse

def modulo3_actualizacion(request, cod_pedido):
    if request.method == 'POST':
        # Recuperar el estado actual del pedido
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT estado_pedido FROM pedido WHERE cod_pedido = %s
            """, [cod_pedido])
            estado_pedido = cursor.fetchone()[0]

        # Verificar si el estado del pedido es 'Pendiente'
        if estado_pedido == 'Pendiente':
            # Si el estado es 'Pendiente', se permite cambiar a 'Aceptado' o 'Rechazado'
            estado_nuevo = request.POST.get('estado_pedido')
            if estado_nuevo not in ['Aceptado', 'Rechazado']:
                # Si el estado nuevo no es válido, redirigir a error o mostrar mensaje
                return render(request, 'error.html', {
                    'message': 'Estado no válido. Solo se puede actualizar a "Aceptado" o "Rechazado".'
                })
        else:
            # Si el estado no es 'Pendiente', no hay restricción para actualizarlo
            estado_nuevo = request.POST.get('estado_pedido')

        # Continuar con la actualización de otros campos
        observaciones = request.POST.get('observaciones')
        fecha_liberacion_recarga = request.POST.get('fecha_liberacion_recarga')  # Suponiendo que viene en formato YYYY-MM-DD

        # Llamar a la función PL/pgSQL para actualizar la recarga
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT actualizar_recarga(%s, %s, %s, %s)
            """, [cod_pedido, observaciones, fecha_liberacion_recarga, estado_nuevo])

        # Ahora, actualizar el estado del pedido en la tabla Pedido
        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE pedido 
                SET estado_pedido = %s
                WHERE cod_pedido = %s
            """, [estado_nuevo, cod_pedido])

        # Recuperar el nuevo estado del pedido
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT estado_pedido FROM pedido WHERE cod_pedido = %s
            """, [cod_pedido])
            estado_pedido_actualizado = cursor.fetchone()[0]

        # Redirigir a la página de factura con el estado del pedido actualizado
        return redirect('factura_recarga', cod_pedido=cod_pedido, estado_pedido=estado_pedido_actualizado)

    else:
        # Manejo en caso de que el método no sea POST
        return redirect('error')  # Redirige a una página de error si el método no es POST

def factura_recarga(request, cod_pedido, estado_pedido):
    # Si el estado del pedido es 'Aceptado'
    if estado_pedido == 'Aceptado':
        # Recuperar los detalles necesarios del pedido, cliente y recarga
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT 
                    c.nombre, c.telefono, p.cod_pedido, p.fecha_reg_pedido, p.fecha_evaluacion,
                    r.cod_recarga, r.monto_recarga, cl.linea_credito, f.cod_factura
                FROM 
                    pedido p
                    JOIN cliente c ON p.cod_cliente = c.cod_cliente
                    JOIN recarga r ON p.cod_pedido = r.cod_pedido
                    JOIN factura f ON p.cod_pedido = f.cod_pedido
                    JOIN cliente cl ON p.cod_cliente = cl.cod_cliente
                WHERE p.cod_pedido = %s
            """, [cod_pedido])
            
            resultado = cursor.fetchone()

            if resultado:
                nombre_cliente, telefono, cod_pedido, fecha_reg_pedido, fecha_evaluacion, cod_recarga, monto_recarga, linea_credito, cod_factura = resultado

        # Pasar los datos al HTML
        return render(request, 'modulo3/factura_recarga.html', {
            'mensaje': "¡Felicidades! El equipo se liberó correctamente.",
            'cod_pedido': cod_pedido,
            'nombre_cliente': nombre_cliente,
            'telefono': telefono,
            'fecha_reg_pedido': fecha_reg_pedido,
            'fecha_evaluacion': fecha_evaluacion,
            'cod_recarga': cod_recarga,
            'monto_recarga': monto_recarga,
            'linea_credito': linea_credito,
            'cod_factura': cod_factura
        })

    # Si el estado del pedido es 'Rechazado'
    elif estado_pedido == 'Rechazado':
        return render(request, 'modulo3/factura_recarga.html', {
            'mensaje': "El pedido ha sido rechazado correctamente.",
            'cod_pedido': cod_pedido
        })
    
    # Si el estado del pedido es 'Pendiente'
    elif estado_pedido == 'Pendiente':
        return render(request, 'modulo3/factura_recarga.html', {
            'mensaje': "El estado del pedido está pendiente, no se realizaron cambios.",
            'cod_pedido': cod_pedido
        })
    
    # En cualquier otro caso, manejar como un error
    else:
        return render(request, 'modulo3/factura_recarga.html', {
            'mensaje': "Error al procesar el estado del pedido.",
            'cod_pedido': cod_pedido
        })
