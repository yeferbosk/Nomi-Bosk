from flask import Blueprint, render_template, request, redirect, url_for
from app.Controllers import empleado_controller
import os



empleado_bp = Blueprint('empleado_bp', __name__)

@empleado_bp.route('/')
def dashboard():
    return render_template('dashboard.html')

@empleado_bp.route('/empleados/')
def lista():
    empleados = empleado_controller.obtener_empleados()
    return render_template('empleados/lista.html', empleados=empleados)

@empleado_bp.route('/empleados/crear', methods=['POST'])
def crear():
    data = {
        'nombre': request.form['nombre'],
        'email': request.form['email'],
        'fecha_nacimiento': request.form['fecha_nacimiento'],
        'telefono': request.form.get('telefono'),
        'estado_civil': request.form.get('estado_civil'),
        'genero': request.form.get('genero'),
        'n_documento': request.form['n_documento'],
        'cargo': request.form.get('cargo'),
        'estado': request.form.get('estado'),
        'direccion': request.form.get('direccion'),
        'fecha_ingreso': request.form['fecha_ingreso']
    }
    empleado_controller.crear_empleado(data)
    return redirect(url_for('empleado_bp.lista'))

