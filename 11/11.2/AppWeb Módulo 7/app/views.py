from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required, user_passes_test
from .models import Solicitud, Documento, Entrevista, Capacitacion, Seguimiento, Solicitante
from .forms import SolicitudForm, SolicitanteForm, DocumentoForm, EntrevistaForm, CapacitacionForm, SeguimientoForm
from django.contrib.auth.models import User
from django.utils import timezone
from django.http import Http404
from django.shortcuts import render, redirect
from .forms import DocumentoFormSet
from .models import Solicitud, Solicitante, Documento
from django.shortcuts import render, get_object_or_404, redirect
from django.forms import modelformset_factory
from .models import Solicitud, Documento
from .forms import DocumentoForm
from django import forms
from mongoengine import connect

connect('AppWebBaseMongo', host='mongodb://localhost:27017')

from couchbase.cluster import Cluster, ClusterOptions
from couchbase.auth import PasswordAuthenticator
from couchbase.bucket import Bucket
import base64 

# Configuración del cliente Couchbase
cluster = Cluster('couchbase://localhost', ClusterOptions(PasswordAuthenticator('Administrator', 'admin123')))
bucket = cluster.bucket('ArchivosCouch')  # Asegúrate de usar el nombre de tu bucket
collection = bucket.default_collection()

def save_file_to_couchbase(cod_documento, archivo):
    data = archivo.read()
    collection.upsert(cod_documento, {"archivo": data, "content_type": archivo.content_type})
    
from django.http import HttpResponse
from couchbase.exceptions import DocumentNotFoundException


# Mapeo de tipos MIME a extensiones de archivo
MIME_TO_EXT = {
    "application/msword": ".doc",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document": ".docx",
    "application/pdf": ".pdf",
    "application/vnd.ms-powerpoint": ".ppt",
    "application/vnd.openxmlformats-officedocument.presentationml.presentation": ".pptx",
    "application/vnd.ms-excel": ".xls",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": ".xlsx",
}

def serve_couchbase_file(request, cod_documento):
    try:
        # Recupera el documento desde Couchbase
        result = collection.get(cod_documento).content_as[dict]
        archivo_base64 = result.get("archivo")
        
        # Decodifica el archivo de Base64 a binario
        archivo_binario = base64.b64decode(archivo_base64)
        
        # Obtén el tipo de contenido del archivo
        content_type = result.get("content_type", "application/octet-stream")
        
        # Determina la extensión de archivo basada en el tipo MIME
        file_extension = MIME_TO_EXT.get(content_type, ".bin")  # Asigna .bin si no se encuentra el tipo MIME
        
        # Devuelve el archivo como respuesta con el tipo de contenido adecuado
        response = HttpResponse(archivo_binario, content_type=content_type)
        response['Content-Disposition'] = f'attachment; filename="{cod_documento}{file_extension}"'  # Usa la extensión dinámica
        
        # Retorna la respuesta para la descarga
        return response
    except DocumentNotFoundException:
        return HttpResponse("Archivo no encontrado", status=404)




# Función para verificar si el usuario es analista
def is_analista(user):
    return user.groups.filter(name='Analista').exists()

# Vista para la página de inicio de los solicitantes
@login_required
def index_solicitante(request):
    if request.method == 'POST':
        solicitanteForm = SolicitanteForm(request.POST)
        

        if solicitanteForm.is_valid():
            # Verificar si ya existe un solicitante con el código igual al username del usuario
            solicitante, created = Solicitante.objects.get_or_create(
                cod_solicitante=request.user.username,
                defaults={  # Si no existe, se crean estos campos
                    'nombre_sol': solicitanteForm.cleaned_data['nombre_sol'],
                    'ruc_sol': solicitanteForm.cleaned_data['ruc_sol'],
                    'dni_sol': solicitanteForm.cleaned_data['dni_sol'],
                    'ubicacion_sol': solicitanteForm.cleaned_data['ubicacion_sol'],
                    'correo_electronico_sol': solicitanteForm.cleaned_data['correo_electronico_sol'],
                    'telefono_sol': solicitanteForm.cleaned_data['telefono_sol'],
                }
            )   

        if not created:  # Si el solicitante ya existía, actualizamos los campos
            solicitante.nombre_sol = solicitanteForm.cleaned_data['nombre_sol']
            solicitante.ruc_sol = solicitanteForm.cleaned_data['ruc_sol']
            solicitante.dni_sol = solicitanteForm.cleaned_data['dni_sol']
            solicitante.ubicacion_sol = solicitanteForm.cleaned_data['ubicacion_sol']
            solicitante.correo_electronico_sol = solicitanteForm.cleaned_data['correo_electronico_sol']
            solicitante.telefono_sol = solicitanteForm.cleaned_data['telefono_sol']
            solicitante.save()



            return redirect('index_solicitante')  # Cambia a la URL deseada
        else:
            print(solicitanteForm.errors)
    else:

        solicitante=get_object_or_404(Solicitante, cod_solicitante=request.user.username)
        solicitanteForm = SolicitanteForm(instance=solicitante)
        

    return render(request, 'index_solicitante.html', {
        'solicitud_form': solicitanteForm,
    })

