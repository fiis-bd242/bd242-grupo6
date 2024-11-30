from django.urls import path
from dbdApp import views

urlpatterns = [
        path('dim_cliente/', views.dim_cliente_list, name='dim_cliente_list'),
        path('fact/', views.fact_list, name='fact_list'),
        path('r1/', views.reporte_deudas, name='reporte_deudas'),
        path('r2/', views.reporte_deudas_2, name='reporte_deudas2'),
        path('detalle_deuda/<str:analista>/<str:trimestre>/<str:year>/', views.detalle_deuda, name='detalle_deuda'),
]
