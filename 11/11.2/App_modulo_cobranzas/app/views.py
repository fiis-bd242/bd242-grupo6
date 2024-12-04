from django.shortcuts import render,HttpResponse, redirect
from datetime import datetime   
from django.db import connection
from django.http import JsonResponse

# Diccionario de módulos 
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

def modulo_equipos(request):
    return render(request, 'modulo2/modulo2.html', {'numero': 2, 'nombre_modulo': 'Equipos'})

def modulo_recargas(request):
    return render(request, 'modulo3/modulo3.html', {'numero': 3, 'nombre_modulo': 'Recargas'})

def modulo_creditos(request):
    return render(request, 'modulo4/modulo4.html', {'numero': 4, 'nombre_modulo': 'Creditos'})

def modulo_liquidacion(request):
    return render(request, 'modulo6/modulo6.html', {'numero': 6, 'nombre_modulo': 'Liquidacion'})

def modulo_reporteria(request):
    return render(request, 'modulo7/modulo7.html', {'numero': 7, 'nombre_modulo': 'Reporteria'})


def modulo_cobranzas(request):
    # Inicializar lista de clientes vacía
    clientes_estructurados = []

    # Consultar todos los clientes sin filtro
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM public.vw_clientes_deuda_completa;")
        clientes = cursor.fetchall()

    # Estructurar los datos de los clientes para pasarlos a la plantilla
    clientes_estructurados = [
        {
            'cod_cliente': cliente[0],
            'nombre_cliente': cliente[1],
            'monto_deuda': cliente[2],
            'estado_deuda': cliente[3],
            'estado_cobranza': cliente[4]
        }
        for cliente in clientes
    ]

    # Pasar los datos a la plantilla
    return render(request, 'modulo5/modulo5.html', {
        'numero': 5, 
        'nombre_modulo': 'Cobranzas',
        'clientes': clientes_estructurados,
        'estado_deuda': '',  # No hay filtro al principio
        'nombre_cliente': ''  # No hay filtro de nombre al principio
    })






def ver_todos_los_clientes(request):
    # Consultar todos los clientes mediante la función de la base de datos
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM public.obtener_clientes_deuda_completa();")
        clientes = cursor.fetchall()

    # Estructurar los datos de los clientes para pasarlos a la plantilla
    clientes_estructurados = [
        {
            'cod_cliente': cliente[0],
            'nombre_cliente': cliente[1],
            'monto_deuda': cliente[2],
            'estado_deuda': cliente[3],
            'estado_cobranza': cliente[4]
        }
        for cliente in clientes
    ]

    # Pasar los datos a la plantilla
    return render(request, 'modulo5/modulo5.html', {
        'numero': 5, 
        'nombre_modulo': 'Cobranzas',
        'clientes': clientes_estructurados,
    })

def filtrar_clientes_por_nombre(request):
    # Obtener el nombre del cliente desde el parámetro GET
    nombre_cliente = request.GET.get('nombre_cliente', '').strip()  # Nombre a filtrar
    clientes_estructurados = []  # Lista para almacenar los resultados

    if nombre_cliente:
        # Ejecutar la consulta que llama a la función `filtrar_clientes_por_nombre`
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM filtrar_clientes_por_nombre(%s);", [nombre_cliente])
            clientes = cursor.fetchall()  # Obtener los resultados filtrados

        # Estructurar los datos para pasarlos a la plantilla
        clientes_estructurados = [
            {
                'cod_cliente': cliente[0],
                'nombre_cliente': cliente[1],
                'monto_deuda': cliente[2],
                'estado_deuda': cliente[3],
                'estado_cobranza': cliente[4]
            }
            for cliente in clientes
        ]

    # Pasar los datos filtrados a la plantilla
    return render(request, 'modulo5/modulo5.html', {
        'numero': 5, 
        'nombre_modulo': 'Cobranzas',
        'clientes': clientes_estructurados,  # Los resultados filtrados
        'nombre_cliente': nombre_cliente  # Mostrar el nombre que se está filtrando
    })