@login_required
def crear_solicitud(request):
    if request.method == 'POST':
        solicitudform = SolicitudForm(request.POST)
        
        if solicitudform.is_valid():
            print(request.user.username)
            # Crear la solicitud
            solicitud = Solicitud.objects.create(
                cod_solicitud='SOLIC' + str(Solicitud.objects.count() + 5).zfill(6),
                fecha_inicio_solicitud=solicitudform.cleaned_data['fecha_inicio_solicitud'],
                tipo_solicitud=solicitudform.cleaned_data['tipo_solicitud'],
                estado_solicitud='PENDIENTE',  # Estado inicial
                cod_solicitante= Solicitante.objects.get(cod_solicitante=request.user.username)  # Asociar al solicitante del usuario
            )
            return redirect('index_solicitante')  # Redirige al inicio o a la página deseada
        else:
            print(solicitudform.errors)
    else:
        solicitudform = SolicitudForm()

    return render(request, 'crear_solicitudes.html', {
        'solicitud_form': solicitudform,
    })

# Vista para la lista de solicitudes de un solicitante
@login_required
def solicitudes_list(request):
    # Filtra las solicitudes usando el cod_solicitante del solicitante
    solicitudes = Solicitud.objects.filter(cod_solicitante=request.user.username)

    # Creamos el formset para los documentos
    DocumentoFormSet = modelformset_factory(Documento, form=DocumentoForm, extra=1, can_delete=True)

    solicitudes_with_formsets = []

    if request.method == 'POST':
        cod_solicitante = request.user.username
        cod_solicitud = "xd"
        
        # Aquí estamos pasando tanto los datos del formulario como los archivos
        formset = DocumentoFormSet(
            request.POST,
            request.FILES,  # Asegúrate de pasar los archivos al formset
            queryset=Documento.objects.filter(solicitud_id=request.POST.get('cod_solicitud'))
        )
        print(formset.queryset)
        if formset.is_valid():
            # Guardamos los documentos asociados a esta solicitud


            for form in formset:
                #document = form.save(commit=False)
                #document.solicitud = Solicitud.objects.filter(cod_solicitud=form.cleaned_data['solicitud_pointer']).first()
                #document.fecha_recibido = timezone.now()
                # Lógica para manejar la versión del documento
                # Buscar si ya existe un documento con el mismo nombre (archivo) en esta solicitud
                #existing_document = Documento.objects.filter(solicitud_id=form.cleaned_data['solicitud_pointer'], nombre_doc=document.nombre_doc).first()
                
                #if existing_document:
                    # Si el documento ya existe, incrementamos la versión
                    #document.version = Documento.objects.filter(solicitud_id=form.cleaned_data['solicitud_pointer'], nombre_doc=document.nombre_doc).count() + 1
                #else:
                    # Si no existe, la versión es 1
                    #document.version = 1
                #document.save()

                ###PRUEBAAAAAAAAA
                cod_solicitud= form.cleaned_data['solicitud_pointer']
                if Documento.objects.filter(cod_documento=form.cleaned_data['cod_documento_pointer']).first() and (not (form.cleaned_data.get('DELETE', False))):
                    documento=  Documento.objects.filter(cod_documento=form.cleaned_data['cod_documento_pointer']).update(
                        nombre_doc=form.cleaned_data['nombre_doc'],
                        tipo_doc=form.cleaned_data['tipo_doc'],
                    )
                    # Guardar el archivo en Couchbase si existe
                    archivo = form.cleaned_data.get('archivo')  # Obtenemos el archivo del formulario

                    if archivo:
                        cod_documento = form.cleaned_data['cod_documento_pointer']
                        try:
                            # Intentamos recuperar el documento de Couchbase
                            existing_document = collection.get(cod_documento).content_as[dict]
                            archivo_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                            # Si existe, actualizamos el archivo
                            updated_document = {
                                "archivo": archivo_base64,
                                "content_type": archivo.content_type,  # Tipo de archivo
                                "fecha_subida": timezone.now().isoformat()  # Actualizamos la fecha
                            }
                            collection.upsert(cod_documento, updated_document)
                        except DocumentNotFoundException:
                            archivo_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                                # Si no existe, creamos un nuevo documento
                            new_document = {
                                "archivo": archivo_base64,
                                "content_type": archivo.content_type,
                                "fecha_subida": timezone.now().isoformat()
                            }
                            collection.insert(cod_documento, new_document)
                else:
                    existing_document = Documento.objects.filter(solicitud_id=cod_solicitud, nombre_doc=form.cleaned_data['nombre_doc'],tipo_doc=form.cleaned_data['tipo_doc']).first()
                    archivo = form.cleaned_data.get('archivo')  # Obtenemos el archivo del formulario
                    if not (form.cleaned_data.get('DELETE', False)):
                        if existing_document:
                            # Si un documento con mismo nombre y tipo ya existe, creamos uno con versión incrementada
                            cod_documento_temp='DOC' + str(Documento.objects.count() + 5).zfill(6)
                            documento = Documento.objects.create(
                            cod_documento=cod_documento_temp,
                            fecha_recibido = timezone.now(),
                            nombre_doc=form.cleaned_data['nombre_doc'],
                            tipo_doc=form.cleaned_data['tipo_doc'],
                            estado_validacion='PENDIENTE',  # Estado inicial
                            version = (Documento.objects.filter(solicitud_id=cod_solicitud, nombre_doc=form.cleaned_data['nombre_doc'],tipo_doc=form.cleaned_data['tipo_doc']).count() + 1),
                            solicitud= Solicitud.objects.get(cod_solicitud=form.cleaned_data['solicitud_pointer'])  # Asociar al solicitante del usuario
                            )
                            # Guardar un nuevo archivo en Couchbase
                            archivo_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                            collection.upsert(cod_documento_temp, {
                                "archivo": archivo_base64,  # Guarda el archivo como binario
                                "content_type": archivo.content_type,  # Tipo MIME del archivo
                                "fecha_subida": timezone.now().isoformat()  # Fecha de subida en formato ISO
                                })
                        else:
                        # Si no existe, la versión es 1
                            cod_documento_temp='DOC' + str(Documento.objects.count() + 5).zfill(6)
                            documento = Documento.objects.create(
                            cod_documento=cod_documento_temp,
                            fecha_recibido = timezone.now(),
                            nombre_doc=form.cleaned_data['nombre_doc'],
                            tipo_doc=form.cleaned_data['tipo_doc'],
                            estado_validacion='PENDIENTE',  # Estado inicial
                            solicitud= Solicitud.objects.get(cod_solicitud=form.cleaned_data['solicitud_pointer']),  # Asociar al solicitante del usuario
                            version = 1
                            )
                            archivo_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                            collection.upsert(cod_documento_temp, {
                                "archivo": archivo_base64,  # Guarda el archivo como binario
                                "content_type": archivo.content_type,  # Tipo MIME del archivo
                                "fecha_subida": timezone.now().isoformat()  # Fecha de subida en formato ISO
                                })

                    else:
                        cod_doc = form.cleaned_data['cod_documento_pointer']
                        # Ahora puedes realizar la acción de eliminar el documento
                        try:
                            documento = Documento.objects.get(cod_documento=cod_doc)
                            documento.delete()
                            # Intentar obtener el documento en Couchbase
                            archivo_couchbase = collection.get(cod_doc)
                            # Si existe, eliminar el documento
                            collection.remove(cod_doc)
                        except Documento.DoesNotExist:
                            # Si no se encuentra el documento, podemos manejar el error
                            pass
            
            return redirect('solicitudes_list')
        else:
            for form in formset:
                if form.is_valid():
                    cod_solicitud= form.cleaned_data['solicitud_pointer']
                    if Documento.objects.filter(cod_documento=form.cleaned_data['cod_documento_pointer']).first() and (not (form.cleaned_data.get('DELETE', False))):
                        documento=  Documento.objects.filter(cod_documento=form.cleaned_data['cod_documento_pointer']).update(
                            nombre_doc=form.cleaned_data['nombre_doc'],
                            tipo_doc=form.cleaned_data['tipo_doc'],
                        )
                        # Guardar el archivo en MongoDB si existe
                        archivo = form.cleaned_data.get('archivo')  # Obtenemos el archivo del formulario
                        if archivo:
                            cod_documento = form.cleaned_data['cod_documento_pointer']
                            try:
                                # Intentamos recuperar el documento de Couchbase
                                existing_document = collection.get(cod_documento).content_as[dict]
                                archivo_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                                # Si existe, actualizamos el archivo
                                updated_document = {
                                    "archivo": archivo_base64,
                                    "content_type": archivo.content_type,  # Tipo de archivo
                                    "fecha_subida": timezone.now().isoformat()  # Actualizamos la fecha
                                }
                                collection.upsert(cod_documento, updated_document)
                            except DocumentNotFoundException:
                                # Si no existe, creamos un nuevo documento
                                archivo_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                                new_document = {
                                    "archivo": archivo_base64,
                                    "content_type": archivo.content_type,
                                    "fecha_subida": timezone.now().isoformat()
                                }
                                collection.insert(cod_documento, new_document)
                    else:
                        existing_document = Documento.objects.filter(solicitud_id=cod_solicitud, nombre_doc=form.cleaned_data['nombre_doc'],tipo_doc=form.cleaned_data['tipo_doc']).first()

                        if not (form.cleaned_data.get('DELETE', False)):
                            if existing_document:
                            # Si el documento ya existe, incrementamos la versión
                                cod_documento_temp='DOC' + str(Documento.objects.count() + 5).zfill(6)
                                documento = Documento.objects.create(
                                cod_documento=cod_documento_temp,
                                fecha_recibido = timezone.now(),
                                nombre_doc=form.cleaned_data['nombre_doc'],
                                tipo_doc=form.cleaned_data['tipo_doc'],
                                estado_validacion='PENDIENTE',  # Estado inicial
                                version = (Documento.objects.filter(solicitud_id=cod_solicitud, nombre_doc=form.cleaned_data['nombre_doc'],tipo_doc=form.cleaned_data['tipo_doc']).count() + 1),
                                solicitud= Solicitud.objects.get(cod_solicitud=form.cleaned_data['solicitud_pointer'])  # Asociar al solicitante del usuario
                                )
                                archivo = form.cleaned_data.get('archivo')
                                archivo_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                                collection.upsert(cod_documento_temp, {
                                    "archivo": archivo_base64,  # Guarda el archivo como binario
                                    "content_type": archivo.content_type,  # Tipo MIME del archivo
                                    "fecha_subida": timezone.now().isoformat()  # Fecha de subida en formato ISO
                                })
                            else:
                            # Si no existe, la versión es 1
                                cod_documento_temp='DOC' + str(Documento.objects.count() + 5).zfill(6)
                                documento = Documento.objects.create(
                                cod_documento=cod_documento_temp,
                                fecha_recibido = timezone.now(),
                                nombre_doc=form.cleaned_data['nombre_doc'],
                                tipo_doc=form.cleaned_data['tipo_doc'],
                                estado_validacion='PENDIENTE',  # Estado inicial
                                solicitud= Solicitud.objects.get(cod_solicitud=form.cleaned_data['solicitud_pointer']),  # Asociar al solicitante del usuario
                                version = 1
                                )
                                archivo = form.cleaned_data.get('archivo')
                                archivo_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                                collection.upsert(cod_documento_temp, {
                                    "archivo": archivo_base64,  # Guarda el archivo como binario
                                    "content_type": archivo.content_type,  # Tipo MIME del archivo
                                    "fecha_subida": timezone.now().isoformat()  # Fecha de subida en formato ISO
                                })

                        else:
                            cod_doc = form.cleaned_data['cod_documento_pointer']
                            # Ahora puedes realizar la acción de eliminar el documento
                            try:
                                documento = Documento.objects.get(cod_documento=cod_doc)
                                documento.delete()
                                # Intentar obtener el documento en Couchbase
                                archivo_couchbase = collection.get(cod_doc)
                                # Si existe, eliminar el documento
                                collection.remove(cod_doc)
                            except Documento.DoesNotExist:
                                # Si no se encuentra el documento, podemos manejar el error
                                pass
                                
                else:
                    print("Formulario invalido")
                    print(form.errors)
            return redirect('solicitudes_list')
    else:

        # Si no es un POST, cargamos los formsets para cada solicitud
        for solicitud in solicitudes:
            formset = DocumentoFormSet(queryset=Documento.objects.filter(solicitud_id=solicitud.cod_solicitud))
            # Asegurarse de pasar el usuario para filtrar las solicitudes en el formulario
            for form in formset:
                form.initial['solicitud_pointer'] = solicitud.cod_solicitud
                form.user = request.user  # Establecemos el usuario actual
                
                if 'cod_documento' in form.initial:
                    # Si 'cod_documento' está en initial, hacer algo si existe
                    form.initial['cod_documento_pointer'] = form.initial['cod_documento']
                    form.initial['cod_documento'] ="xdd"
                    
                else:
                    # Si no existe en initial, hacer algo distinto
                    
                    form.fields['DELETE'].widget = forms.HiddenInput()
                    form.initial['cod_documento'] ="xd"
                    form.initial['cod_documento_pointer'] = 'DOC' + str(Documento.objects.count() + 5).zfill(6)
                    
                    # Aquí ocultamos el campo DELETE
                
              
            solicitudes_with_formsets.append((solicitud, formset))
 

    return render(request, 'solicitudes_list.html', {
        'solicitudes_with_formsets': solicitudes_with_formsets,
    })



