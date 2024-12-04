from django.db import models
from django.contrib.auth.models import User  # Usando el modelo de usuario de Django


class AnalistaCredito(models.Model):
    cod_analista_ac = models.CharField(max_length=9, primary_key=True)
    nombre_ac = models.CharField(max_length=100)
    correo_electronico_ac = models.EmailField(max_length=100)
    telefono_ac = models.CharField(max_length=15)
    direccion_ac = models.CharField(max_length=150)

    class Meta:
        db_table = 'Analista_credito'

    def __str__(self):
        return f"Analista Crédito {self.nombre_ac}"


# Modelo de Solicitante
class Solicitante(models.Model):
    cod_solicitante = models.CharField(max_length=9, primary_key=True)
    nombre_sol = models.CharField(max_length=100)
    ruc_sol = models.CharField(max_length=11)
    dni_sol = models.CharField(max_length=8)
    ubicacion_sol = models.CharField(max_length=150)
    correo_electronico_sol = models.EmailField(max_length=100)
    telefono_sol = models.CharField(max_length=15)

    class Meta:
        db_table = 'Solicitante'

    def __str__(self):
        return f"Solicitante {self.nombre_sol}"


# Modelo de Solicitud
class Solicitud(models.Model):
    ESTADOS = [
        ('PENDIENTE', 'Pendiente'),
        ('COMPLETADA', 'Completada'),
        ('CANCELADA', 'Cancelada'),
    ]
    
    TIPO_SOLICITUD = [
        ('Distribuidor Autorizado de Claro', 'DAC'),
        ('Centro de Atención Claro', 'CAC'),
    ]
    
    cod_solicitud = models.CharField(max_length=9, primary_key=True)
    fecha_inicio_solicitud = models.DateField()
    fecha_fin_solicitud = models.DateField(blank=True, null=True)
    fecha_notificacion = models.DateField(blank=True, null=True)
    estado_solicitud = models.CharField(
        max_length=50,
        choices=ESTADOS,
        default='PENDIENTE',
        null=True,
        blank=True
    )
    tipo_solicitud = models.CharField(
        max_length=50,
        choices=TIPO_SOLICITUD
    )
    cod_solicitante = models.ForeignKey(Solicitante, on_delete=models.CASCADE)

    class Meta:
        db_table = 'Solicitud'

    def __str__(self):
        return f"Solicitud {self.cod_solicitud} ({self.estado_solicitud})"


# Modelo de Documento
class Documento(models.Model):
    ESTADO_VALIDACION = [
        ('VALIDADO', 'Validado'),
        ('RECHAZADO', 'Rechazado'),
        ('PENDIENTE', 'Pendiente')
    ]
    
    cod_documento = models.CharField(max_length=9, primary_key=True)
    nombre_doc = models.CharField(max_length=100)
    tipo_doc = models.CharField(max_length=50)
    ruta_doc = models.CharField(max_length=255)
    fecha_recibido = models.DateField()
    version = models.IntegerField(default=1)
    estado_validacion = models.CharField(
        max_length=20,
        choices=ESTADO_VALIDACION,
        default='PENDIENTE'
    )
    solicitud = models.ForeignKey(Solicitud, related_name='documentos', on_delete=models.CASCADE)
    cod_analista_ac = models.ForeignKey('AnalistaCredito', related_name='documentos', on_delete=models.SET_NULL, null=True)

    class Meta:
        db_table = 'Documento_adm'

    def __str__(self):
        return f"{self.nombre_doc} ({self.estado_validacion})"


# Modelo de Entrevista
class Entrevista(models.Model):
    cod_entrevista = models.CharField(max_length=9, primary_key=True)
    fecha_entrevista = models.DateField()
    hora_inicio_entrevista = models.TimeField()
    hora_fin_entrevista = models.TimeField()
    resultados_entrevista = models.CharField(max_length=255)
    observaciones_entrevista = models.TextField(blank=True, null=True)
    solicitud = models.ForeignKey(Solicitud, related_name='entrevistas', on_delete=models.CASCADE, null=True)

    class Meta:
        db_table = 'Entrevista'

    def __str__(self):
        return f"Entrevista {self.cod_entrevista}"


# Modelo de Analista de Admisión
class AnalistaAdmision(models.Model):
    cod_analista_adm = models.CharField(max_length=9, primary_key=True)
    nombre_ad = models.CharField(max_length=100)
    correo_electronico_ad = models.EmailField(max_length=100)
    telefono_ad = models.CharField(max_length=15)
    direccion = models.CharField(max_length=150)
    num_aceptados = models.IntegerField(default=0)
    num_rechazados = models.IntegerField(default=0)
    num_pendientes = models.IntegerField(default=0)

    class Meta:
        db_table = 'Analista_adm'

    def __str__(self):
        return f"Analista {self.nombre_ad}"


# Modelo de Capacitaciones
class Capacitacion(models.Model):
    cod_capacitacion = models.CharField(max_length=9, primary_key=True)
    fecha_capacitacion = models.DateField()
    temas_tratados = models.TextField()
    asistencia = models.IntegerField()
    solicitud = models.ForeignKey(Solicitud, related_name='capacitaciones', on_delete=models.CASCADE, null=True)

    class Meta:
        db_table = 'Capacitacion'

    def __str__(self):
        return f"Capacitación {self.cod_capacitacion}"


# Modelo de Seguimiento
class Seguimiento(models.Model):
    cod_seguimiento = models.CharField(max_length=9, primary_key=True)
    fecha_seguimiento = models.DateField()
    indicadores = models.JSONField()  # Usando JSONField para almacenar métricas clave
    observaciones = models.TextField(blank=True, null=True)
    solicitud = models.ForeignKey(Solicitud, related_name='seguimientos', on_delete=models.CASCADE, null=True)

    class Meta:
        db_table = 'Seguimiento'

    def __str__(self):
        return f"Seguimiento {self.cod_seguimiento}"


# Relación entre Solicitudes y Analistas de Admisión
class SolicitudAnalistaAdmision(models.Model):
    cod_sol_analista_adm = models.CharField(max_length=9, primary_key=True)
    fecha_inicio = models.DateField()
    fecha_final = models.DateField()
    analista_adm = models.ForeignKey(
        AnalistaAdmision, 
        related_name='solicitudes', 
        on_delete=models.CASCADE,
        null=True
    )
    solicitud = models.ForeignKey(
        Solicitud, 
        related_name='analistas_admision', 
        on_delete=models.CASCADE,
        null=True
    )

    class Meta:
        db_table = 'Solicitud_Analista_adm'

    def __str__(self):
        return f"Relación {self.cod_sol_analista_adm}"

