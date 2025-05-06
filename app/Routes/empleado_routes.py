from flask import Blueprint, render_template, request, redirect, url_for, flash
from app.Controllers.empleado_controller import crear_empleado, obtener_empleados, obtener_empleado, actualizar_empleado, eliminar_empleado
from app import get_connection

empleado_bp = Blueprint('empleado_bp', __name__)

@empleado_bp.route('/')
def dashboard():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT e.id_empleado, e.nombre, c.salario_bruto
        FROM Empleado e
        INNER JOIN Contrato c ON e.id_empleado = c.id_empleado
        WHERE c.fecha_fin IS NULL OR c.fecha_fin > CURDATE()
        ORDER BY e.id_empleado
    """)
    datos_grafica = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('dashboard.html', datos_grafica=datos_grafica)

@empleado_bp.route('/empleados')
def lista_empleados():
    empleados = obtener_empleados()
    return render_template('empleados/lista.html', empleados=empleados)

@empleado_bp.route('/empleados/crear', methods=['GET', 'POST'])
def crear():
    if request.method == 'POST':
        data = {
            'nombre': request.form['nombre'],
            'n_documento': request.form['n_documento'],
            'cargo': request.form['cargo']
        }
        crear_empleado(data)
        return redirect(url_for('empleado_bp.lista_empleados'))
    return render_template('empleados/crear.html')

@empleado_bp.route('/empleados/<int:id>/editar', methods=['GET', 'POST'])
def editar(id):
    if request.method == 'POST':
        data = {
            'nombre': request.form['nombre'],
            'n_documento': request.form['n_documento'],
            'cargo': request.form['cargo']
        }
        actualizar_empleado(id, data)
        return redirect(url_for('empleado_bp.lista_empleados'))
    empleado = obtener_empleado(id)
    return render_template('empleados/editar.html', empleado=empleado)

@empleado_bp.route('/empleados/<int:id>/eliminar', methods=['POST'])
def eliminar(id):
    eliminar_empleado(id)
    return redirect(url_for('empleado_bp.lista_empleados'))