# Vista para ver detalles de una solicitud
@login_required
def solicitud_detalle(request, cod_solicitud):
    try:
        solicitud = Solicitud.objects.get(cod_solicitud=cod_solicitud)
    except Solicitud.DoesNotExist:
        raise Http404("Solicitud no encontrada")
    
    documentos = Documento.objects.filter(solicitud_id=solicitud)
    entrevistas = Entrevista.objects.filter(solicitud_id=solicitud)
    capacitaciones = Capacitacion.objects.filter(solicitud_id=solicitud)
    seguimientos = Seguimiento.objects.filter(solicitud_id=solicitud)

    return render(request, 'solicitud_detalle.html', {
        'solicitud': solicitud,
        'documentos': documentos,
        'entrevistas': entrevistas,
        'capacitaciones': capacitaciones,
        'seguimientos': seguimientos,
    })

@login_required
def agregar_documentos(request, id):
    solicitud = get_object_or_404(Solicitud, id=id)
    
    # Crear un FormSet para los documentos asociados a la solicitud
    DocumentoFormSet = modelformset_factory(Documento, form=DocumentoForm, extra=1, can_delete=True)
    
    if request.method == 'POST':
        formset = DocumentoFormSet(request.POST)
        if formset.is_valid():
            for form in formset:
                document = form.save(commit=False)
                if not document.solicitud:
                    document.solicitud = solicitud  # Asignamos la solicitud al documento
                document.save()
                archivo = form.cleaned_data.get('archivo')  # Obtenemos el archivo del formulario

                if archivo:
                    cod_documento = form.cleaned_data['cod_documento_pointer']
                    try:
                        # Intentamos recuperar el documento de Couchbase
                        existing_document = collection.get(cod_documento).content_as[dict]
                        archivo_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                        # Si existe, actualizamos el archivo
                        updated_document = {
                            "archivo": archivo_base64,
                            "content_type": archivo.content_type,  # Tipo de archivo
                            "fecha_subida": timezone.now().isoformat()  # Actualizamos la fecha
                        }
                        collection.upsert(cod_documento, updated_document)
                    except DocumentNotFoundException:
                        archivo_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                            # Si no existe, creamos un nuevo documento
                        new_document = {
                            "archivo": archivo_base64,
                            "content_type": archivo.content_type,
                            "fecha_subida": timezone.now().isoformat()
                        }
                        collection.insert(cod_documento, new_document)

            return redirect('solicitudes_list')  # Redirigir después de guardar los documentos

    else:
        formset = DocumentoFormSet(queryset=Documento.objects.filter(solicitud=solicitud))
    
    return render(request, 'agregar_documentos.html', {
        'solicitud': solicitud,
        'formset': formset,
    })

