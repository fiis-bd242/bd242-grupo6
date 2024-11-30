from django.shortcuts import render
from .models import DimClienteRp, FactReporteDeudas  # Importa el modelo
from django.db import connection
from .forms import FiltroDimClienteForm
from .forms import FiltroFactReporteDeudasForm
def dim_cliente_list(request):
    clientes = DimClienteRp.objects.all()  # Obtén todos los registros de la tabla
    return render(request, 'dim_cliente_list.html', {'clientes': clientes})  # Renderiza la plantilla con el contexto
def fact_list(request):
    facts = FactReporteDeudas.objects.all()  # Obtén todos los registros de la tabla
    return render(request, 'fact_list.html', {'facts': facts})  # Renderiza la plantilla con el contexto


def reporte_deudas(request):
    # Ejecutar la consulta
    facts = FactReporteDeudas.objects.values('ind_analista', 'suma_monto_deuda_analista').distinct()
    return render(request, 'reporte_deudas.html', {'facts': facts})
def cliente_detalle(request, ind_cliente):
    # Usamos el cursor para ejecutar una consulta SQL directa
    with connection.cursor() as cursor:
        # Realizamos la consulta SQL usando el campo 'ind_cliente' en lugar de 'id'
        cursor.execute("SELECT ind_cliente, nombre_cliente, estado_cliente FROM dim_cliente_rp WHERE ind_cliente = %s",
                       [ind_cliente])

        # Recuperamos el resultado
        cliente = cursor.fetchone()  # Devuelve una sola fila de resultados

    # Si se encuentra un cliente, lo pasamos al contexto
    if cliente:
        cliente_context = {
            'ind_cliente': cliente[0],
            'nombre_cliente': cliente[1],
            'estado_cliente': cliente[2],
        }
    else:
        cliente_context = None

    # Renderizamos la plantilla con los datos del cliente
    return render(request, 'cliente_detalle.html', {'cliente': cliente_context})


from django.db import connection


def reporte_deudas_2(request):
    # Obtener los valores de los filtros desde el request GET
    ind_analista = request.GET.get('ind_analista', '')
    trim_cln = request.GET.get('trim_cln', '')
    year_cln = request.GET.get('year_cln', '')

    # Crear la consulta base
    query = """
    SELECT 
        F.IND_ANALISTA AS Analista, 
        T.TRIM_CLN AS TRIMESTRE, 
        T.YEAR_CLN AS YEAR, 
        F.CANTIDAD_CLIENTES_COBRANZA_ADMIN_TRIMESTRE AS Cant_cobr_admin
    FROM 
        FACT_REPORTE_DEUDAS F
    LEFT JOIN 
        DIM_CALENDARIO_RP T 
    ON 
        F.IND_DATE = T.IND_DATE
    WHERE 1=1
    """

    # Lista para los parámetros que se van a pasar a la consulta
    params = []

    # Añadir filtros condicionalmente si tienen valor
    if ind_analista:
        query += " AND F.IND_ANALISTA = %s"
        params.append(ind_analista)
    if trim_cln:
        query += " AND T.TRIM_CLN = %s"
        params.append(trim_cln)
    if year_cln:
        query += " AND T.YEAR_CLN = %s"
        params.append(year_cln)

    query += """
    GROUP BY 
        F.IND_ANALISTA, 
        T.TRIM_CLN, 
        T.YEAR_CLN, 
        F.CANTIDAD_CLIENTES_COBRANZA_ADMIN_TRIMESTRE
    HAVING 
        F.CANTIDAD_CLIENTES_COBRANZA_ADMIN_TRIMESTRE != 0
    ORDER BY 
        F.IND_ANALISTA, 
        T.YEAR_CLN, 
        T.TRIM_CLN;
    """

    # Ejecutar la consulta con los parámetros
    with connection.cursor() as cursor:
        cursor.execute(query, params)
        facts = cursor.fetchall()

    # Pasar los resultados a la plantilla
    return render(request, 'reporte_deudas_compleja.html', {'facts': facts})
def detalle_deuda(request, analista, trimestre, year):
    # Realizamos la consulta SQL usando los parámetros pasados en la URL
    query = """
        SELECT
            S.NAM_CLIENTE,              -- Nombre del cliente
            S.IND_CLIENTE              -- Código del cliente
        FROM 
            FACT_REPORTE_DEUDAS F
        LEFT JOIN DIM_ANALISTA_RP N ON F.IND_ANALISTA = N.IND_ANALISTA
        LEFT JOIN DIM_CLIENTE_RP S ON F.IND_CLIENTE = S.IND_CLIENTE
        LEFT JOIN DIM_CALENDARIO_RP T ON F.IND_DATE = T.IND_DATE
        WHERE
            F.ESTADO_COBRANZA = 'Administrativa'
            AND N.IND_ANALISTA = %s
            AND T.TRIM_CLN = %s
            AND T.YEAR_CLN = %s
        ORDER BY
            T.TRIM_CLN;
    """

    # Ejecutar la consulta SQL
    with connection.cursor() as cursor:
        cursor.execute(query, [analista, trimestre, year])
        clientes = cursor.fetchall()
    return render(request, 'detalle_deuda.html', {
        'analista': analista,
        'trimestre': trimestre,
        'year': year,
        'clientes': clientes
    })










def dim_cliente_list(request):
    form = FiltroDimClienteForm(request.GET)  # Crea el formulario con los datos GET (para obtener los filtros)
    clientes = DimClienteRp.objects.all()  # Consulta base (sin filtros)

    if form.is_valid():
        nombre_cliente = form.cleaned_data.get('nombre_cliente')
        estado_cliente = form.cleaned_data.get('estado_cliente')

        if nombre_cliente:
            clientes = clientes.filter(nombre_cliente__icontains=nombre_cliente)  # Filtra por nombre

        if estado_cliente:
            clientes = clientes.filter(estado_cliente=estado_cliente)  # Filtra por estado

    return render(request, 'dim_cliente_list.html', {'clientes': clientes, 'form': form})


def fact_list(request):
    form = FiltroFactReporteDeudasForm(request.GET)
    facts = FactReporteDeudas.objects.all()  # Consulta base (sin filtros)

    if form.is_valid():
        analista = form.cleaned_data.get('analista')
        trimestre = form.cleaned_data.get('trimestre')
        year = form.cleaned_data.get('year')

        if analista:
            facts = facts.filter(ind_analista__icontains=analista)  # Filtra por analista

        if trimestre:
            facts = facts.filter(trimestre=trimestre)  # Filtra por trimestre

        if year:
            facts = facts.filter(year_cln=year)  # Filtra por año

    return render(request, 'fact_list.html', {'facts': facts, 'form': form})