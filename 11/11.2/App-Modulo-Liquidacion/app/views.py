from django.shortcuts import render
from django.db import connection
from datetime import datetime
from django.http import HttpResponseRedirect
from django.urls import reverse
from datetime import date
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json

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

def modulo_admision(request):
    return render(request, 'modulo1/modulo1.html', {'numero': 1, 'nombre_modulo': 'Admision'})

def modulo_equipos(request):
    return render(request, 'modulo2/modulo2.html', {'numero': 2, 'nombre_modulo': 'Equipos'})

def modulo_recargas(request):
    return render(request, 'modulo3/modulo3.html', {'numero': 3, 'nombre_modulo': 'Recargas'})

def modulo_creditos(request):
    return render(request, 'modulo4/modulo4.html', {'numero': 4, 'nombre_modulo': 'Creditos'})

def modulo_cobranzas(request):
    return render(request, 'modulo5/modulo5.html', {'numero': 5, 'nombre_modulo': 'Cobranzas'})

## MODULO 6
def modulo_liquidacion(request):
    # Analista específico
    cod_analista = 'AS0003'
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM obtener_contratos_vigentes(%s);", [cod_analista])
        contratos = cursor.fetchall()
    contratos_list = [
        {
            'nombre_cliente': contrato[0],
            'clasificacion': contrato[1],
            'codigo': contrato[2],
            'region': contrato[3],
            'fecha_inicio': datetime.strptime(str(contrato[4]), '%Y-%m-%d').strftime('%d/%m/%Y'),
            'fecha_fin_normal': datetime.strptime(str(contrato[5]), '%Y-%m-%d').strftime('%d/%m/%Y'),
            'fecha_fin_real': datetime.strptime(str(contrato[6]), '%Y-%m-%d').strftime('%d/%m/%Y') if contrato[6] else "Sin programar",
        }
        for contrato in contratos
    ]
    return render(request, 'modulo6/modulo6.html', {'numero': 6, 'nombre_modulo': 'Liquidacion', 'contratos': contratos_list})

def modulo_reporteria(request):
    return render(request, 'modulo7/modulo7.html', {'numero': 7, 'nombre_modulo': 'Reporteria'})

## MODULO 6
@csrf_exempt
def programar_resolucion(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)
            codigo_cliente = data.get("codigo")
            fecha_resolucion = data.get("fecha")
            if not codigo_cliente or not fecha_resolucion:
                return JsonResponse({"error": "Datos incompletos."}, status=400)
            with connection.cursor() as cursor:
                cursor.execute("""
                    UPDATE Contrato
                    SET fecha_fin_real = %s
                    WHERE cod_cliente = %s;
                """, [fecha_resolucion, codigo_cliente])
            return JsonResponse({"message": "Fecha programada con éxito"}, status=200)
        except Exception as e:
            print(f"Error: {e}")
            return JsonResponse({"error": "Error al guardar la fecha."}, status=500)
    return JsonResponse({"error": "Método no permitido."}, status=405)

def historico_resoluciones(request):
    anio = request.GET.get('anio')
    mes = request.GET.get('mes')
    estado_cliente = request.GET.get('estado_cliente')
    if request.GET.get('mostrar_todo'):
        anio = mes = estado_cliente = None
    query = "SELECT * FROM obtener_historial_resoluciones()"
    params = []
    if anio:
        query += " WHERE EXTRACT(YEAR FROM fecha_resolucion) = %s"
        params.append(anio)
    if mes:
        mes_map = {
            "Enero": "01", "Febrero": "02", "Marzo": "03", "Abril": "04",
            "Mayo": "05", "Junio": "06", "Julio": "07", "Agosto": "08",
            "Septiembre": "09", "Octubre": "10", "Noviembre": "11", "Diciembre": "12"
        }
        month_number = mes_map.get(mes)
        if month_number:
            if "WHERE" in query:
                query += " AND EXTRACT(MONTH FROM fecha_resolucion) = %s"
            else:
                query += " WHERE EXTRACT(MONTH FROM fecha_resolucion) = %s"
            params.append(month_number)
    if estado_cliente:
        if "WHERE" in query:
            query += " AND estado_cliente = %s"
        else:
            query += " WHERE estado_cliente = %s"
        params.append(estado_cliente)
    with connection.cursor() as cursor:
        cursor.execute(query, params)
        resultados = cursor.fetchall()
    columnas = ['nombre_cliente', 'representante_legal', 'fecha_resolucion', 'estado_cliente', 'codigo_cliente']
    registros = [dict(zip(columnas, fila)) for fila in resultados]
    return render(request, 'modulo6/liquidacion.html', {
        'registros': registros,
        'anio': anio,
        'mes': mes,
        'estado_cliente': estado_cliente
    })

def detalle_combinado(request, codigo_cliente):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM obtener_detalle_cliente(%s)", [codigo_cliente])
        detalle = cursor.fetchone()
    columnas_cliente = ['nombre_cliente', 'representante_legal', 'fecha_resolucion']
    datos_cliente = dict(zip(columnas_cliente, detalle)) if detalle else {}
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM obtener_liquidaciones_cliente(%s)", [codigo_cliente])
        liquidaciones = cursor.fetchall()
    columnas_liquidacion = [
        'codigo', 'fecha_emitida', 'fecha_lim_obs', 'fecha_finalizacion',
        'monto_deuda_acum', 'monto_garantias', 'monto_comisiones'
    ]
    datos_liquidaciones = [dict(zip(columnas_liquidacion, liq)) for liq in liquidaciones]
    pre_liquidacion = datos_liquidaciones[0] if len(datos_liquidaciones) > 0 else None
    liquidacion_final = datos_liquidaciones[1] if len(datos_liquidaciones) > 1 else None
    return render(request, 'modulo6/detallesliq.html', {
        'datos_cliente': datos_cliente,
        'pre_liquidacion': pre_liquidacion,
        'liquidacion_final': liquidacion_final
    })