# Vista para que el analista vea las solicitudes pendientes
@login_required
@user_passes_test(is_analista)  # Solo accesible por analistas
def solicitudes_pendientes(request):
    solicitudes = Solicitud.objects.filter(estado_solicitud='PENDIENTE')
    return render(request, 'solicitudes_pendientes.html', {'solicitudes': solicitudes})
# Vista para que el analista vea las solicitudes pendientes y pueda filtrarlas
@login_required
@user_passes_test(is_analista)  # Solo accesible por analistas
def solicitudes_pendientes(request):
    solicitudes = Solicitud.objects.all()

    
    # Filtrar por código de solicitante si se proporciona
    cod_solicitante = request.GET.get('cod_solicitante', '')
    if cod_solicitante:
        solicitudes = solicitudes.filter(cod_solicitante=cod_solicitante)
    
    # Filtrar por atributos relacionados al Solicitante
    ruc_solicitante = request.GET.get('ruc_solicitante', '')
    dni_solicitante = request.GET.get('dni_solicitante', '')
    correo_solicitante = request.GET.get('correo_solicitante', '')
    telefono_solicitante = request.GET.get('telefono_solicitante', '')
    nombre_solicitante = request.GET.get('nombre_solicitante', '')

    if any([ruc_solicitante, dni_solicitante, correo_solicitante, telefono_solicitante, nombre_solicitante]):
        solicitantes = Solicitante.objects.all()
        if ruc_solicitante:
            solicitantes = solicitantes.filter(ruc_sol__icontains=ruc_solicitante)
        if dni_solicitante:
            solicitantes = solicitantes.filter(dni_sol__icontains=dni_solicitante)
        if correo_solicitante:
            solicitantes = solicitantes.filter(correo_electronico_sol__icontains=correo_solicitante)
        if telefono_solicitante:
            solicitantes = solicitantes.filter(telefono_sol__icontains=telefono_solicitante)
        if nombre_solicitante:
            solicitantes = solicitantes.filter(nombre_sol__icontains=nombre_solicitante)
        
        # Filtrar las solicitudes basadas en los solicitantes encontrados
        solicitudes = solicitudes.filter(cod_solicitante__in=solicitantes.values_list('cod_solicitante', flat=True))
    
    # Filtrar por estado de solicitud si se proporciona
    estado_solicitud = request.GET.get('estado_solicitud', '')
    if estado_solicitud:
        solicitudes = solicitudes.filter(estado_solicitud__icontains=estado_solicitud)
    
    # Filtrar por tipo de solicitud si se proporciona
    tipo_solicitud = request.GET.get('tipo_solicitud', '')
    if tipo_solicitud:
        solicitudes = solicitudes.filter(tipo_solicitud__icontains=tipo_solicitud)
    
    # Filtrar por fecha de inicio si se proporciona
    fecha_inicio = request.GET.get('fecha_inicio', '')
    if fecha_inicio:
        solicitudes = solicitudes.filter(fecha_inicio_solicitud__gte=fecha_inicio)
    
    # Filtrar por fecha de fin si se proporciona
    fecha_fin = request.GET.get('fecha_fin', '')
    if fecha_fin:
        solicitudes = solicitudes.filter(fecha_fin_solicitud__lte=fecha_fin)

    return render(request, 'solicitudes_pendientes.html', {'solicitudes': solicitudes})
