from django.urls import path
from . import views

urlpatterns = [
    path('', views.tu_vista, name='index'),
    path('modulo/admision/', views.modulo_admision, name='modulo_admision'),
    path('modulo/equipos/', views.modulo_equipos, name='modulo_equipos'),
    path('modulo/recargas/', views.modulo_recargas, name='modulo_recargas'),    
    path('modulo/liquidacion/', views.modulo_liquidacion, name='modulo_liquidacion'),
    path('modulo/creditos/', views.modulo_creditos, name='modulo_creditos'),
    path('modulo/cobranzas/', views.modulo_cobranzas, name='modulo_cobranzas'),
    path('modulo/reporteria/', views.modulo_reporteria, name='modulo_reporteria'),
    
    #Urls para Modulo 2
    path('detalle_pedido/<str:cod_pedido>/', views.detalle_pedido, name='detalle_pedido'), 
    path('guardar_observaciones/<str:cod_pedido>/', views.guardar_observaciones, name='guardar_observaciones'),
    path('cambiar_estado/<str:cod_pedido>/', views.cambiar_estado, name='cambiar_estado'),
    path('evaluacion/', views.evaluacion_view, name='evaluacion'),
    path('factura/', views.factura_view, name='factura'),
    path('notificacion/', views.notificacion_view, name='notificacion'),
    
    #Urls para Modulo 3
    path('modulo/recargas/detalles/<str:cod_pedido>/', views.modulo3_detalles, name='modulo3_detalles'),
    path('modulo/recargas/verificar/<str:cod_pedido>/', views.modulo3_verificar, name='modulo3_verificar'),
    path('modulo/recargas/actualizacion/<str:cod_pedido>/', views.modulo3_actualizacion, name='modulo3_actualizacion'),
    path('modulo/recargas/factura_recarga/<str:cod_pedido>/<str:estado_pedido>/', views.factura_recarga, name='factura_recarga'),

]
