from django import forms
from .models import (
    Solicitud, Documento, Entrevista, Solicitante,
    Capacitacion, AnalistaAdmision, Seguimiento, SolicitudAnalistaAdmision
)

from django import forms
from .models import Solicitante

class SolicitanteForm(forms.ModelForm):
    class Meta:
        model = Solicitante
        fields = [
            'nombre_sol',
            'ruc_sol',
            'dni_sol',
            'ubicacion_sol',
            'correo_electronico_sol',
            'telefono_sol',
        ]
        widgets = {
            'nombre_sol': forms.TextInput(attrs={'placeholder': 'Nombre del Solicitante'}),
            'ruc_sol': forms.TextInput(attrs={'placeholder': 'RUC'}),
            'dni_sol': forms.TextInput(attrs={'placeholder': 'DNI'}),
            'ubicacion_sol': forms.TextInput(attrs={'placeholder': 'Ubicación'}),
            'correo_electronico_sol': forms.EmailInput(attrs={'placeholder': 'Correo Electrónico'}),
            'telefono_sol': forms.TextInput(attrs={'placeholder': 'Teléfono'}),
        }
        labels = {
            'nombre_sol': 'Nombre del Solicitante',
            'ruc_sol': 'RUC',
            'dni_sol': 'DNI',
            'ubicacion_sol': 'Ubicación',
            'correo_electronico_sol': 'Correo Electrónico',
            'telefono_sol': 'Teléfono',
        }

from django import forms
from .models import Solicitud

class SolicitudForm(forms.ModelForm):
    class Meta:
        model = Solicitud
        fields = [
            'fecha_inicio_solicitud',
            'tipo_solicitud',
            'estado_solicitud',  # Asegúrate de incluir 'estado_solicitud' aquí
            
        ]
        widgets = {
            'fecha_inicio_solicitud': forms.DateInput(attrs={'type': 'date', 'class': 'form-control'}),
            'tipo_solicitud': forms.Select(choices=Solicitud.TIPO_SOLICITUD, attrs={'class': 'form-control'}),
            'estado_solicitud': forms.Select(choices=Solicitud.ESTADOS, attrs={'class': 'form-control'}),  # Si tienes un campo Select
        }
        labels = {
            'fecha_inicio_solicitud': 'Fecha de Inicio de la Solicitud',
            'tipo_solicitud': 'Tipo de Solicitud',
            'estado_solicitud': 'Estado de la Solicitud',  # Etiqueta para el campo
        }



from django import forms
from .models import Documento

class DocumentoForm(forms.ModelForm):
    solicitud_pointer = forms.CharField(
        max_length=12,  # El código de la solicitud tiene un tamaño máximo de 12 caracteres
        widget=forms.HiddenInput(),  # El campo será oculto en el formulario
        label="Código de la Solicitud",  # El label sigue existiendo, pero no se mostrará
        required=False,
    )
    cod_documento_pointer = forms.CharField(
        max_length=12,  # El código de la solicitud tiene un tamaño máximo de 12 caracteres
        widget=forms.HiddenInput(),  # El campo será oculto en el formulario
        label="Código del documento pointer",  # El label sigue existiendo, pero no se mostrará
        required=False,
    )
    archivo = forms.FileField(
        label="Archivo",
        required=False,  # Puedes hacer que este campo no sea obligatorio si lo deseas
    )
    class Meta:
        model = Documento
        fields = ['cod_documento','nombre_doc', 'tipo_doc', 'solicitud_pointer', 'cod_documento_pointer', 'archivo']
        widgets = {
            'cod_documento': forms.HiddenInput(),  # Campo oculto
            'nombre_doc': forms.TextInput(attrs={'placeholder': 'Nombre del documento'}),
            'tipo_doc': forms.TextInput(attrs={'placeholder': 'Tipo de documento'}),
        }
        labels = {
            'nombre_doc': 'Nombre del Documento',
            'tipo_doc': 'Tipo de Documento',
            #'solicitud': 'Código de la Solicitud',  # El label solo será para referencia interna
        }
    
    def __init__(self, *args, **kwargs):
        user = kwargs.get('user')  # Obtener el usuario actual (lo pasamos desde la vista)
        super().__init__(*args, **kwargs)

        # Solo asignamos los códigos de solicitud del usuario actual
        #if user:
            # Filtramos las solicitudes asociadas al usuario
            #solicitudes = Solicitud.objects.filter(cod_solicitante=user.username)
            # Establecemos el valor de 'solicitud' como el código de solicitud de la primera solicitud
            #if solicitudes.exists():
                # Asumimos que la solicitud ya está seleccionada para cada formulario
                #self.fields['solicitud'].initial = solicitudes.first().cod_solicitud

from django.forms import modelformset_factory

# Crear un FormSet para el modelo Documento
DocumentoFormSet = modelformset_factory(
    Documento,
    form=DocumentoForm,
    extra=1,  # Cantidad inicial de formularios en blanco
    can_delete=True  # Permitir eliminar formularios
)

class EntrevistaForm(forms.ModelForm):
    class Meta:
        model = Entrevista
        fields = ['fecha_entrevista', 'hora_inicio_entrevista', 'hora_fin_entrevista', 'resultados_entrevista', 'observaciones_entrevista']
        widgets = {
            'fecha_entrevista': forms.DateInput(attrs={'type': 'date'}),
            'hora_inicio_entrevista': forms.TimeInput(attrs={'type': 'time'}),
            'hora_fin_entrevista': forms.TimeInput(attrs={'type': 'time'}),
            'resultados_entrevista': forms.TextInput(attrs={'placeholder': 'Resultados de la entrevista'}),
            'observaciones_entrevista': forms.Textarea(attrs={'placeholder': 'Observaciones (opcional)'}),
        }

class CapacitacionForm(forms.ModelForm):
    class Meta:
        model = Capacitacion
        fields = ['fecha_capacitacion', 'temas_tratados', 'asistencia']
        widgets = {
            'fecha_capacitacion': forms.DateInput(attrs={'type': 'date'}),
            'temas_tratados': forms.Textarea(attrs={'placeholder': 'Temas tratados durante la capacitación'}),
            'asistencia': forms.NumberInput(attrs={'placeholder': 'Número de asistentes'}),
        }

class AnalistaEvaluacionForm(forms.ModelForm):
    class Meta:
        model = SolicitudAnalistaAdmision
        fields = ['analista_adm', 'solicitud', 'fecha_inicio', 'fecha_final']  # Usamos los nombres correctos de los campos
        widgets = {
            'analista_adm': forms.Select(),  # Campo para seleccionar el analista
            'solicitud': forms.Select(),  # Campo para seleccionar la solicitud
            'fecha_inicio': forms.DateInput(attrs={'type': 'date'}),
            'fecha_final': forms.DateInput(attrs={'type': 'date'}),
        }


class SeguimientoForm(forms.ModelForm):
    class Meta:
        model = Seguimiento
        fields = ['fecha_seguimiento', 'indicadores', 'observaciones']
        widgets = {
            'fecha_seguimiento': forms.DateInput(attrs={'type': 'date'}),
            'indicadores': forms.Textarea(attrs={'placeholder': 'Indicadores clave en formato JSON'}),
            'observaciones': forms.Textarea(attrs={'placeholder': 'Observaciones adicionales'}),
        }