# Vista para que el analista vea los detalles de una solicitud y modifique su estado
@login_required
@user_passes_test(is_analista)  # Solo accesible por analistas
def gestionar_solicitud(request, cod_solicitud):
    try:
        solicitud = Solicitud.objects.get(cod_solicitud=cod_solicitud)
    except Solicitud.DoesNotExist:
        raise Http404("Solicitud no encontrada")

    if request.method == 'POST':
        form = SolicitudForm(request.POST, instance=solicitud)
        if form.is_valid():
            form.save()
            return redirect('solicitudes_pendientes')
    else:
        form = SolicitudForm(instance=solicitud)

    return render(request, 'gestionar_solicitud.html', {'form': form, 'solicitud': solicitud})

# Vista para que un analista gestione los documentos de una solicitud
@login_required
@user_passes_test(is_analista)  # Solo accesible por analistas
def gestionar_documentos(request, cod_solicitud):
    try:
        solicitud = Solicitud.objects.get(cod_solicitud=cod_solicitud)
    except Solicitud.DoesNotExist:
        raise Http404("Solicitud no encontrada")

    documentos = Documento.objects.filter(solicitud=solicitud)

    if request.method == 'POST':
        form = DocumentoForm(request.POST, request.FILES)
        if form.is_valid():
            documento = form.save(commit=False)
            documento.solicitud = solicitud
            documento.fecha_recibido= timezone.now()
            documento.save()
            archivo = form.cleaned_data.get('archivo')  # Obtenemos el archivo del formulario

            if archivo:
                cod_documento = form.cleaned_data['cod_documento']
                print("Codddd",cod_documento)
                try:
                    # Intentamos recuperar el documento de Couchbase
                    existing_document = collection.get(cod_documento).content_as[dict]
                    archivo_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                    # Si existe, actualizamos el archivo
                    updated_document = {
                        "archivo": archivo_base64,
                        "content_type": archivo.content_type,  # Tipo de archivo
                        "fecha_subida": timezone.now().isoformat()  # Actualizamos la fecha
                    }
                    collection.upsert(cod_documento, updated_document)
                except DocumentNotFoundException:
                    archivo_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                    # Si no existe, creamos un nuevo documento
                    new_document = {
                        "archivo": archivo_base64,
                        "content_type": archivo.content_type,
                        "fecha_subida": timezone.now().isoformat()
                    }
                    collection.insert(cod_documento, new_document)
            return redirect('gestionar_documentos', cod_solicitud=cod_solicitud)
    else:
        form = DocumentoForm()
        form.initial['cod_documento'] = 'DOC' + str(Documento.objects.count() + 5).zfill(6)
    return render(request, 'gestionar_documentos.html', {
        'form': form,
        'documentos': documentos,
        'solicitud': solicitud
    })