# Función para filtrar los clientes según el estado de deuda
def filtrar_clientes(request, estado_deuda):
    # Ejecutar la consulta filtrada según el estado de deuda
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM obtener_clientes_deuda_completa() WHERE estado_deuda = %s", [estado_deuda])
        clientes = cursor.fetchall()  # Obtener los resultados filtrados

    # Estructurar los datos para pasarlos a la plantilla
    clientes_estructurados = [
        {
            'cod_cliente': cliente[0],
            'nombre_cliente': cliente[1],
            'monto_deuda': cliente[2],
            'estado_deuda': cliente[3],
            'estado_cobranza': cliente[4]
        }
        for cliente in clientes
    ]

    # Pasar los datos filtrados a la plantilla
    return render(request, 'modulo5/modulo5.html', {
        'numero': 5, 
        'nombre_modulo': 'Cobranzas',
        'clientes': clientes_estructurados,
        'estado_deuda': estado_deuda  # Mostrar el filtro aplicado
    })
from django.db import connection
from django.shortcuts import redirect
from django.contrib import messages
from django.shortcuts import render


def actualizar_estado_cobranza(request):
    if request.method == 'POST':
        try:
            sql = "CALL actualizar_estado_cobranza();"  # Procedimiento sin parámetros
            with connection.cursor() as cursor:
                cursor.execute(sql)
                # Si el procedimiento se ejecutó correctamente
                messages.success(request, "El estado de cobranza se actualizó correctamente.")
        except Exception as e:
            # Si ocurre un error
            print(f"Error al ejecutar el procedimiento: {e}")
            messages.error(request, f"Ocurrió un error: {str(e)}")
    
    # Regresar a la misma página con el mensaje de éxito o error
    return render(request, 'modulo5/modulo5.html')

def detalle_cliente(request, cod_cliente):
    # Consulta SQL para obtener datos del cliente
    query = """
    SELECT 
        c.COD_CLIENTE, 
        c.NOMBRE AS NOMBRE_CLIENTE, 
        c.REGION, 
        c.ESTADO_CLIENTE, 
        d.ESTADO_DEUDA, 
        d.ESTADO_COBRANZA, 
        d.DIAS_RETRASO, 
        a.NOMBRE_ANALISTA_COBRANZA
   
    FROM 
        Cliente c
    LEFT JOIN 
        Deuda d ON c.COD_CLIENTE = d.COD_CLIENTE
    LEFT JOIN 
        Analista_cobranza a ON d.COD_ANALISTA_COBRANZA = a.COD_ANALISTA_COBRANZAS
    WHERE 
        c.COD_CLIENTE = %s;
    """
    with connection.cursor() as cursor:
        cursor.execute(query, [cod_cliente])
        row = cursor.fetchone()

    if row is None:
        return render(request, 'error.html', {'message': 'Cliente no encontrado'})

    # Mapear resultados a un diccionario
    cliente_data = {
        'codigo': row[0],
        'nombre': row[1],
        'region': row[2],
        'estado_cliente': row[3],
        'estado_deuda': row[4],  # Estado de deuda
        'estado_cobranza': row[5],
        'dias_atraso': row[6],
        'analista': row[7],

    }

    # Consulta para verificar si hay notificaciones en la base de datos
    query_notificaciones = """
    SELECT COUNT(*) 
    FROM Notificacion_cobranza 
    WHERE COD_CLIENTE = %s;
    """
    with connection.cursor() as cursor:
        cursor.execute(query_notificaciones, [cod_cliente])
        notificaciones_count = cursor.fetchone()[0]

    # Si no hay notificaciones, mostrar un mensaje, si hay, habilitar el botón
    hay_notificaciones = notificaciones_count > 0

    # Pasar todos los datos a la plantilla, incluyendo la variable de notificaciones
    return render(request, 'modulo5/detalle_cliente.html', {
        'cliente': cliente_data,
        'hay_notificaciones': hay_notificaciones,  # Variable para mostrar notificaciones
        'cod_cliente': cod_cliente  # Asegúrate de pasar cod_cliente
    })
