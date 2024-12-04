from django.urls import path
from . import views

urlpatterns = [

    path('', views.tu_vista, name='index'),
    path('modulo/admision/', views.modulo_admision, name='modulo_admision'),
    path('modulo/equipos/', views.modulo_equipos, name='modulo_equipos'),
    path('modulo/recargas/', views.modulo_recargas, name='modulo_recargas'),
    path('modulo/creditos/', views.modulo_creditos, name='modulo_creditos'),
    path('modulo/cobranzas/', views.modulo_cobranzas, name='modulo_cobranzas'),
    path('modulo/liquidacion/', views.modulo_liquidacion, name='modulo_liquidacion'),
    path('modulo/reporteria/', views.modulo_reporteria, name='modulo_reporteria'),

    path('cobranzas/<str:estado_deuda>/', views.filtrar_clientes, name='filtrar_clientes'),  
    path('filtrar_clientes/', views.filtrar_clientes_por_nombre, name='filtrar_clientes_por_nombre'),
    path('ver_todos_los_clientes/', views.ver_todos_los_clientes, name='ver_todos_los_clientes'),
    path('actualizar_estado_cobranza/', views.actualizar_estado_cobranza, name='actualizar_estado_cobranza'),
    path('detalle/<str:cod_cliente>/', views.detalle_cliente, name='detalle_cliente'),
    path('notificaciones/<str:cod_cliente>/', views.historial_notificaciones, name='historial_notificaciones'),
    path('pago_realizado/<str:cod_cliente>/', views.pago_realizado, name='pago_realizado'),
    path('agregar_notificacion/<str:cod_cliente>/', views.agregar_notificacion, name='agregar_notificacion'),
]