# Vista para que un analista registre una entrevista
@login_required
@user_passes_test(is_analista)  # Solo accesible por analistas
def registrar_entrevista(request, cod_solicitud):
    try:
        solicitud = Solicitud.objects.get(cod_solicitud=cod_solicitud)
    except Solicitud.DoesNotExist:
        raise Http404("Solicitud no encontrada")
    if request.method == 'POST':
        form = EntrevistaForm(request.POST)
        if form.is_valid():
            entrevista = form.save(commit=False)
            entrevista.cod_entrevista = 'ENT' + str(Entrevista.objects.count() + 5).zfill(6)
            entrevista.solicitud = solicitud
            entrevista.save()
            return redirect('gestionar_entrevistas', cod_solicitud=cod_solicitud)
    else:
        form = EntrevistaForm()

    return render(request, 'registrar_entrevista.html', {'form': form, 'solicitud': solicitud})

# Vista para que el analista registre una capacitación
@login_required
@user_passes_test(is_analista)  # Solo accesible por analistas
def registrar_capacitacion(request, cod_solicitud):
    try:
        solicitud = Solicitud.objects.get(cod_solicitud=cod_solicitud)
    except Solicitud.DoesNotExist:
        raise Http404("Solicitud no encontrada")

    if request.method == 'POST':
        form = CapacitacionForm(request.POST)
        if form.is_valid():
            capacitacion = form.save(commit=False)
            capacitacion.cod_capacitacion= 'CAP' + str(Capacitacion.objects.count() + 5).zfill(6)
            capacitacion.solicitud = solicitud
            capacitacion.save()
            return redirect('gestionar_capacitaciones', cod_solicitud=cod_solicitud)
    else:
        form = CapacitacionForm()

    return render(request, 'registrar_capacitacion.html', {'form': form, 'solicitud': solicitud})

