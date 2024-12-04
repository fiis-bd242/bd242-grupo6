from django.contrib import admin  # Asegúrate de importar admin
from django.urls import path
from . import views  # Asegúrate de importar las vistas
from django.contrib.auth import views as auth_views


urlpatterns = [
    path('admin/', admin.site.urls),  # Ahora admin está definido correctamente
    path('accounts/login/', auth_views.LoginView.as_view(), name='login'),

    path('', views.index_solicitante, name='index_solicitante'),  # Página de inicio



    path('solicitudes/', views.solicitudes_list, name='solicitudes_list'),
    path('crear_solicitudes/', views.crear_solicitud, name='crear_solicitudes'),

    path('solicitud/<str:cod_solicitud>/', views.solicitud_detalle, name='solicitud_detalle'),
    path('solicitud/<int:id>/agregar_documentos/', views.agregar_documentos, name='agregar_documentos'),
    path('analista/solicitudes_pendientes/', views.solicitudes_pendientes, name='solicitudes_pendientes'),
    path('analista/gestionar_solicitud/<str:cod_solicitud>/', views.gestionar_solicitud, name='gestionar_solicitud'),
    path('analista/gestionar_documentos/<str:cod_solicitud>/', views.gestionar_documentos, name='gestionar_documentos'),
    path('analista/registrar_entrevista/<str:cod_solicitud>/', views.registrar_entrevista, name='registrar_entrevista'),
    path('analista/registrar_capacitacion/<str:cod_solicitud>/', views.registrar_capacitacion, name='registrar_capacitacion'),
    path('analista/registrar_seguimiento/<str:cod_solicitud>/', views.registrar_seguimiento, name='registrar_seguimiento'),
    path('analista/gestionar_entrevistas/<str:cod_solicitud>/', views.gestionar_entrevistas, name='gestionar_entrevistas'),
    path('analista/gestionar_capacitaciones/<str:cod_solicitud>/', views.gestionar_capacitaciones, name='gestionar_capacitaciones'),
    path('analista/gestionar_seguimientos/<str:cod_solicitud>/', views.gestionar_seguimientos, name='gestionar_seguimientos'),


    path('analista/cambiar_estado_documento/<str:cod_documento>/', views.cambiar_estado_documento, name='cambiar_estado_documento'),
    path('analista/eliminar_documento/<str:cod_documento>/', views.eliminar_documento, name='eliminar_documento'),
    path('analista/editar_capacitacion/<str:cod_capacitacion>/', views.editar_capacitacion, name='editar_capacitacion'),
    path('analista/eliminar_capacitacion/<str:cod_capacitacion>/', views.eliminar_capacitacion, name='eliminar_capacitacion'),
    path('analista/editar_seguimiento/<str:cod_seguimiento>/', views.editar_seguimiento, name='editar_seguimiento'),
    path('analista/eliminar_seguimiento/<str:cod_seguimiento>/', views.eliminar_seguimiento, name='eliminar_seguimiento'),
    path('analista/editar_entrevista/<str:cod_entrevista>/', views.editar_entrevista, name='editar_entrevista'),
    path('analista/eliminar_entrevista/<str:cod_entrevista>/', views.eliminar_entrevista, name='eliminar_entrevista'),
    path('archivo_couchbase/<str:cod_documento>/', views.serve_couchbase_file, name='serve_couchbase_file'),


]
