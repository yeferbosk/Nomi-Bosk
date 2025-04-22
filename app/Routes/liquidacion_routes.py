from flask import Blueprint, render_template, request, redirect, url_for
from app.Controllers import liquidacion_controller, empleado_controller

liquidacion_bp = Blueprint('liquidacion_bp', __name__)

# Aquí cambiamos la ruta para no tener '/api' en el prefijo
@liquidacion_bp.route('/liquidacion')
def lista_liquidaciones():
    liquidaciones = liquidacion_controller.obtener_liquidaciones()
    # Cambiar 'lista.html' por 'listado_liquidaciones.html'
    return render_template('liquidacion/listado_liquidaciones.html', liquidaciones=liquidaciones)

# Y también la ruta para crear liquidaciones
@liquidacion_bp.route('/liquidacion/crear', methods=['GET', 'POST'])
def crear_liquidacion():
    if request.method == 'POST':
        data = {
            'id_empleado': request.form['id_empleado'],
            'tipo_pago': request.form['tipo_pago'],
            'fecha_pago': request.form['fecha_pago']
        }
        liquidacion_controller.crear_liquidacion(data)
        return redirect(url_for('liquidacion_bp.lista_liquidaciones'))
    
    # Obtener empleados para el formulario de creación de liquidación
    empleados = empleado_controller.obtener_empleados()
    return render_template('liquidacion/crear.html', empleados=empleados)