# Vista para que el analista registre un seguimiento
@login_required
@user_passes_test(is_analista)  # Solo accesible por analistas
def registrar_seguimiento(request, cod_solicitud):
    try:
        solicitud = Solicitud.objects.get(cod_solicitud=cod_solicitud)
    except Solicitud.DoesNotExist:
        raise Http404("Solicitud no encontrada")
    if request.method == 'POST':
        form = SeguimientoForm(request.POST)
        if form.is_valid():
            seguimiento = form.save(commit=False)
            seguimiento.cod_seguimiento= 'SEG' + str(Seguimiento.objects.count() + 5).zfill(6)
            seguimiento.solicitud = solicitud
            seguimiento.save()
            return redirect('gestionar_seguimientos', cod_solicitud=cod_solicitud)
    else:
        form = SeguimientoForm()

    return render(request, 'registrar_seguimiento.html', {'form': form, 'solicitud': solicitud})

# Vista para que el analista vea los detalles de las entrevistas
@login_required
@user_passes_test(is_analista)  # Solo accesible por analistas
def gestionar_entrevistas(request, cod_solicitud):
    try:
        solicitud = Solicitud.objects.get(cod_solicitud=cod_solicitud)
    except Solicitud.DoesNotExist:
        raise Http404("Solicitud no encontrada")

    entrevistas = Entrevista.objects.filter(solicitud=solicitud)
    return render(request, 'gestionar_entrevistas.html', {'entrevistas': entrevistas, 'solicitud': solicitud})

# Vista para que el analista vea los detalles de las capacitaciones
@login_required
@user_passes_test(is_analista)  # Solo accesible por analistas
def gestionar_capacitaciones(request, cod_solicitud):
    # Obtener la solicitud correspondiente
    solicitud = get_object_or_404(Solicitud, cod_solicitud=cod_solicitud)
    
    # Obtener todas las capacitaciones asociadas con esta solicitud
    capacitaciones = Capacitacion.objects.filter(solicitud=solicitud)
    # Lógica para crear una nueva capacitación
    if request.method == 'POST':
        form = CapacitacionForm(request.POST)
        if form.is_valid():
            # Establecer la solicitud relacionada con la capacitación
            capacitacion = form.save(commit=False)
            capacitacion.cod_capacitacion = 'CAP' + str(Capacitacion.objects.count() + 5).zfill(6)
            capacitacion.solicitud = solicitud  # Asociar la solicitud con la nueva capacitación
            capacitacion.save()  # Guardar la nueva capacitación
            return redirect('gestionar_capacitaciones', cod_solicitud=cod_solicitud)
    else:
        form = CapacitacionForm()

    return render(request, 'gestionar_capacitaciones.html', {
        'solicitud': solicitud,
        'capacitaciones': capacitaciones,
        'form': form,
    })
# Vista para que el analista vea los detalles de los seguimientos
@login_required
@user_passes_test(is_analista)  # Solo accesible por analistas
def gestionar_seguimientos(request, cod_solicitud):
    try:
        solicitud = Solicitud.objects.get(cod_solicitud=cod_solicitud)
    except Solicitud.DoesNotExist:
        raise Http404("Solicitud no encontrada")

    seguimientos = Seguimiento.objects.filter(solicitud=solicitud)
    return render(request, 'gestionar_seguimientos.html', {'seguimientos': seguimientos, 'solicitud': solicitud})

