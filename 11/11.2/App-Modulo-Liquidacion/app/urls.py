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
    path('modulo/liquidacion/programar_resolucion/', views.programar_resolucion, name='programar_resolucion'),
    path('modulo/liquidacion/historico/', views.historico_resoluciones, name='historico_resoluciones'),
    path('modulo6/liquidacion/detalle/<str:codigo_cliente>/', views.detalle_combinado, name='detalle_combinado'),
]