def historial_notificaciones(request, cod_cliente):
    # Consulta SQL para obtener el historial de notificaciones
    query = """
    SELECT 
        n.COD_NOTIFICACION_COBRANZA, 
        n.FECHA_ENVIO, 
        n.TIPO_NOTIFICACION, 
        d.ESTADO_COBRANZA
    FROM 
        Notificacion_cobranza n
    LEFT JOIN 
        Deuda d ON n.COD_DEUDA = d.COD_DEUDA
    WHERE 
        n.COD_CLIENTE = %s
    ORDER BY 
        n.FECHA_ENVIO ASC;
    """
    
    # Consulta para obtener el nombre del cliente
    query_nombre = """
    SELECT 
        NOMBRE 
    FROM 
        Cliente 
    WHERE 
        COD_CLIENTE = %s
    """

    # Consulta para obtener el estado de deuda del cliente
    query_estado_deuda = """
    SELECT 
        ESTADO_DEUDA
    FROM 
        Deuda
    WHERE 
        COD_CLIENTE = %s
    """
    
    with connection.cursor() as cursor:
        # Obtener el historial de notificaciones
        cursor.execute(query, [cod_cliente])
        notificaciones = cursor.fetchall()

        # Verificar si se obtuvieron notificaciones
        if notificaciones:
            print("Notificaciones encontradas:", notificaciones)
        else:
            print("No hay notificaciones para este cliente")

        # Ejecutar consulta del nombre del cliente
        cursor.execute(query_nombre, [cod_cliente])
        cliente_nombre_row = cursor.fetchone()

        # Verificar si se encontró el cliente
        if cliente_nombre_row:
            cliente_nombre = cliente_nombre_row[0]
        else:
            cliente_nombre = "Cliente no encontrado"  # Mensaje de error si no se encuentra el cliente
            print("No se encontró el cliente con el código:", cod_cliente)

        # Obtener el estado de deuda del cliente
        cursor.execute(query_estado_deuda, [cod_cliente])
        estado_deuda_row = cursor.fetchone()

        if estado_deuda_row:
            estado_deuda = estado_deuda_row[0]
        else:
            estado_deuda = None
            print("No se encontró el estado de deuda para este cliente")

    # Pasar los datos a la plantilla
    return render(request, 'modulo5/historial_notificaciones.html', {
        'notificaciones': notificaciones,
        'cod_cliente': cod_cliente,
        'cliente_nombre': cliente_nombre,  # Pasar el nombre al contexto
        'estado_deuda': estado_deuda,  # Pasar el estado de la deuda al contexto
        'no_notificaciones': len(notificaciones) == 0,  # Variable que indica si no hay notificaciones
    })

from datetime import datetime
from django.db import connection

from django.shortcuts import render, redirect
from django.db import connection
from datetime import datetime

def pago_realizado(request, cod_cliente):
    if request.method == "POST":
        # Obtener el nuevo código de notificación usando la secuencia
        with connection.cursor() as cursor:
            cursor.execute("SELECT NEXTVAL('secuencia_notificacion_cobranza')")
            nuevo_numero = cursor.fetchone()[0]

            # Formatear el código como NC00001, NC00002, etc.
            nuevo_codigo = f"NC{nuevo_numero:05d}"

        # Obtener el COD_DEUDA relacionado con el cliente
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT COD_DEUDA 
                FROM Deuda 
                WHERE COD_CLIENTE = %s
            """, [cod_cliente])
            deuda_row = cursor.fetchone()

        if deuda_row:
            cod_deuda = deuda_row[0]
        else:
            cod_deuda = None  # Si no se encuentra la deuda, se establece como None

        # Insertar nueva notificación en la base de datos
        fecha_envio = datetime.now().strftime('%Y-%m-%d')
        tipo_notificacion = "pago realizado"
        estado_cobranza = "ninguna"

        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO Notificacion_cobranza (COD_NOTIFICACION_COBRANZA, FECHA_ENVIO, TIPO_NOTIFICACION, COD_CLIENTE, COD_DEUDA)
                VALUES (%s, %s, %s, %s, %s)
            """, [nuevo_codigo, fecha_envio, tipo_notificacion, cod_cliente, cod_deuda])


        # Actualizar el estado de deuda del cliente
        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE Deuda
                SET ESTADO_DEUDA = 'Al dia'
                WHERE COD_CLIENTE = %s
            """, [cod_cliente])


        # Actualizar el estado de cobranza a 'Ninguna'
        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE Deuda
                SET ESTADO_COBRANZA = 'Ninguna'
                WHERE COD_CLIENTE = %s
            """, [cod_cliente])

        # Redireccionar al historial de notificaciones
        return redirect('historial_notificaciones', cod_cliente=cod_cliente)

    # Si no es POST, redirige al historial
    return redirect('historial_notificaciones', cod_cliente=cod_cliente)

    
