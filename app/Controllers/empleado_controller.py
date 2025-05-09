# app/controller/empleadocontroller.py

from flask import Blueprint, render_template, flash, request, redirect, url_for

#Dependencias app
from app.Models.Empleado import Empleado
from app import get_connection

empleado_bp = Blueprint('empleado_bp', __name__, url_prefix='/inicio/gestion_empleados')

@empleado_bp.route('/')
def pt_gestion_empleado():
    empleados = Empleado.query.all()
    return render_template('empleados/GestionEmpleado.html', empleados=empleados)

@empleado_bp.route('/crear_empleado', methods=['GET', 'POST'])
def pt_crear_empleado():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.callproc('obtener_cargos')

    cargos = []
    for result in cursor.stored_results():
        cargos = [row[0] for row in result.fetchall()]

    cursor.close()
    conn.close()

    if request.method == 'POST':
        # Datos del formulario empleado
        nombre = request.form['nombre']
        email = request.form['email']
        fecha_nacimiento = request.form['fecha_nacimiento']
        telefono = request.form['telefono']
        estado_civil = request.form['estado_civil']
        genero = request.form['genero']
        n_documento = request.form['n_documento']
        cargo = request.form['cargo']
        estado = True
        direccion = request.form['direccion']
        fecha_ingreso = request.form['fecha_ingreso']

        # Datos del formulario contrato
        salario_bruto = request.form['salario_bruto']
        tipo = request.form['tipo']
        horario = request.form['horario']
        fecha_inicio = request.form['fecha_inicio']
        fecha_fin = request.form['fecha_fin']

        conn = get_connection()
        cursor = conn.cursor()

        try:
            id_empleado = 0
            result_args = cursor.callproc('crear_empleado', (
                nombre, email, fecha_nacimiento, telefono,
                estado_civil, genero, n_documento, cargo,
                estado, direccion, fecha_ingreso, id_empleado
            ))
            conn.commit()

            id_empleado = result_args[-1]
            cursor.callproc("crear_contrato", (
                salario_bruto, tipo, horario, fecha_inicio, fecha_fin, id_empleado
            ))

            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"Error: {str(e)}")
        finally:
            cursor.close()
            conn.close()

    return render_template('empleados/GestionEmpleadoAgregar.html', cargos=cargos)

@empleado_bp.route('/editar/<int:id>', methods=['GET', 'POST'])
def pt_editar_empleado(id):
    empleado = Empleado.query.get_or_404(id)
    if request.method == 'POST':
        # Aquí irá la lógica para actualizar el empleado
        pass
    return render_template('empleados/GestionEmpleadoEditar.html', empleado=empleado)

@empleado_bp.route('/eliminar/<int:id>', methods=['POST'])
def pt_eliminar_empleado(id):
    empleado = Empleado.query.get_or_404(id)
    # Aquí irá la lógica para eliminar el empleado
    return redirect(url_for('empleado_bp.pt_gestion_empleado'))