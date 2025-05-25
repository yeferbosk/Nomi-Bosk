from datetime import date

from flask import Blueprint, flash, redirect, render_template, request, url_for

from app import db
from app.Models.Bonos import Bonos
from app.Models.Contrato import Contrato
from app.Models.Empleado import Empleado

dashboard_bp = Blueprint('dashboard_bp', __name__)

@dashboard_bp.route('/api/comisiones', methods=['GET'])
def vista_comisiones():
    empleados = Empleado.query.filter_by(estado=True).all()
    bonos = db.session.query(
        Empleado.id_empleado,
        Empleado.nombre,
        Empleado.cargo,
        Empleado.email,
        Contrato.salario_bruto.label('salario_base'),
        Bonos.fecha_bono,
        Bonos.valor_bono,
        Bonos.porcentaje_cumplimiento,
        Bonos.observaciones,
        (Contrato.salario_bruto + Bonos.valor_bono).label('total_remuneracion')
    ).join(Contrato, (Contrato.id_empleado == Empleado.id_empleado) & (Contrato.fecha_fin == None))\
     .join(Bonos, Bonos.id_empleado == Empleado.id_empleado)\
     .all()
    return render_template('comisiones.html', empleados=empleados, bonos=bonos)

@dashboard_bp.route('/api/comisiones/agregar', methods=['POST'])
def agregar_bono():
    id_empleado = request.form.get('id_empleado')
    valor_bono = request.form.get('valor_bono')
    porcentaje_cumplimiento = request.form.get('porcentaje_cumplimiento')
    observaciones = request.form.get('observaciones')
    fecha_bono = date.today()

    # Buscar el tipo de bono por cumplimiento
    from app.Models.TiposBonos import TiposBonos
    tipo_bono = TiposBonos.query.filter_by(nombre='Bono por Cumplimiento').first()
    if not tipo_bono:
        tipo_bono = TiposBonos(nombre='Bono por Cumplimiento', descripcion='Bono por cumplimiento de objetivos', es_constitutivo_salario=True)
        db.session.add(tipo_bono)
        db.session.commit()

    bono = Bonos(
        id_empleado=id_empleado,
        id_tipo_bono=tipo_bono.id_tipo_bono,
        fecha_bono=fecha_bono,
        valor_bono=valor_bono,
        porcentaje_cumplimiento=porcentaje_cumplimiento,
        observaciones=observaciones
    )
    db.session.add(bono)
    db.session.commit()
    flash('Bono agregado correctamente', 'success')
    return redirect(url_for('dashboard_bp.vista_comisiones')) 