# forms.py
from django import forms

class FiltroDimClienteForm(forms.Form):
    nombre_cliente = forms.CharField(required=False, label='Nombre del Cliente')
    estado_cliente = forms.ChoiceField(choices=[('', 'Todos'), ('activo', 'Activo'), ('inactivo', 'Inactivo')], required=False)

class FiltroFactReporteDeudasForm(forms.Form):
    analista = forms.CharField(required=False, label='Analista')
    trimestre = forms.CharField(required=False, label='Trimestre')
    year = forms.IntegerField(required=False, label='Año')