###MEJORASSSSSSS
from .models import Capacitacion
from .forms import CapacitacionForm

# Vista para editar la capacitación
@login_required
@user_passes_test(is_analista)  # Solo accesible por analistas
def editar_capacitacion(request, cod_capacitacion):
    capacitacion = get_object_or_404(Capacitacion, cod_capacitacion=cod_capacitacion)
    if request.method == 'POST':
        form = CapacitacionForm(request.POST, instance=capacitacion)
        if form.is_valid():
            form.save()
            return redirect('gestionar_capacitaciones', cod_solicitud=capacitacion.solicitud.cod_solicitud)
    else:
        form = CapacitacionForm(instance=capacitacion)
    return redirect('gestionar_capacitaciones', cod_solicitud=capacitacion.solicitud.cod_solicitud)

# Vista para eliminar la capacitación
@login_required
@user_passes_test(is_analista)  # Solo accesible por analistas
def eliminar_capacitacion(request, cod_capacitacion):
    capacitacion = get_object_or_404(Capacitacion, cod_capacitacion=cod_capacitacion)
    if request.method == 'POST':
        capacitacion.delete()
        return redirect('gestionar_capacitaciones', cod_solicitud=capacitacion.solicitud.cod_solicitud)
    return render('gestionar_capacitaciones.html', cod_solicitud=capacitacion.solicitud.cod_solicitud)

# Vista para cambiar el estado del documento
def cambiar_estado_documento(request, cod_documento):
    if request.method == 'POST':
        print(cod_documento)
        documento = get_object_or_404(Documento, cod_documento=cod_documento)
        nuevo_estado = request.POST.get('estado')
        if nuevo_estado in ['PENDIENTE', 'VALIDADO', 'RECHAZADO']:
            documento.estado_validacion = nuevo_estado
            documento.save()
        return redirect('gestionar_documentos', cod_solicitud=documento.solicitud.cod_solicitud)

# Vista para eliminar el documento
def eliminar_documento(request, cod_documento):
    documento = get_object_or_404(Documento, cod_documento=cod_documento)
    solicitud_cod = documento.solicitud.cod_solicitud
    documento.delete()
    try:
        
        # Intentar obtener el documento en Couchbase
        archivo_couchbase = collection.get(cod_documento)
        # Si existe, eliminar el documento
        collection.remove(cod_documento)
    except Documento.DoesNotExist:
        # Si no se encuentra el documento, podemos manejar el error
            pass
    return redirect('gestionar_documentos', cod_solicitud=solicitud_cod)

# Vista para editar seguimiento
def editar_seguimiento(request, cod_seguimiento):
    seguimiento = get_object_or_404(Seguimiento, cod_seguimiento=cod_seguimiento)

    if request.method == 'POST':
        form = SeguimientoForm(request.POST, instance=seguimiento)
        if form.is_valid():
            form.save()
            return redirect('gestionar_seguimientos', cod_solicitud=seguimiento.solicitud.cod_solicitud)
    else:
        form = SeguimientoForm(instance=seguimiento)

    return render(request, 'editar_seguimiento.html', {'form': form, 'seguimiento': seguimiento})


# Vista para eliminar seguimiento
def eliminar_seguimiento(request, cod_seguimiento):
    seguimiento = get_object_or_404(Seguimiento, cod_seguimiento=cod_seguimiento)
    solicitud_cod = seguimiento.solicitud.cod_solicitud
    seguimiento.delete()
    return redirect('gestionar_seguimientos', cod_solicitud=solicitud_cod)

# Vista para editar entrevista
def editar_entrevista(request, cod_entrevista):
    entrevista = get_object_or_404(Entrevista, cod_entrevista=cod_entrevista)

    if request.method == 'POST':
        form = EntrevistaForm(request.POST, instance=entrevista)
        if form.is_valid():
            form.save()
            return redirect('gestionar_entrevistas', cod_solicitud=entrevista.solicitud.cod_solicitud)
    else:
        form = EntrevistaForm(instance=entrevista)

    return render(request, 'editar_entrevista.html', {'form': form, 'entrevista': entrevista})

# Vista para eliminar entrevista
def eliminar_entrevista(request, cod_entrevista):
    entrevista = get_object_or_404(Entrevista, cod_entrevista=cod_entrevista)
    solicitud_cod = entrevista.solicitud.cod_solicitud
    entrevista.delete()
    return redirect('gestionar_entrevistas', cod_solicitud=solicitud_cod)


