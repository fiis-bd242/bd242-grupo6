


from django.db import models
class AnalistaCobranza(models.Model):
    cod_analista_cobranzas = models.CharField(primary_key=True, max_length=9)
    nombre_analista_cobranza = models.CharField(max_length=100)
    fecha_de_contratacion_cobranza = models.DateField()
    telefono_analista_cobranza = models.CharField(max_length=20)
    correo_analista_cobranza = models.CharField(max_length=100)
    region_analista_cobranza = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'analista_cobranza'
class Cliente(models.Model):
    cod_cliente = models.CharField(primary_key=True, max_length=7)
    nombre = models.CharField(max_length=100)
    razon_social = models.CharField(max_length=150, blank=True, null=True)
    telefono = models.CharField(max_length=15, blank=True, null=True)
    correo_empresa = models.CharField(max_length=100, blank=True, null=True)
    direccion_cliente = models.CharField(max_length=150, blank=True, null=True)
    credito_maximo = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    estado_cliente = models.CharField(max_length=50, blank=True, null=True)
    fecha_registro = models.DateField(blank=True, null=True)
    linea_credito = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    clase_persona = models.CharField(max_length=50, blank=True, null=True)
    region = models.CharField(max_length=50, blank=True, null=True)
    rep_legal = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'cliente'


class Deuda(models.Model):
    cod_deuda = models.CharField(primary_key=True, max_length=11)
    estado_deuda = models.CharField(max_length=50, blank=True, null=True)
    monto_deuda = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    dias_retraso = models.IntegerField(blank=True, null=True)
    estado_cobranza = models.CharField(max_length=50, blank=True, null=True)
    fecha_vencimiento = models.DateField(blank=True, null=True)
    cod_analista_cobranza = models.ForeignKey(AnalistaCobranza, models.DO_NOTHING, db_column='cod_analista_cobranza', blank=True, null=True)
    cod_cliente = models.ForeignKey(Cliente, models.DO_NOTHING, db_column='cod_cliente', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'deuda'


class DimAnalistaRp(models.Model):
    ind_analista = models.CharField(max_length=9, blank=True, null=True)
    nam_analista = models.CharField(max_length=100, blank=True, null=True)
    reg_analista = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dim_analista_rp'


class DimCalendarioRp(models.Model):
    ind_date = models.AutoField(primary_key=True)
    fecha_cln = models.DateField(blank=True, null=True)
    periodo_cln = models.IntegerField(blank=True, null=True)
    year_cln = models.CharField(max_length=4, blank=True, null=True)
    mes_cln = models.IntegerField(blank=True, null=True)
    mes_nom_cln = models.CharField(max_length=50, blank=True, null=True)
    dia_cln = models.IntegerField(blank=True, null=True)
    trim_cln = models.CharField(max_length=6, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dim_calendario_rp'


class DimClienteRp(models.Model):
    ind_cliente = models.CharField(max_length=255, primary_key=True)
    nam_cliente = models.CharField(max_length=100, blank=True, null=True)
    sta_cliente = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dim_cliente_rp'


class FactReporteDeudas(models.Model):
    id = models.BigIntegerField(primary_key=True)
    ind_analista = models.CharField(max_length=9, blank=True, null=True)
    reg_analista = models.CharField(max_length=100, blank=True, null=True)
    estado_cobranza = models.CharField(max_length=50, blank=True, null=True)
    ind_date = models.IntegerField(blank=True, null=True)
    ind_cliente = models.CharField(max_length=9, blank=True, null=True)
    suma_monto_deuda_analista = models.DecimalField(max_digits=20, decimal_places=2, blank=True, null=True)
    suma_monto_deuda_region = models.DecimalField(max_digits=20, decimal_places=2, blank=True, null=True)
    cantidad_clientes_atrasado_analista = models.BigIntegerField(blank=True, null=True)
    cantidad_clientes_al_dia_analista = models.BigIntegerField(blank=True, null=True)
    cantidad_clientes_cobranza_admin_trimestre = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'fact_reporte_deudas'


class NotificacionCobranza(models.Model):
    cod_notificacion_cobranza = models.CharField(primary_key=True, max_length=8)
    fecha_envio = models.DateField()
    tipo_notificacion = models.CharField(max_length=50, blank=True, null=True)
    cod_cliente = models.ForeignKey(Cliente, models.DO_NOTHING, db_column='cod_cliente', blank=True, null=True)
    cod_deuda = models.ForeignKey(Deuda, models.DO_NOTHING, db_column='cod_deuda', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'notificacion_cobranza'


class Users(models.Model):
    id = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=255)
    age = models.IntegerField()
    gender = models.CharField(max_length=255)

    class Meta:
        managed = False
        db_table = 'users'