from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.db import connection
from datetime import datetime

def agregar_notificacion(request, cod_cliente):
    if request.method == 'POST':
        tipo_notificacion = request.POST.get('tipo_notificacion')
        fecha_notificacion = request.POST.get('fecha_notificacion')

        # Verificar que el tipo de notificación sea válido
        tipos_validos = ['recordatorio por vencimiento', 'llamada telefonica', 
                         'visita personalizada', 'carta notarial', 'derivacion prejudicial']
        
        if tipo_notificacion not in tipos_validos:
            return HttpResponse("Error: Tipo de notificación no válido", status=400)

        # Obtener el nuevo código de notificación usando la secuencia
        with connection.cursor() as cursor:
            cursor.execute("SELECT nextval('secuencia_notificacion_cobranza')")  # Usamos la secuencia para obtener el siguiente valor
            nuevo_codigo_num = cursor.fetchone()[0]
            nuevo_codigo = f"NC{nuevo_codigo_num:05d}"  # Formatear el código como 'NC00001', 'NC00002', ...

        # Obtener el COD_DEUDA relacionado con el cliente
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT COD_DEUDA 
                FROM Deuda 
                WHERE COD_CLIENTE = %s
            """, [cod_cliente])
            deuda_row = cursor.fetchone()

        if deuda_row:
            cod_deuda = deuda_row[0]
        else:
            cod_deuda = None  # Si no se encuentra la deuda, se establece como None

        # Insertar la nueva notificación en la base de datos
        fecha_envio = datetime.now().strftime('%Y-%m-%d')
        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO Notificacion_cobranza (COD_NOTIFICACION_COBRANZA, FECHA_ENVIO, TIPO_NOTIFICACION, COD_CLIENTE, COD_DEUDA)
                VALUES (%s, %s, %s, %s, %s)
            """, [nuevo_codigo, fecha_envio, tipo_notificacion, cod_cliente, cod_deuda])

        # Determinar el estado de cobranza en función del tipo de notificación
        if tipo_notificacion in ['recordatorio por vencimiento', 'llamada telefonica']:
            estado_cobranza = 'Regular'
        elif tipo_notificacion in ['visita personalizada', 'carta notarial']:
            estado_cobranza = 'Administrativa'
        elif tipo_notificacion == 'derivacion prejudicial':
            estado_cobranza = 'Prejudicial'
        else:
            estado_cobranza = 'Ninguna'  # Estado predeterminado si no encaja en los anteriores

        # Actualizar el estado de cobranza en la tabla Deuda
        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE Deuda
                SET ESTADO_COBRANZA = %s
                WHERE COD_CLIENTE = %s
            """, [estado_cobranza, cod_cliente])

        # Redireccionar al historial de notificaciones (o página que sea relevante)
        return redirect('historial_notificaciones', cod_cliente=cod_cliente)

    # Si no es POST, redirige al historial de notificaciones
    return redirect('historial_notificaciones', cod_cliente=cod_cliente)